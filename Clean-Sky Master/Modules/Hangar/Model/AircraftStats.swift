//
//  AircraftStats.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Aircraft Stats
// NOTE: This is a legacy version with ObservableObject classes.
// New MVVM architecture uses struct models from Models/ and ViewModels from ViewModels/

/// Aircraft parameters
class AircraftStats: ObservableObject {
    @Published var fuel: Double // Fuel (0-100)
    @Published var maxFuel: Double // Maximum capacity
    @Published var armor: Int // Armor
    @Published var firepower: Int // Weapons
    @Published var speed: Int // Speed
    @Published var cargo: Int // Cargo capacity
    @Published var health: Double // Hull health (0-100)
    @Published var installedModules: [String] // Installed modules
    
    init(
        fuel: Double = 75.0,
        maxFuel: Double = 100.0,
        armor: Int = 10,
        firepower: Int = 5,
        speed: Int = 450,
        cargo: Int = 100,
        health: Double = 90.0,
        installedModules: [String] = []
    ) {
        self.fuel = fuel
        self.maxFuel = maxFuel
        self.armor = armor
        self.firepower = firepower
        self.speed = speed
        self.cargo = cargo
        self.health = health
        self.installedModules = installedModules
    }
    
    // MARK: - Methods
    
    /// Flight range calculation
    func maxRange() -> Double {
        let baseRange = 1000.0
        let fuelCoefficient = fuel / 100.0
        let cargoModifier = 1.0 - (Double(cargo) / 500.0) // Cargo reduces range
        return baseRange * fuelCoefficient * cargoModifier
    }
    
    /// Mission success chance based on distance
    func successChance(forDistance distance: Double) -> Double {
        let range = maxRange()
        if distance > range * 1.5 {
            return 0.2 // Very low chance
        } else if distance > range {
            return 0.5 // Medium chance
        } else {
            return 0.9 // High chance
        }
    }
    
    /// Fuel consumption for mission
    func fuelConsumption(forDistance distance: Double) -> Double {
        let baseFuel = (distance / 10.0) // Base consumption
        let cargoModifier = 1.0 + (Double(cargo) / 200.0) // Cargo increases consumption
        return baseFuel * cargoModifier
    }
    
    /// Evasion chance in battle
    func evasionChance() -> Double {
        let baseEvasion = 0.3
        let speedBonus = Double(speed) / 2000.0 // Maximum +0.25
        let cargoMalus = Double(cargo) / 1000.0 // Maximum -0.1
        return min(0.8, max(0.1, baseEvasion + speedBonus - cargoMalus))
    }
    
    /// Taking damage with armor considered
    func takeDamage(_ rawDamage: Double) -> Double {
        let armorReduction = Double(armor) * 0.5
        let actualDamage = max(1.0, rawDamage - armorReduction)
        health = max(0, health - actualDamage)
        return actualDamage
    }
    
    /// Refuel
    func refuel(amount: Double) {
        fuel = min(maxFuel, fuel + amount)
    }
    
    /// Repair
    func repair(amount: Double) {
        health = min(100, health + amount)
    }
    
    /// Check mission readiness
    func isReadyForMission() -> (ready: Bool, reason: String?) {
        if fuel < 20 {
            return (false, "Insufficient fuel")
        }
        if health < 30 {
            return (false, "Aircraft requires repair")
        }
        return (true, nil)
    }
}

// MARK: - Pilot (Legacy)
//
// IMPORTANT: This is a legacy version of the Pilot class for backward compatibility.
// New code should use struct Pilot from Models/Pilot.swift + PilotViewModel
//
// TODO: Remove this class after completing MVVM migration

/// Aircraft pilot (LEGACY - use Models/Pilot.swift)
class PilotLegacy: ObservableObject {
    @Published var name: String
    @Published var level: Int
    @Published var experience: Int
    @Published var skillPoints: Int
    @Published var battleRating: Int // Battle Rating - pilot proficiency indicator
    
    // Pilot skills
    @Published var combatSkill: Int // Combat mastery
    @Published var navigationSkill: Int // Navigation
    @Published var efficiencySkill: Int // Efficiency
    
    init(
        name: String = "Captain",
        level: Int = 1,
        experience: Int = 0,
        skillPoints: Int = 0,
        battleRating: Int = 1,
        combatSkill: Int = 0,
        navigationSkill: Int = 0,
        efficiencySkill: Int = 0
    ) {
        self.name = name
        self.level = level
        self.experience = experience
        self.skillPoints = skillPoints
        self.battleRating = battleRating
        self.combatSkill = combatSkill
        self.navigationSkill = navigationSkill
        self.efficiencySkill = efficiencySkill
    }
    
