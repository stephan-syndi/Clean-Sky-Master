//
//  Pilot.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import Foundation

// MARK: - Pilot (Model)
//
// ACTIVE MVVM MODEL
// Used with PilotViewModel from ViewModels/
//
// Note: PilotData name is used to avoid conflict
// with legacy class Pilot (PilotLegacy) from AircraftStats.swift

/// Pilot model - pure data without logic
struct PilotData {
    var name: String
    var level: Int
    var experience: Int
    var skillPoints: Int
    var battleRating: Int // Battle Rating - pilot mastery indicator
    
    // Pilot skills
    var combatSkill: Int // Combat mastery
    var navigationSkill: Int // Navigation
    var efficiencySkill: Int // Efficiency
    
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
    
    // MARK: - Computed Properties
    
    /// Experience for next level
    var experienceForNextLevel: Int {
        return level * 100
    }
    
    /// Progress to next level (0.0 - 1.0)
    var levelProgress: Double {
        return Double(experience) / Double(experienceForNextLevel)
    }
    
    // MARK: - Skill Bonuses
    
    /// Damage bonus from combat skill
    func combatBonus() -> Double {
        return 1.0 + (Double(combatSkill) * 0.05)
    }
    
    /// Fuel consumption reduction from navigation
    func navigationBonus() -> Double {
        return max(0.5, 1.0 - (Double(navigationSkill) * 0.03))
    }
    
    /// Income increase from efficiency
    func efficiencyBonus() -> Double {
        return 1.0 + (Double(efficiencySkill) * 0.04)
    }
    
    /// Overall  effectiveness multiplier
    func effectivenessMultiplier() -> Double {
        let levelBonus = 1.0 + (Double(level) * 0.02)
        let skillBonus = combatBonus()
        return levelBonus * skillBonus
    }
    
    /// Critical hit chance
    func criticalChance() -> Double {
        return min(0.5, 0.1 + (Double(combatSkill) * 0.02))
    }
    
    // MARK: - Battle Rating
    
    /// Battle Rating calculation based on level and skills
    /// BR increases with pilot level and skill upgrades
    mutating func calculateBattleRating() {
        let levelBR = level // 1 BR per level
        let skillBR = (combatSkill + navigationSkill + efficiencySkill) / 3 // Average skill
        battleRating = max(1, levelBR + skillBR)
    }
    
    /// Increase BR after completing a difficult mission
    mutating func increaseBattleRating(by amount: Int = 1) {
        battleRating += amount
    }
}
