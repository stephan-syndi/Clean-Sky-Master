//
//  Upgrade.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 2.03.26.
//

import Foundation
import SwiftUI

// MARK: - Upgrade Effect Type

enum EffectType {
    case speed
    case fuel
    case health
    case capacity
    case efficiency
    case armor
    case firepower
    case cargo
}

// MARK: - Upgrade Effect

struct UpgradeEffect {
    let type: EffectType
    let value: Double
    
    var displayString: String {
        switch type {
        case .speed:
            return "+\(Int(value)) km/h"
        case .fuel:
            return "+\(Int(value))%"
        case .health:
            return "+\(Int(value))%"
        case .capacity:
            return "+\(Int(value)) L"
        case .efficiency:
            return "-\(Int(value))%"
        case .armor:
            return "+\(Int(value))"
        case .firepower:
            return "+\(Int(value))"
        case .cargo:
            return "+\(Int(value)) kg"
        }
    }
    
    var color: Color {
        switch type {
        case .speed:
            return .purple
        case .fuel:
            return .green
        case .health:
            return .cyan
        case .capacity:
            return .blue
        case .efficiency:
            return .orange
        case .armor:
            return .red
        case .firepower:
            return .yellow
        case .cargo:
            return .indigo
        }
    }
}

// MARK: - Upgrade Model

struct Upgrade: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let effect: UpgradeEffect
    let cost: Int
    let level: Int
    let maxLevel: Int
    let requirements: [String] // Names of upgrade dependencies
    var isUnlocked: Bool
    var isPurchased: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        icon: String,
        effect: UpgradeEffect,
        cost: Int,
        level: Int,
        maxLevel: Int,
        requirements: [String] = [],
        isUnlocked: Bool = false,
        isPurchased: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.effect = effect
        self.cost = cost
        self.level = level
        self.maxLevel = maxLevel
        self.requirements = requirements
        self.isUnlocked = isUnlocked
        self.isPurchased = isPurchased
    }
}

// MARK: - Upgrade Category

struct UpgradeCategory: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    var upgradeIds: [UUID]
    
    init(title: String, icon: String, color: Color, upgradeIds: [UUID] = []) {
        self.title = title
        self.icon = icon
        self.color = color
        self.upgradeIds = upgradeIds
    }
}

// MARK: - Codable Support for UpgradeEffect

extension UpgradeEffect: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeString = try container.decode(String.self, forKey: .type)
        value = try container.decode(Double.self, forKey: .value)
        
        switch typeString {
        case "speed": type = .speed
        case "fuel": type = .fuel
        case "health": type = .health
        case "capacity": type = .capacity
        case "efficiency": type = .efficiency
        case "armor": type = .armor
        case "firepower": type = .firepower
        case "cargo": type = .cargo
        default: type = .speed
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let typeString: String
        switch type {
        case .speed: typeString = "speed"
        case .fuel: typeString = "fuel"
        case .health: typeString = "health"
        case .capacity: typeString = "capacity"
        case .efficiency: typeString = "efficiency"
        case .armor: typeString = "armor"
        case .firepower: typeString = "firepower"
        case .cargo: typeString = "cargo"
        }
        
        try container.encode(typeString, forKey: .type)
        try container.encode(value, forKey: .value)
    }
}

// MARK: - Sample Data