    // MARK: - Methods
    
    /// Experience to next level
    func experienceToNextLevel() -> Int {
        return level * 100
    }
    
    /// Progress to next level
    func experienceProgress() -> Double {
        return Double(experience) / Double(experienceToNextLevel())
    }
    
    /// Add experience
    func addExperience(_ amount: Int) {
        experience += amount
        checkLevelUp()
    }
    
    /// Check level up
    private func checkLevelUp() {
        while experience >= experienceToNextLevel() {
            experience -= experienceToNextLevel()
            level += 1
            skillPoints += 2
            // Increase BR on level up
            battleRating += 1
        }
    }
    
    /// Effectiveness multiplier
    func effectivenessMultiplier() -> Double {
        let baseMultiplier = 1.0
        let levelBonus = Double(level - 1) * 0.05 // +5% per level
        let skillBonus = Double(combatSkill + navigationSkill + efficiencySkill) * 0.02
        return baseMultiplier + levelBonus + skillBonus
    }
    
    /// Critical success bonus
    func criticalChance() -> Double {
        let baseChance = 0.05
        let levelBonus = Double(level) * 0.01
        let combatBonus = Double(combatSkill) * 0.02
        return min(0.5, baseChance + levelBonus + combatBonus)
    }
    
    /// Navigation bonus (fuel consumption reduction)
    func navigationBonus() -> Double {
        return 1.0 - (Double(navigationSkill) * 0.03) // Up to -30% consumption
    }
    
    /// Efficiency bonus (income increase)
    func efficiencyBonus() -> Double {
        return 1.0 + (Double(efficiencySkill) * 0.04) // Up to +40% income
    }
    
    /// Upgrade skill
    func upgradeSkill(_ skill: PilotSkill) -> Bool {
        guard skillPoints > 0 else { return false }
        
        switch skill {
        case .combat:
            if combatSkill < 10 {
                combatSkill += 1
                skillPoints -= 1
                return true
            }
        case .navigation:
            if navigationSkill < 10 {
                navigationSkill += 1
                skillPoints -= 1
                return true
            }
        case .efficiency:
            if efficiencySkill < 10 {
                efficiencySkill += 1
                skillPoints -= 1
                return true
            }
        }
        return false
    }
}

// MARK: - Legacy Compatibility

/// Alias for backward compatibility
/// TODO: Remove after migrating all code to struct Pilot + PilotViewModel
typealias Pilot = PilotLegacy

// MARK: - Pilot Skill

enum PilotSkill {
    case combat
    case navigation
    case efficiency
    
    var title: String {
        switch self {
        case .combat: return "Combat"
        case .navigation: return "Navigation"
        case .efficiency: return "Efficiency"
        }
    }
    
    var icon: String {
        switch self {
        case .combat: return "scope"
        case .navigation: return "location.fill"
        case .efficiency: return "chart.line.uptrend.xyaxis"
        }
    }
    
    var description: String {
        switch self {
        case .combat: return "Increases damage and critical success chance"
        case .navigation: return "Reduces fuel consumption"
        case .efficiency: return "Increases mission income"
        }
    }
}

// MARK: - Game State

/// Overall game state
// MARK: - Game State (Main game model)
//
// ObservableObject with nested ObservableObjects (aircraft, pilot, economy)
// IMPORTANT: Changes in nested objects are automatically propagated
// through objectWillChange.send() for synchronizing all Views

class GameState: ObservableObject {
    @Published var aircraftVM: AircraftViewModel
    @Published var pilot: Pilot
    @Published var economy: EconomyManager
    @Published var altitude: Double
    @Published var missionHistory: MissionHistoryViewModel
    
    // Save subscriptions for tracking nested object changes
    private var cancellables = Set<AnyCancellable>()
    
    // Deprecated field for backward compatibility
    var money: Int {
        get { economy.credits }
        set { economy.credits = newValue }
    }
    
    // Proxy for aircraft access through ViewModel
    var aircraft: Aircraft {
        get { aircraftVM.aircraft }
        set { aircraftVM.aircraft = newValue }
    }
    
