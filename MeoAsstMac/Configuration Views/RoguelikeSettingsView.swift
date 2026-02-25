//
//  RoguelikeSettingsView.swift
//  MeoAsstMac
//
//  Created by hguandl on 9/10/2022.
//

import SwiftUI

struct RoguelikeSettingsView: View {
    @Binding var config: RoguelikeConfiguration

    @Environment(\.defaultMinListRowHeight) private var rowHeight

    var body: some View {
        ScrollView {
            Form {
                generalSettings()
                Divider()
                goldSettings()
                Divider()
                squadSettings()
                Divider()
                strategySettings()
            }
            .animation(.default, value: config)
            .padding()
        }
    }

    @ViewBuilder private func generalSettings() -> some View {
        Picker(String(localized: "主题"), selection: $config.theme) {
            ForEach(RoguelikeConfiguration.Theme.allCases, id: \.self) {
                Text($0.description).tag($0)
            }
        }

        if config.theme != .Phantom {
            Picker(String(localized: "难度"), selection: $config.difficulty) {
                ForEach(config.theme.difficulties) {
                    Text($0.description).tag($0)
                }
            }
        }

        TextField(String(localized: "最多探索次数"), value: $config.starts_count, format: .number)
    }

    @ViewBuilder private func goldSettings() -> some View {
        HStack {
            Toggle(String(localized: "投资源石锭"), isOn: $config.investment_enabled)
            if config.investment_enabled {
                Toggle(String(localized: "储备源石锭达到上限时停止"), isOn: $config.stop_when_investment_full)
            }
        }
        if config.investment_enabled {
            TextField(String(localized: "最多投资数量"), value: $config.investments_count, format: .number)
        }
    }

    @ViewBuilder private func squadSettings() -> some View {
        Picker(String(localized: "开局分队"), selection: $config.squad) {
            ForEach(config.theme.squads, id: \.self) { squad in
                Text(squad).tag(squad)
            }
        }

        Picker(String(localized: "开局职业组"), selection: $config.roles) {
            ForEach(config.theme.roles, id: \.self) { role in
                Text(role).tag(role)
            }
        }

        TextField("开局干员（单个）", text: $config.core_char)

        HStack {
            Toggle("“开局干员”使用助战", isOn: $config.use_support)
            if config.use_support {
                Toggle(String(localized: "可以使用非好友助战"), isOn: $config.use_nonfriend_support)
            }
        }

    }

    @ViewBuilder private func startCollectibles() -> some View {
        LazyVGrid(columns: .init(repeating: .init(.flexible()), count: 4), alignment: .leading) {
            Toggle(String(localized: "热水壶"), isOn: $config.collectible_mode_start_list.hot_water)
            Toggle(String(localized: "盾"), isOn: $config.collectible_mode_start_list.shield)
            Toggle(String(localized: "源石锭"), isOn: $config.collectible_mode_start_list.ingot)
            Toggle(String(localized: "希望"), isOn: $config.collectible_mode_start_list.hope)
            Toggle(String(localized: "随机奖励"), isOn: $config.collectible_mode_start_list.random)
            if config.theme == .Mizuki {
                Toggle(String(localized: "钥匙"), isOn: $config.collectible_mode_start_list.key)
                Toggle(String(localized: "骰子"), isOn: $config.collectible_mode_start_list.dice)
            }
            if config.theme == .Sarkaz {
                Toggle(String(localized: "构想"), isOn: $config.collectible_mode_start_list.ideas)
            }
        }
    }