extension Upgrade {
    static func createDefaultUpgrades() -> [Upgrade] {
        return [
            // ENGINE - Speed
            Upgrade(
                name: "Turbocharger Mk.I",
                description: "Increases aircraft speed",
                icon: "tornado",
                effect: UpgradeEffect(type: .speed, value: 50),
                cost: 300,
                level: 1,
                maxLevel: 3,
                requirements: [],
                isUnlocked: true,
                isPurchased: false
            ),
            Upgrade(
                name: "Turbocharger Mk.II",
                description: "Significantly increases speed",
                icon: "tornado",
                effect: UpgradeEffect(type: .speed, value: 100),
                cost: 600,
                level: 2,
                maxLevel: 3,
                requirements: ["Turbocharger Mk.I"],
                isUnlocked: false,
                isPurchased: false
            ),
            Upgrade(
                name: "Jet Engine",
                description: "Maximum flight speed",
                icon: "flame.fill",
                effect: UpgradeEffect(type: .speed, value: 200),
                cost: 1200,
                level: 3,
                maxLevel: 3,
                requirements: ["Turbocharger Mk.II"],
                isUnlocked: false,
                isPurchased: false
            ),
            
            // FUEL SYSTEM
            Upgrade(
                name: "Extended Tank",
                description: "Increases fuel capacity",
                icon: "cylinder.fill",
                effect: UpgradeEffect(type: .fuel, value: 20),
                cost: 250,
                level: 1,
                maxLevel: 3,
                requirements: [],
                isUnlocked: true,
                isPurchased: false
            ),
            Upgrade(
                name: "Efficient Pump",
                description: "Reduces fuel consumption",
                icon: "arrow.down.circle.fill",
                effect: UpgradeEffect(type: .efficiency, value: 15),
                cost: 400,
                level: 2,
                maxLevel: 3,
                requirements: ["Extended Tank"],
                isUnlocked: false,
                isPurchased: false
            ),
            Upgrade(
                name: "Cryogenic Cooling",
                description: "Maximum fuel efficiency",
                icon: "snowflake",
                effect: UpgradeEffect(type: .efficiency, value: 30),
                cost: 800,
                level: 3,
                maxLevel: 3,
                requirements: ["Efficient Pump"],
                isUnlocked: false,
                isPurchased: false
            ),
            
            // HULL - Health
            Upgrade(
                name: "Reinforced Plating",
                description: "Increases aircraft durability",
                icon: "shield.lefthalf.filled",
                effect: UpgradeEffect(type: .health, value: 20),
                cost: 350,
                level: 1,
                maxLevel: 3,
                requirements: [],
                isUnlocked: true,
                isPurchased: false
            ),
            Upgrade(
                name: "Titanium Frame",
                description: "Significantly increases durability",
                icon: "shield.fill",
                effect: UpgradeEffect(type: .health, value: 40),
                cost: 700,
                level: 2,
                maxLevel: 3,
                requirements: ["Reinforced Plating"],
                isUnlocked: false,
                isPurchased: false
            ),
            Upgrade(
                name: "Composite Armor",
                description: "Maximum protection",
                icon: "shield.checkered",
                effect: UpgradeEffect(type: .armor, value: 30),
                cost: 1000,
                level: 3,
                maxLevel: 3,
                requirements: ["Titanium Frame"],
                isUnlocked: false,
                isPurchased: false
            ),
            
            // ARMAMENT
            Upgrade(
                name: "Improved Cannons",
                description: "Increases firepower",
                icon: "scope",
                effect: UpgradeEffect(type: .firepower, value: 15),
                cost: 400,
                level: 1,
                maxLevel: 3,
                requirements: [],
                isUnlocked: true,
                isPurchased: false
            ),
            Upgrade(
                name: "Rocket Launchers",
                description: "Significantly increases damage",
                icon: "sparkles",
                effect: UpgradeEffect(type: .firepower, value: 30),
                cost: 800,
                level: 2,
                maxLevel: 3,
                requirements: ["Improved Cannons"],
                isUnlocked: false,
                isPurchased: false
            ),
            
            // CARGO CAPACITY
            Upgrade(
                name: "Expanded Cargo Hold",
                description: "Increases cargo capacity",
                icon: "shippingbox.fill",
                effect: UpgradeEffect(type: .cargo, value: 100),
                cost: 300,
                level: 1,
                maxLevel: 3,
                requirements: [],
                isUnlocked: true,
                isPurchased: false
            ),
            Upgrade(
                name: "Modular Containers",
                description: "Significantly increases capacity",
                icon: "cube.box.fill",
                effect: UpgradeEffect(type: .cargo, value: 200),
                cost: 600,
                level: 2,
                maxLevel: 3,
                requirements: ["Expanded Cargo Hold"],
                isUnlocked: false,
                isPurchased: false
            )
        ]
    }
    
    static func createDefaultCategories(for upgrades: [Upgrade]) -> [UpgradeCategory] {
        var categories = [
            UpgradeCategory(
                title: "ENGINE",
                icon: "engine.combustion.fill",
                color: .red
            ),
            UpgradeCategory(
                title: "FUEL SYSTEM",
                icon: "fuelpump.fill",
                color: .green
            ),
            UpgradeCategory(
                title: "HULL",
                icon: "shield.fill",
                color: .cyan
            ),
            UpgradeCategory(
                title: "ARMAMENT",
                icon: "sparkles",
                color: .yellow
            ),
            UpgradeCategory(
                title: "CARGO CAPACITY",
                icon: "shippingbox.fill",
                color: .indigo
            )
        ]
        
        // Assign upgrades to categories by indices
        if upgrades.count >= 13 {
            categories[0].upgradeIds = [upgrades[0].id, upgrades[1].id, upgrades[2].id] // Engine
            categories[1].upgradeIds = [upgrades[3].id, upgrades[4].id, upgrades[5].id] // Fuel
            categories[2].upgradeIds = [upgrades[6].id, upgrades[7].id, upgrades[8].id] // Hull
            categories[3].upgradeIds = [upgrades[9].id, upgrades[10].id] // Armament
            categories[4].upgradeIds = [upgrades[11].id, upgrades[12].id] // Cargo Capacity
        }
        
        return categories
    }
}
