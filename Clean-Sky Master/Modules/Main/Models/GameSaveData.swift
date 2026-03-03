//
//  GameSaveData.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 02.03.26.
//

import Foundation

// MARK: - Game Save Data

/// Структура для сохранения всего прогресса игры
struct GameSaveData: Codable {
    let version: Int = 1
    let savedAt: Date
    
    // Aircraft
    let aircraft: Aircraft
    
    // Pilot
    let pilotName: String
    let pilotLevel: Int
    let pilotExperience: Int
    let pilotSkillPoints: Int
    let pilotBattleRating: Int
    let pilotCombatSkill: Int
    let pilotNavigationSkill: Int
    let pilotEfficiencySkill: Int
    
    // Economy
    let credits: Int
    let fuelUnits: Int
    let parts: Int
    let repairKits: [SavedRepairKit]
    let lastFuelRefill: Date
    
    // Altitude
    let altitude: Double
    
    init(
        aircraft: Aircraft,
        pilot: Pilot,
        economy: EconomyManager,
        altitude: Double
    ) {
        self.savedAt = Date()
        
        // Aircraft
        self.aircraft = aircraft
        
        // Pilot
        self.pilotName = pilot.name
        self.pilotLevel = pilot.level
        self.pilotExperience = pilot.experience
        self.pilotSkillPoints = pilot.skillPoints
        self.pilotBattleRating = pilot.battleRating
        self.pilotCombatSkill = pilot.combatSkill
        self.pilotNavigationSkill = pilot.navigationSkill
        self.pilotEfficiencySkill = pilot.efficiencySkill
        
        // Economy
        self.credits = economy.credits
        self.fuelUnits = economy.fuelUnits
        self.parts = economy.parts
        self.repairKits = economy.repairKits.map { SavedRepairKit(from: $0) }
        self.lastFuelRefill = economy.getLastFuelRefill()
        
        // Altitude
        self.altitude = altitude
    }
}

// MARK: - Saved Repair Kit

/// Codable версия RepairKit
struct SavedRepairKit: Codable {
    let id: String
    let typeRawValue: String
    
    init(from kit: RepairKit) {
        self.id = kit.id.uuidString
        self.typeRawValue = kit.type.rawValue
    }
    
    func toRepairKit() -> RepairKit? {
        guard let type = RepairKitType(rawValue: typeRawValue) else { return nil }
        var kit = RepairKit(type: type)
        // Восстанавливаем UUID если возможно
        if let uuid = UUID(uuidString: id) {
            kit = RepairKit(type: type)
        }
        return kit
    }
}
