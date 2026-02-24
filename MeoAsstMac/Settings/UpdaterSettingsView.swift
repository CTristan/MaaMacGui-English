//
//  UpdaterSettingsView.swift
//  MeoAsstMac
//
//  Created by hguandl on 13/3/2023.
//

import Sparkle
import SwiftUI

struct UpdaterSettingsView: View {
    private let updater: SPUUpdater

    @State private var automaticallyChecksForUpdates: Bool
    @State private var automaticallyDownloadsUpdates: Bool

    @AppStorage("MaaUseBetaChannel") private var useBetaChannel = false
    @AppStorage("AutoResourceUpdate") var autoResourceUpdate = false
    @AppStorage("ResourceUpdateChannel") var resourceChannel = MAAResourceChannel.github

    init(updater: SPUUpdater) {
        self.updater = updater
        self.automaticallyChecksForUpdates = updater.automaticallyChecksForUpdates
        self.automaticallyDownloadsUpdates = updater.automaticallyDownloadsUpdates
    }

    var body: some View {
        Form {
            Toggle(String(localized: "Receive Beta Updates"), isOn: $useBetaChannel)

            Toggle(String(localized: "Automatically Check for Updates"), isOn: $automaticallyChecksForUpdates)
                .onChange(of: automaticallyChecksForUpdates) { newValue in
                    updater.automaticallyChecksForUpdates = newValue
                }

            Toggle(String(localized: "Automatically Download Updates"), isOn: $automaticallyDownloadsUpdates)
                .disabled(!automaticallyChecksForUpdates)
                .onChange(of: automaticallyDownloadsUpdates) { newValue in
                    updater.automaticallyDownloadsUpdates = newValue
                }

            Divider()

            Picker(String(localized: "Resource Update Source"), selection: $resourceChannel) {
                ForEach(MAAResourceChannel.allCases, id: \.hashValue) { channel in
                    Text(channel.description).tag(channel)
                }
            }

            if resourceChannel == .mirrorChyan {
                SecureField(String(localized: "CDK"), text: mirrorChyanCDK)
            } else if resourceChannel == .github {
                Text(String(localized: "System Proxy May Be Required"))
                    .font(.caption).foregroundStyle(.secondary)
            }

            Toggle(String(localized: "Auto Resource Update"), isOn: $autoResourceUpdate)

            Text(String(localized: "Restart App for Changes"))
                .font(.caption).foregroundStyle(.secondary)
        }
        .animation(.default, value: resourceChannel)
        .padding()
    }
}

private let mirrorChyanCDK = Binding {
    MirrorChyan.getCDK() ?? ""
} set: {
    _ = MirrorChyan.setCDK($0)
}

struct UpdaterSettingsView_Previews: PreviewProvider {
    private static let updateController = SPUStandardUpdaterController(
        startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)

    static var previews: some View {
        UpdaterSettingsView(updater: updateController.updater)
    }
}
