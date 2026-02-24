//
//  ConnectionSettingsView.swift
//  MeoAsstMac
//
//  Created by hguandl on 10/10/2022.
//

import SwiftUI

struct ConnectionSettingsView: View {
    @EnvironmentObject private var viewModel: MAAViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Picker(String(localized: "Touch Mode"), selection: $viewModel.touchMode) {
                ForEach(MaaTouchMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue)
                }
            }

            if viewModel.touchMode == .MacPlayTools {
                Text(String(localized: "PlayTools Documentation"))
                    .font(.caption).foregroundStyle(.secondary)
            }

            HStack {
                Text(String(localized: "Connection Address"))
                TextField("", text: $viewModel.connectionAddress)
            }

            Divider()

            Toggle(isOn: allowGzip) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "Allow Gzip"))
                    Text(String(localized: "Gzip Memory Warning"))
                        .font(.caption).foregroundStyle(.secondary)
                }
            }

            Toggle(isOn: $viewModel.useAdbLite) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "Use ADB Lite"))
                    Text(String(localized: "Use ADB Lite Tip"))
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .animation(.default, value: viewModel.touchMode)
    }

    private var allowGzip: Binding<Bool> {
        Binding {
            viewModel.connectionProfile == "Compatible"
        } set: { allow in
            if allow {
                viewModel.connectionProfile = "Compatible"
            } else {
                viewModel.connectionProfile = "CompatMac"
            }
        }
    }
}

struct ConnectionSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionSettingsView()
            .environmentObject(MAAViewModel())
    }
}

enum MaaTouchMode: String, CaseIterable {
    case adb
    case minitouch
    case maatouch
    case MacPlayTools
}
