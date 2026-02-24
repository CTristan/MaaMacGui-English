//
//  LogView.swift
//  MAA
//
//  Created by hguandl on 16/4/2023.
//

import SwiftUI

struct LogView: View {
    @EnvironmentObject private var viewModel: MAAViewModel

    var body: some View {
        ScrollViewReader { proxy in
            Table(viewModel.logs) {
                TableColumn(String(localized: "时间"), value: \.date.maaFormat)
                    .width(min: 100, ideal: 125, max: 150)
                TableColumn(String(localized: "信息")) { log in
                    Text(log.content)
                        .textSelection(.enabled)
                        .foregroundStyle(log.color.textColor)
                        .lineLimit(nil)
                }
                .width(min: 100, ideal: 300)
            }
            .animation(.default, value: viewModel.logs)
            .toolbar {
                HStack {
                    Divider()

                    Toggle(isOn: $viewModel.trackTail) {
                        Label(String(localized: "现在"), systemImage: "arrow.down.to.line")
                    }
                    .help(String(localized: "自动滚动到底部"))
                }
            }
            .onChange(of: viewModel.logs) { _ in
                if viewModel.trackTail {
                    withAnimation {
                        proxy.scrollTo(viewModel.logs.last?.id ?? UUID())
                    }
                }
            }
            .onChange(of: viewModel.trackTail) { newValue in
                if newValue {
                    withAnimation {
                        proxy.scrollTo(viewModel.logs.last?.id ?? UUID())
                    }
                }
            }
        }
    }
}

extension Date {
    fileprivate var maaFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView().environmentObject(MAAViewModel())
    }
}
