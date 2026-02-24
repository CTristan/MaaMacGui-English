//
//  ItemNameLocalizer.swift
//  MeoAsstMac
//
//  Helper for localizing item names in shopping and other configurations.
//  The backend (MaaCore) expects Chinese item names, but we display localized names to users.
//

import Foundation

struct ItemNameLocalizer {
    /// List of Chinese item names that should be localized
    /// These are the keys used in Localizable.xcstrings
    private static let knownItemNames: Set<String> = [
        // Shopping Mall Items
        "招聘许可", "招聘许可×5",
        "龙门币", "龙门币×1000", "龙门币×5000", "龙门币×10000",
        "加急许可",
        "家具零件", "家具零件×4",
        "作战记录", "作战记录×10", "初级作战记录", "中级作战记录", "高级作战记录", "特级作战记录",
        "理智合剂", "理智合剂×2",
        "源石碎片",
        "碳素", "碳素组",
        "赤金",
        "固源岩",
        "糖", "糖×4",
        "技巧概要",
        "建材",
        "招揽信",
        "寻访凭证", "公开招募券",
        "理智", "体力",
        "源石",
        "合成玉",
        "助理",
    ]

    /// Get the localized display name for an item
    /// - Parameter chineseName: The Chinese item name used by MaaCore
    /// - Returns: The localized display name, or the original if no mapping exists
    static func localizedDisplayName(for chineseName: String) -> String {
        if knownItemNames.contains(chineseName) {
            return String(localized: String.LocalizationValue(chineseName))
        }
        return chineseName
    }

    /// Convert a display name back to the Chinese name expected by MaaCore
    /// - Parameter displayName: The display name (could be Chinese or localized)
    /// - Returns: The Chinese name expected by MaaCore
    static func chineseName(for displayName: String) -> String {
        // If it's already a known Chinese name, return it
        if knownItemNames.contains(displayName) {
            return displayName
        }

        // Try to find a known Chinese name whose localized version matches
        for chineseName in knownItemNames {
            let localized = String(localized: String.LocalizationValue(chineseName))
            if localized.lowercased() == displayName.lowercased() {
                return chineseName
            }
        }

        // Return as-is if no mapping found
        return displayName
    }

    /// Check if an item name is a known Chinese name
    static func isKnownChineseName(_ name: String) -> Bool {
        return knownItemNames.contains(name)
    }
}
