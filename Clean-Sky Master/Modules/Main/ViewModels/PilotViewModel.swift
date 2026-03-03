//
//  PilotViewModel.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import Foundation
import Combine

// MARK: - Pilot View Model
//
// ACTIVE MVVM VIEW MODEL
// Uses struct PilotData from Models/Pilot.swift

/// ViewModel for pilot management
class PilotViewModel: ObservableObject {
    @Published var pilot: PilotData
    
    init(pilot: PilotData = PilotData()) {
        self.pilot = pilot
    }
    
    // MARK: - Actions
    
    /// Add experience
    func addExperience(_ amount: Int) {
        pilot.experience += amount
        checkLevelUp()
    }
    
    /// Check level up
    private func checkLevelUp() {
        while pilot.experience >= pilot.experienceForNextLevel {
            pilot.experience -= pilot.experienceForNextLevel
            pilot.level += 1
            pilot.skillPoints += 1
            // Increase BR on level up
            pilot.battleRating += 1
        }
    }
    
    /// Upgrade combat skill
    func upgradeCombatSkill() -> Bool {
        guard pilot.skillPoints > 0 else { return false }
        pilot.combatSkill += 1
        pilot.skillPoints -= 1
        updateBattleRatingFromSkills()
        return true
    }
    
    /// Upgrade navigation skill
    func upgradeNavigationSkill() -> Bool {
        guard pilot.skillPoints > 0 else { return false }
        pilot.navigationSkill += 1
        pilot.skillPoints -= 1
        updateBattleRatingFromSkills()
        return true
    }
    
    /// Upgrade efficiency skill
    func upgradeEfficiencySkill() -> Bool {
        guard pilot.skillPoints > 0 else { return false }
        pilot.efficiencySkill += 1
        pilot.skillPoints -= 1
        updateBattleRatingFromSkills()
        return true
    }
    
    /// Update BR based on upgraded skills
    /// Every 3 skill points = +1 BR
    private func updateBattleRatingFromSkills() {
        let totalSkills = pilot.combatSkill + pilot.navigationSkill + pilot.efficiencySkill
        let skillBR = totalSkills / 3
        let levelBR = pilot.level
        pilot.battleRating = max(1, levelBR + skillBR)
    }
    
    /// Increase BR for completing difficult mission
    func increaseBattleRating(by amount: Int = 1) {
        pilot.battleRating += amount
    }
    
    /// Change name
    func rename(_ newName: String) {
        pilot.name = newName
    }
}
