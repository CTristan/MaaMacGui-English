//
//  LocalizedEditableTextList.swift
//  MeoAsstMac
//
//  A localized version of EditableTextList that displays item names in the user's language
//  while storing Chinese names internally for MaaCore compatibility.
//

import SwiftUI

struct LocalizedEditableTextList: View {
    let title: LocalizedStringKey
    @Binding var chineseTexts: [String]  // Stored as Chinese for MaaCore

    private struct TextEntry: Equatable, Identifiable {
        let id: Int
        var chineseValue: String  // The actual Chinese value stored
        var displayValue: String  // What's shown to the user (localized or Chinese)
    }

    private var entries: Binding<[TextEntry]> {
        Binding {
            chineseTexts.enumerated().map { TextEntry(
                id: $0.offset,
                chineseValue: $0.element,
                displayValue: ItemNameLocalizer.localizedDisplayName(for: $0.element)
            )
            }
        } set: { newValue in
            // Store the Chinese values
            chineseTexts = newValue.map(\.chineseValue)
        }
    }

    @State private var selection: Int?
    @FocusState private var focusedField: Int?

    var body: some View {
        List(selection: $selection) {
            Section {
                ForEach(entries) { entry in
                    HStack {
                        TextField("", text: binding(for: entry))
                            .focused($focusedField, equals: entry.id)
                            .onChange(of: entry.displayValue) { newValue in
                                // When user edits, convert back to Chinese
                                entry.chineseValue.wrappedValue = ItemNameLocalizer.chineseName(for: newValue)
                                entry.displayValue.wrappedValue = newValue
                            }

                        Button {
                            selection = entry.id
                            focusedField = entry.id
                        } label: {
                            Image(systemName: "pencil")
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onMove(perform: moveEntry)
            } header: {
                Text(title)
            } footer: {
                editButtons()
            }
        }
        .animation(.default, value: chineseTexts)
    }

    /// Create a binding that syncs display value with Chinese value
    private func binding(for entry: TextEntry) -> Binding<String> {
        Binding(
            get: { entry.displayValue },
            set: { newValue in
                entry.displayValue.wrappedValue = newValue
                entry.chineseValue.wrappedValue = ItemNameLocalizer.chineseName(for: newValue)
            }
        )
    }

    @ViewBuilder private func editButtons() -> some View {
        HStack {
            Button {
                addEntry()
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.plain)

            Button {
                deleteEntry()
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
        }
    }

    private func moveEntry(source: IndexSet, destination: Int) {
        chineseTexts.move(fromOffsets: source, toOffset: destination)
    }

    private func addEntry() {
        chineseTexts.append("")
        selection = chineseTexts.count - 1
    }

    private func deleteEntry() {
        if let selection {
            chineseTexts.remove(at: selection)
        }
        selection = nil
    }
}
