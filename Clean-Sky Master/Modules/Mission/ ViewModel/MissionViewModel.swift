//
//  MissionViewModel.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 2.03.26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Mission View Model
//
// ACTIVE MVVM VIEW MODEL
//
// Manages available missions for execution:
// - Generation of available missions based on Battle Rating
// - Management of selected mission
// - Check if mission can be started
// - Filtering available missions
//
// MISSION HISTORY is now managed through MissionHistoryViewModel in GameState
//
// Uses data models:
// - MissionTemplate from MissionTemplates.swift
// - MissionResult from Mission.swift

/// ViewModel for managing available missions
class MissionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Available missions for execution
    @Published var availableMissions: [MissionTemplate] = []
    
    /// Currently selected mission
    @Published var selectedMission: MissionTemplate?
    
    /// Last mission execution result
    @Published var lastResult: MissionResult?
    
    /// Selected choice index in mission with choices
    @Published var selectedChoiceIndex: Int?
    
    // MARK: - Initialization
    
    init() {
        // MissionViewModel now handles only available missions
        // Mission history is managed through MissionHistoryViewModel in GameState
    }
    
    // MARK: - Mission Generation
    
    /// Generates new available missions based on Battle Rating
    /// - Parameters:
    ///   - battleRating: Current aircraft Battle Rating
    ///   - count: Number of missions to generate (default 3-5)
    func generateMissions(battleRating: Int, count: Int = Int.random(in: 3...5)) {
        availableMissions.removeAll()
        
        // Define difficulty range
        let minDifficulty = 0.0
        let maxDifficulty = min(3.0, Double(battleRating) / 10.0 + 1.5)
        
        // Generate unique missions
        var attempts = 0
        while availableMissions.count < count && attempts < count * 3 {
            let mission = MissionTemplatesLibrary.getRandomMission(
                minDifficulty: minDifficulty,
                maxDifficulty: maxDifficulty,
                battleRating: battleRating
            )
            
            // Avoid duplicates
            if !availableMissions.contains(where: { $0.name == mission.name }) {
                availableMissions.append(mission)
            }
            
            attempts += 1
        }
    }
    
    /// Updates list of available missions (removes completed, adds new if needed)
    /// - Parameters:
    ///   - completedMissionName: Name of completed mission
    ///   - battleRating: Battle Rating for generating new mission
    func refreshMissions(completedMissionName: String, battleRating: Int) {
        // Remove completed mission
        availableMissions.removeAll { $0.name == completedMissionName }
        
        // If missions are running low, generate new ones
        if availableMissions.count < 3 {
            generateMissions(battleRating: battleRating, count: 5 - availableMissions.count)
        }
    }
    
    // MARK: - Mission Execution
    
    /// Executes mission through coordination with GameViewModel
    /// - Parameters:
    ///   - template: Mission template
    ///   - choiceIndex: Player's choice index (if mission has choices)
    ///   - gameVM: GameViewModel for accessing aircraft/pilot/economy
    /// - Returns: Mission execution result
    func executeMission(
        template: MissionTemplate,
        choiceIndex: Int? = nil,
        gameVM: GameViewModel
    ) -> MissionResult {
        // Save choice
        self.selectedChoiceIndex = choiceIndex
        
        // Check aircraft readiness
        let readiness = gameVM.aircraft.isReadyForMission()
        guard readiness.ready else {
            let result = MissionResult(
                success: false,
                reward: 0,
                fuelUsed: 0,
                damageReceived: 0,
                experienceGained: 0,
                message: readiness.reason ?? "Mission impossible"
            )
            lastResult = result
            return result
        }
        
        // Check mission requirements
        let canStart = MissionTemplatesLibrary.canStartMission(
            template: template,
            battleRating: gameVM.pilot.battleRating,
            modules: gameVM.aircraft.installedModules
        )
        guard canStart.canStart else {
            let result = MissionResult(
                success: false,
                reward: 0,
                fuelUsed: 0,
                damageReceived: 0,
                experienceGained: 0,
                message: canStart.reason ?? "Requirements not met"
            )
            lastResult = result
            return result
        }
        
        // Base difficulty with modifiers
        let totalDifficulty = template.baseDifficulty * template.modifier.difficultyModifier
        
        // Reward multiplier from choice
        var rewardMultiplier = 1.0
        var riskModifier = 0.0
        if let index = choiceIndex, let choices = template.choices {
            rewardMultiplier = choices[index].rewardMultiplier
            riskModifier = choices[index].riskLevel
        }
        
        // Fuel cost (base - 20-40% depending on difficulty)
        let baseFuelCost = 20.0 + (totalDifficulty * 10.0)
        let fuelCostPercent = baseFuelCost * gameVM.pilot.navigationBonus()
        let fuelUnitsNeeded = Int(ceil(fuelCostPercent))
        
        // Check fuel availability
        guard gameVM.economy.fuelUnits >= fuelUnitsNeeded else {
            let result = MissionResult(
                success: false,
                reward: 0,
                fuelUsed: 0,
                damageReceived: 0,
                experienceGained: 0,
                message: "Insufficient fuel (need \(fuelUnitsNeeded) units)"
            )
            lastResult = result
            return result
        }
        
        // Deduct fuel
        gameVM.economyVM.useFuel(fuelUnitsNeeded)
        gameVM.aircraftVM.consumeFuel(fuelCostPercent)
        
        // Success chance
        let baseSuccessChance = max(0.3, 1.0 - (totalDifficulty / 5.0))
        let pilotCombatBonus = Double(gameVM.pilot.combatSkill) * 0.02
        let brBonus = Double(gameVM.pilot.battleRating) / 200.0
        var finalSuccessChance = baseSuccessChance + pilotCombatBonus + brBonus - riskModifier
        finalSuccessChance = max(0.1, min(0.95, finalSuccessChance))
        
        let success = Double.random(in: 0...1) < finalSuccessChance
        
        // Mission failure
        if !success {
            let damage = 15.0 * totalDifficulty
            let _ = gameVM.aircraftVM.takeDamage(damage)
            
            // Experience even on failure (less)
            let failExperience = Int(30.0 * totalDifficulty)
            
            // Remember level before adding experience
            let oldLevel = gameVM.pilot.level
            let oldSkillPoints = gameVM.pilot.skillPoints
            
            // Add experience even on failure
            gameVM.pilotVM.addExperience(failExperience)
            
            // Check level up
            let leveledUp = gameVM.pilot.level > oldLevel
            let newLevel = leveledUp ? gameVM.pilot.level : nil
            let skillPointsGained = gameVM.pilot.skillPoints - oldSkillPoints
            
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
            lastResult = result
            
            return result
        }
        
        // Successful mission - check combat damage
        var damageReceived = 0.0
        if totalDifficulty > 1.0 {
            let evasionSuccess = Double.random(in: 0...1) < gameVM.aircraft.evasionChance
            if !evasionSuccess {
                let rawDamage = 10.0 * totalDifficulty * (1.0 + riskModifier)
                damageReceived = gameVM.aircraftVM.takeDamage(rawDamage)
            }
        }
        
        // Reward
        let baseReward = Double(template.baseReward) * template.modifier.difficultyModifier * rewardMultiplier
        let cargoBonus = 1.0 + (Double(gameVM.aircraft.cargo) / 500.0)
        let pilotEfficiencyBonus = gameVM.pilot.efficiencyBonus()
        let reward = Int(baseReward * cargoBonus * pilotEfficiencyBonus)
        gameVM.economyVM.addCredits(reward)
        
        // Chance to get parts (higher for difficult missions)
        let partsChance = min(0.6, 0.2 + (totalDifficulty * 0.15))
        if Double.random(in: 0...1) < partsChance {
            let partsFound = Int.random(in: 1...Int(max(3, totalDifficulty * 2)))
            gameVM.economyVM.addParts(partsFound)
        }
        
        // Experience and level up
        let experience = Int(60.0 * totalDifficulty * (1.0 + riskModifier))
        
        // Remember level before adding experience
        let oldLevel = gameVM.pilot.level
        let oldSkillPoints = gameVM.pilot.skillPoints
        
        // Add experience
        gameVM.pilotVM.addExperience(experience)
        
        // Check level up
        let leveledUp = gameVM.pilot.level > oldLevel
        let newLevel = leveledUp ? gameVM.pilot.level : nil
        let skillPointsGained = gameVM.pilot.skillPoints - oldSkillPoints
        
        // Bonus skill points for especially difficult missions (3.0+)
        var bonusSkillPoints = 0
        if totalDifficulty >= 3.0 {
            bonusSkillPoints = 1
            gameVM.pilotVM.pilot.skillPoints += bonusSkillPoints
        }
        
        let totalSkillPointsGained = skillPointsGained + bonusSkillPoints
        
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
        lastResult = result
        
        return result
    }
    
    // MARK: - Mission Selection
    
    /// Selects mission for execution
    /// - Parameter mission: Mission template
    func selectMission(_ mission: MissionTemplate) {
        selectedMission = mission
        selectedChoiceIndex = nil
    }
    
    /// Clears selected mission
    func clearSelection() {
        selectedMission = nil
        selectedChoiceIndex = nil
        lastResult = nil
    }
    
    /// Checks if mission can be started
    /// - Parameters:
    ///   - template: Mission template
    ///   - battleRating: Aircraft Battle Rating
    ///   - modules: Installed modules
    /// - Returns: Tuple (can start, reason if not)
    func canStartMission(
        template: MissionTemplate,
        battleRating: Int,
        modules: [String]
    ) -> (canStart: Bool, reason: String?) {
        return MissionTemplatesLibrary.canStartMission(
            template: template,
            battleRating: battleRating,
            modules: modules
        )
    }
}