    init(
        aircraftVM: AircraftViewModel = AircraftViewModel(),
        pilot: Pilot = Pilot(),
        economy: EconomyManager = EconomyManager(),
        altitude: Double = 5000,
        missionHistory: MissionHistoryViewModel = MissionHistoryViewModel()
    ) {
        self.aircraftVM = aircraftVM
        self.pilot = pilot
        self.economy = economy
        self.altitude = altitude
        self.missionHistory = missionHistory
        
        // Subscribe to nested ObservableObject changes
        // When they change, GameState also publishes changes
        aircraftVM.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
            self?.saveGame() // Auto-save on aircraft change
        }.store(in: &cancellables)
        
        pilot.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
            self?.saveGame() // Auto-save on pilot change
        }.store(in: &cancellables)
        
        economy.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
            self?.saveGame() // Auto-save on economy change
        }.store(in: &cancellables)
        
        missionHistory.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        // Load saved progress
        _ = loadGame()
    }
    
    // MARK: - Mission Methods
    
    /// Calculate final mission reward
    func calculateMissionReward(baseReward: Int) -> Int {
        let cargoBonus = 1.0 + (Double(aircraft.cargo) / 500.0)
        let pilotBonus = pilot.efficiencyBonus()
        return Int(Double(baseReward) * cargoBonus * pilotBonus)
    }
    
    /// Calculate fuel cost for mission
    func calculateFuelCost(distance: Double) -> Double {
        let baseCost = aircraft.fuelConsumption(forDistance: distance)
        let pilotReduction = pilot.navigationBonus()
        return baseCost * pilotReduction
    }
    
    /// Calculate damage in combat
    func calculateDamage(multiplier: Double = 1.0) -> Double {
        let baseDamage = Double(aircraft.firepower) * 10.0
        let pilotMultiplier = pilot.effectivenessMultiplier()
        let criticalRoll = Double.random(in: 0...1)
        let isCritical = criticalRoll < pilot.criticalChance()
        
        return baseDamage * pilotMultiplier * multiplier * (isCritical ? 2.0 : 1.0)
    }
    
    /// Execute mission (simplified logic)
    func executeMission(distance: Double, baseReward: Int, difficulty: Double = 1.0) -> MissionResult {
        // Readiness check
        let readiness = aircraftVM.isReadyForMission()
        guard readiness.ready else {
            return MissionResult(
                success: false,
                reward: 0,
                fuelUsed: 0,
                damageReceived: 0,
                experienceGained: 0,
                message: readiness.reason ?? "Mission impossible"
            )
        }
        
        // Fuel cost (in percent)
        let fuelCostPercent = calculateFuelCost(distance: distance)
        
        // Convert to fuel units (1% = 1 unit)
        let fuelUnitsNeeded = Int(ceil(fuelCostPercent))
        
        // Check fuel availability in economy
        guard economy.fuelUnits >= fuelUnitsNeeded else {
            return MissionResult(
                success: false,
                reward: 0,
                fuelUsed: 0,
                damageReceived: 0,
                experienceGained: 0,
                message: "Insufficient fuel (need \(fuelUnitsNeeded) units)"
            )
        }
        
        // Deduct fuel
        _ = economy.useFuel(fuelUnitsNeeded)
        aircraftVM.consumeFuel(fuelCostPercent)
        
        // Success chance
        let successChance = aircraft.successChance(forDistance: distance)
        let success = Double.random(in: 0...1) < successChance
        
        if !success {
            let damage = 10.0 * difficulty
            let actualDamage = aircraftVM.takeDamage(damage)
            return MissionResult(
                success: false,
                reward: 0,
                fuelUsed: fuelCostPercent,
                damageReceived: actualDamage,
                experienceGained: 20,
                message: "Mission failed"
            )
        }
        
        // Combat (if any)
        var damageReceived = 0.0
        if difficulty > 1.0 {
            let evasionSuccess = Double.random(in: 0...1) < aircraft.evasionChance
            if !evasionSuccess {
                let rawDamage = 15.0 * difficulty
                damageReceived = aircraftVM.takeDamage(rawDamage)
            }
        }
        
        // Reward in credits
        let reward = calculateMissionReward(baseReward: baseReward)
        economy.addCredits(reward)
        
        // Chance to get parts
        if Double.random(in: 0...1) < 0.3 {
            let partsFound = Int.random(in: 1...3)
            economy.addParts(partsFound)
        }
        
        // Experience
        let experience = Int(50.0 * difficulty)
        pilot.addExperience(experience)
        
        return MissionResult(
            success: true,
            reward: reward,
            fuelUsed: fuelCostPercent,
            damageReceived: damageReceived,
            experienceGained: experience,
            message: "Mission completed successfully!"
        )
    }
    
    /// Execute mission based on template
    func executeMissionFromTemplate(template: MissionTemplate, choiceIndex: Int? = nil) -> MissionResult {
        // Readiness check
        let readiness = aircraftVM.isReadyForMission()
        guard readiness.ready else {
            return MissionResult(
                success: false,
                reward: 0,
                fuelUsed: 0,
                damageReceived: 0,
                experienceGained: 0,
                message: readiness.reason ?? "Mission impossible"
            )
        }
        
        // Check mission requirements
        let canStart = MissionTemplatesLibrary.canStartMission(
            template: template,
            battleRating: pilot.battleRating,
            modules: aircraft.installedModules
        )
        guard canStart.canStart else {
            return MissionResult(
                success: false,
                reward: 0,
                fuelUsed: 0,
                damageReceived: 0,
                experienceGained: 0,
                message: canStart.reason ?? "Requirements not met"
            )
        }
        
        // Base difficulty with modifiers
        let totalDifficulty = template.baseDifficulty * template.modifier.difficultyModifier
        
        // Reward modifier from choice
        var rewardMultiplier = 1.0
        var riskModifier = 0.0
        if let index = choiceIndex, let choices = template.choices {
            rewardMultiplier = choices[index].rewardMultiplier
            riskModifier = choices[index].riskLevel
        }
        
        // Fuel cost (base - 20-40% depending on difficulty)
        let baseFuelCost = 20.0 + (totalDifficulty * 10.0)
        let fuelCostPercent = baseFuelCost * pilot.navigationBonus()
        let fuelUnitsNeeded = Int(ceil(fuelCostPercent))
        
        // Check fuel availability
        guard economy.fuelUnits >= fuelUnitsNeeded else {
            return MissionResult(
                success: false,
                reward: 0,
                fuelUsed: 0,
                damageReceived: 0,
                experienceGained: 0,
                message: "Insufficient fuel (need \(fuelUnitsNeeded) units)"
            )
        }
        
        // Deduct fuel
        _ = economy.useFuel(fuelUnitsNeeded)
        aircraftVM.consumeFuel(fuelCostPercent)
        
        // Success chance
        let baseSuccessChance = max(0.3, 1.0 - (totalDifficulty / 5.0))
        let pilotCombatBonus = Double(pilot.combatSkill) * 0.02
        let brBonus = Double(pilot.battleRating) / 200.0
        var finalSuccessChance = baseSuccessChance + pilotCombatBonus + brBonus - riskModifier
        finalSuccessChance = max(0.1, min(0.95, finalSuccessChance))
        
        let success = Double.random(in: 0...1) < finalSuccessChance
        
        if !success {
            let damage = 15.0 * totalDifficulty
            let actualDamage = aircraftVM.takeDamage(damage)
            
            // Experience even for failure (less)
            let failExperience = Int(30.0 * totalDifficulty)
            
            // Remember level before adding experience
            let oldLevel = pilot.level
            let oldSkillPoints = pilot.skillPoints
            
            // Add experience even for failure
            pilot.addExperience(failExperience)
            
            // Check level up
            let leveledUp = pilot.level > oldLevel
            let newLevel = leveledUp ? pilot.level : nil
            let skillPointsGained = pilot.skillPoints - oldSkillPoints
            
            // Create mission result
            let result = MissionResult(
                success: false,
                reward: 0,
                fuelUsed: fuelCostPercent,
                damageReceived: damage,
                experienceGained: failExperience,
                message: "Mission failed",
                leveledUp: leveledUp,
                newLevel: newLevel,
                skillPointsGained: skillPointsGained
            )
            
            // Save failure to history
            let distance = Int(100.0 * totalDifficulty)
            let flightTime = Int(60.0 * totalDifficulty)
            missionHistory.addMission(
                template: template,
                result: result,
                distance: distance,
                flightTime: flightTime
            )
            
            return result
        }
        
        // Combat (taking damage)
        var damageReceived = 0.0
        if totalDifficulty > 1.0 {
            let evasionSuccess = Double.random(in: 0...1) < aircraft.evasionChance
            if !evasionSuccess {
                let rawDamage = 10.0 * totalDifficulty * (1.0 + riskModifier)
                damageReceived = aircraftVM.takeDamage(rawDamage)
            }
        }
        
        // Reward
        let baseReward = Double(template.baseReward) * template.modifier.difficultyModifier * rewardMultiplier
        let cargoBonus = 1.0 + (Double(aircraft.cargo) / 500.0)
        let pilotEfficiencyBonus = pilot.efficiencyBonus()
        let reward = Int(baseReward * cargoBonus * pilotEfficiencyBonus)
        economy.addCredits(reward)
        
        // Chance to get parts (higher for difficult missions)
        let partsChance = min(0.6, 0.2 + (totalDifficulty * 0.15))
        if Double.random(in: 0...1) < partsChance {
            let partsFound = Int.random(in: 1...Int(max(3, totalDifficulty * 2)))
            economy.addParts(partsFound)
        }
        
        // Experience and level up
        let experience = Int(60.0 * totalDifficulty * (1.0 + riskModifier))
        
        // Remember level before adding experience
        let oldLevel = pilot.level
        let oldSkillPoints = pilot.skillPoints
        
        // Add experience
        pilot.addExperience(experience)
        
        // Check level up
        let leveledUp = pilot.level > oldLevel
        let newLevel = leveledUp ? pilot.level : nil
        let skillPointsGained = pilot.skillPoints - oldSkillPoints
        
        // Bonus skill points for especially difficult missions (3.0+)
        var bonusSkillPoints = 0
        if totalDifficulty >= 3.0 {
            bonusSkillPoints = 1
            pilot.skillPoints += bonusSkillPoints
        }
        
        let totalSkillPointsGained = skillPointsGained + bonusSkillPoints
        
        // Create mission result
        let result = MissionResult(
            success: true,
            reward: reward,
            fuelUsed: fuelCostPercent,
            damageReceived: damageReceived,
            experienceGained: experience,
            message: "Mission completed successfully!",
            leveledUp: leveledUp,
            newLevel: newLevel,
            skillPointsGained: totalSkillPointsGained
        )
        
        // Save to history
        let distance = Int(100.0 * totalDifficulty) // Pseudo-distance based on difficulty
        let flightTime = Int(60.0 * totalDifficulty) // Pseudo-time based on difficulty
        missionHistory.addMission(
            template: template,
            result: result,
            distance: distance,
            flightTime: flightTime
        )
        
        return result
    }
    
    // MARK: - Save/Load Game
    
    private let saveKey = "game_save_data"
    
    /// Save game progress
    func saveGame() {
        let saveData = GameSaveData(
            aircraft: aircraftVM.aircraft,
            pilot: pilot,
            economy: economy,
            altitude: altitude
        )
        
        if let encoded = try? JSONEncoder().encode(saveData) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
            print("✅ Game saved: \(saveData.savedAt)")
        } else {
            print("❌ Error saving game")
        }
    }
    
    /// Load game progress
    func loadGame() -> Bool {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let saveData = try? JSONDecoder().decode(GameSaveData.self, from: data) else {
            print("⚠️ Save not found, starting new game")
            return false
        }
        
        // Load Aircraft
        aircraftVM.aircraft = saveData.aircraft
        
        // Load Pilot
        pilot.name = saveData.pilotName
        pilot.level = saveData.pilotLevel
        pilot.experience = saveData.pilotExperience
        pilot.skillPoints = saveData.pilotSkillPoints
        pilot.battleRating = saveData.pilotBattleRating
        pilot.combatSkill = saveData.pilotCombatSkill
        pilot.navigationSkill = saveData.pilotNavigationSkill
        pilot.efficiencySkill = saveData.pilotEfficiencySkill
        
        // Load Economy
        economy.credits = saveData.credits
        economy.fuelUnits = saveData.fuelUnits
        economy.parts = saveData.parts
        economy.repairKits = saveData.repairKits.compactMap { $0.toRepairKit() }
        economy.setLastFuelRefill(saveData.lastFuelRefill)
        
        // Load Altitude
        altitude = saveData.altitude
        
        print("✅ Game loaded: save from \(saveData.savedAt)")
        return true
    }
    
    /// Delete save (for debugging)
    func deleteSave() {
        UserDefaults.standard.removeObject(forKey: saveKey)
        print("🗑️ Save deleted")
    }
}

// MARK: - MVVM Compatibility Type Aliases

/// Allows using new MVVM names with existing classes
/// Facilitates gradual code refactoring

// New name for AircraftStats (already an ObservableObject class)
// typealias AircraftViewModel = AircraftStats (commented out - avoiding name conflicts)

// New name for GameState (already an ObservableObject class)
// typealias GameViewModel = GameState (commented out - avoiding name conflicts)

// Note: Files in Models/ and ViewModels/ contain pure data structures
// that will be used in future refactorings.
// Currently using a monolithic approach in AircraftStats.swift

