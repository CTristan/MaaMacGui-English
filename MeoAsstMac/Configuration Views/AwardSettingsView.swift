//
//  AwardSettingsView.swift
//  MAA
//
//  Created by hguandl on 1/11/2023.
//

import SwiftUI

struct AwardSettingsView: View {
    @Binding var config: AwardConfiguration

    var body: some View {
        Form {
            Toggle("领取每日/每周任务奖励", isOn: $config.award)

            Toggle(String(localized: "领取所有邮件奖励"), isOn: $config.mail)

            Toggle(String(localized: "进行每日免费单抽"), isOn: $config.recruit)

            Toggle(String(localized: "领取幸运墙合成玉奖励"), isOn: $config.orundum)

            Toggle(String(localized: "领取限时开采许可合成玉奖励"), isOn: $config.mining)

            Toggle(String(localized: "领取周年庆赠送月卡奖励"), isOn: $config.specialaccess)
        }
        .padding()
    }
}

struct AwardSettings_Preview: PreviewProvider {
    static var previews: some View {
        AwardSettingsView(config: .constant(.init()))
    }
}