    @ViewBuilder private func strategySettings() -> some View {
        Picker(String(localized: "策略"), selection: $config.mode) {
            ForEach(config.theme.modes, id: \.self) {
                Text($0.description).tag($0)
            }
        }

        if config.mode == .collectible {
            Picker(String(localized: "烧水分队"), selection: $config.collectible_mode_squad) {
                ForEach(config.theme.squads, id: \.self) {
                    Text($0).tag($0)
                }
            }

            LabeledContent(String(localized: "烧水奖励"), value: "").padding(.top, 1)
            startCollectibles().padding(.top, -rowHeight)

            Divider()
        }

        HStack {
            Toggle(String(localized: "满级后自动停止"), isOn: $config.stop_at_max_level)
            if config.theme != .Phantom {
                Toggle("在第五层BOSS前暂停", isOn: $config.stop_at_final_boss)
            }
            if config.mode == .investment {
                Toggle(String(localized: "投资后进二层"), isOn: $config.investment_with_more_score)
            }
            if config.mode == .collectible {
                Toggle(String(localized: "刷开局启用购物"), isOn: $config.collectible_mode_shopping)
            }
        }

        if config.mode == .collectible {
            HStack {
                Toggle(String(localized: "凹开局干员精二直升"), isOn: $config.start_with_elite_two)
                if config.start_with_elite_two {
                    Toggle(String(localized: "只凹直升不凹其他"), isOn: $config.only_start_with_elite_two)
                }
            }
        }

        if config.theme == .Mizuki {
            Toggle("刷新商店（指路鳞）", isOn: $config.refresh_trader_with_dice)
        }

        if config.theme == .Sami {
            HStack {
                Toggle(String(localized: "使用密文板"), isOn: $config.use_foldartal)
                Toggle(String(localized: "检测获取的坍缩范式"), isOn: $config.check_collapsal_paradigms)
            }
            TextField(String(localized: "一层远见密文板"), text: $config.first_floor_foldartal)
            if config.mode == .collectible, config.squad == String(localized: "生活至上分队") {
                TextField(String(localized: "分队开局密文板"), text: $config.semicolonString(for: \.start_foldartal_list))
            }
            if config.mode == .clpPds {
                TextField(String(localized: "待刷坍缩范式"), text: $config.semicolonString(for: \.expected_collapsal_paradigms))
            }
        }

        if config.theme == .Sarkaz, config.mode == .collectible {
            Toggle("凹2构想开局", isOn: $config.start_with_two_ideas)
        }

        if config.mode == .squad {
            HStack {
                Toggle(String(localized: "月度小队自动切换"), isOn: $config.monthly_squad_auto_iterate)
                if config.monthly_squad_auto_iterate {
                    Toggle(String(localized: "月度小队通讯"), isOn: $config.monthly_squad_check_comms)
                }
            }
        }

        if config.mode == .exploration {
            Toggle(String(localized: "深度调查自动切换"), isOn: $config.deep_exploration_auto_iterate)
        }
    }
}

#Preview {
    struct Preview: View {
        @State var config = RoguelikeConfiguration()
        var body: some View {
            RoguelikeSettingsView(config: $config)
        }
    }
    return Preview()
}

// MARK: - Constants

extension RoguelikeConfiguration.Mode {
    var description: String {
        switch self {
        case .exp:
            NSLocalizedString("刷分/奖励点数，尽可能稳定地打更多层数", comment: "")
        case .investment:
            NSLocalizedString("刷源石锭，到达第二层后直接退出", comment: "")
        case .collectible:
            NSLocalizedString("刷开局，刷取热水壶或精二干员开局", comment: "")
        case .clpPds:
            NSLocalizedString("刷坍缩范式，遇到非稀有坍缩范式后重开", comment: "")
        case .squad:
            NSLocalizedString("刷月度小队，到达第五层后直接退出", comment: "")
        case .exploration:
            NSLocalizedString("刷深入调查，尽可能稳定地打更多层数", comment: "")
        }
    }
}

extension RoguelikeConfiguration.Theme: CustomStringConvertible {
    var description: String {
        switch self {
        case .Phantom:
            return NSLocalizedString(String(localized: "傀影与猩红血钻"), comment: "")
        case .Mizuki:
            return NSLocalizedString(String(localized: "水月与深蓝之树"), comment: "")
        case .Sami:
            return NSLocalizedString(String(localized: "探索者的银凇止境"), comment: "")
        case .Sarkaz:
            return NSLocalizedString(String(localized: "萨卡兹的无终奇语"), comment: "")
        case .JieGarden:
            return NSLocalizedString(String(localized: "岁的界园志异"), comment: "")
        }
    }

    var difficulties: [RoguelikeConfiguration.Difficulty] {
        switch self {
        case .Phantom:
            return []
        case .Mizuki:
            return RoguelikeConfiguration.Difficulty.upto(maximum: 15)
        case .Sami:
            return RoguelikeConfiguration.Difficulty.upto(maximum: 15)
        case .Sarkaz:
            return RoguelikeConfiguration.Difficulty.upto(maximum: 18)
        case .JieGarden:
            return RoguelikeConfiguration.Difficulty.upto(maximum: 15)
        }
    }

    var squads: [String] {
        switch self {
        case .Phantom:
            [
                String(localized: "指挥分队"), String(localized: "集群分队"), String(localized: "后勤分队"), String(localized: "矛头分队"),
                String(localized: "突击战术分队"), String(localized: "堡垒战术分队"), String(localized: "远程战术分队"), String(localized: "破坏战术分队"),
                String(localized: "研究分队"), String(localized: "高规格分队"),
            ]
        case .Mizuki:
            [
                String(localized: "心胜于物分队"), String(localized: "物尽其用分队"), String(localized: "以人为本分队"),
                String(localized: "指挥分队"), String(localized: "集群分队"), String(localized: "后勤分队"), String(localized: "矛头分队"),
                String(localized: "突击战术分队"), String(localized: "堡垒战术分队"), String(localized: "远程战术分队"), String(localized: "破坏战术分队"),
                String(localized: "研究分队"), String(localized: "高规格分队"),
            ]
        case .Sami:
            [
                String(localized: "指挥分队"), String(localized: "集群分队"), String(localized: "后勤分队"), String(localized: "矛头分队"),
                String(localized: "突击战术分队"), String(localized: "堡垒战术分队"), String(localized: "远程战术分队"), String(localized: "破坏战术分队"),
                String(localized: "高规格分队"), String(localized: "特训分队"),
                String(localized: "科学主义分队"), String(localized: "生活至上分队"), String(localized: "永恒狩猎分队"),
            ]
        case .Sarkaz:
            [
                String(localized: "魂灵护送分队"), String(localized: "博闻广记分队"), String(localized: "蓝图测绘分队"),
                String(localized: "指挥分队"), String(localized: "集群分队"), String(localized: "后勤分队"), String(localized: "矛头分队"),
                String(localized: "突击战术分队"), String(localized: "堡垒战术分队"), String(localized: "远程战术分队"), String(localized: "破坏战术分队"),
                String(localized: "高规格分队"), String(localized: "因地制宜分队"),
                String(localized: "点刺成锭分队"), String(localized: "拟态学者分队"), String(localized: "异想天开分队"),
            ]
        case .JieGarden:
            [
                String(localized: "指挥分队"), String(localized: "特勤分队"), String(localized: "后勤分队"),
                String(localized: "突击战术分队"), String(localized: "堡垒战术分队"), String(localized: "远程战术分队"), String(localized: "破坏战术分队"),
                String(localized: "高规格分队"), String(localized: "高台突破分队"), String(localized: "地面突破分队"),
                String(localized: "游客分队"), String(localized: "司岁台分队"), String(localized: "天师府分队"),
                String(localized: "花团锦簇分队"), String(localized: "棋行险着分队"), String(localized: "岁影回音分队"),
            ]
        }
    }

    var roles: [String] {
        switch self {
        case .JieGarden:
            [String(localized: "先手必胜"), String(localized: "稳扎稳打"), String(localized: "取长补短"), String(localized: "灵活部署"), String(localized: "坚不可摧"), String(localized: "随心所欲")]
        default:
            [String(localized: "先手必胜"), String(localized: "稳扎稳打"), String(localized: "取长补短"), String(localized: "随心所欲")]
        }
    }
}
