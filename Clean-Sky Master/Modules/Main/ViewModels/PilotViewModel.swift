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
// АКТИВНЫЙ MVVM VIEW MODEL
// Использует struct PilotData из Models/Pilot.swift

/// ViewModel для управления пилотом
class PilotViewModel: ObservableObject {
    @Published var pilot: PilotData
    
    init(pilot: PilotData = PilotData()) {
        self.pilot = pilot
    }
    
    // MARK: - Actions
    
    /// Добавление опыта
    func addExperience(_ amount: Int) {
        pilot.experience += amount
        checkLevelUp()
    }
    
    /// Проверка повышения уровня
    private func checkLevelUp() {
        while pilot.experience >= pilot.experienceForNextLevel {
            pilot.experience -= pilot.experienceForNextLevel
            pilot.level += 1
            pilot.skillPoints += 1
            // Повышаем BR при повышении уровня
            pilot.battleRating += 1
        }
    }
    
    /// Улучшение навыка боя
    func upgradeCombatSkill() -> Bool {
        guard pilot.skillPoints > 0 else { return false }
        pilot.combatSkill += 1
        pilot.skillPoints -= 1
        updateBattleRatingFromSkills()
        return true
    }
    
    /// Улучшение навыка навигации
    func upgradeNavigationSkill() -> Bool {
        guard pilot.skillPoints > 0 else { return false }
        pilot.navigationSkill += 1
        pilot.skillPoints -= 1
        updateBattleRatingFromSkills()
        return true
    }
    
    /// Улучшение навыка эффективности
    func upgradeEfficiencySkill() -> Bool {
        guard pilot.skillPoints > 0 else { return false }
        pilot.efficiencySkill += 1
        pilot.skillPoints -= 1
        updateBattleRatingFromSkills()
        return true
    }
    
    /// Обновление BR на основе прокачанных навыков
    /// Каждые 3 очка навыков = +1 BR
    private func updateBattleRatingFromSkills() {
        let totalSkills = pilot.combatSkill + pilot.navigationSkill + pilot.efficiencySkill
        let skillBR = totalSkills / 3
        let levelBR = pilot.level
        pilot.battleRating = max(1, levelBR + skillBR)
    }
    
    /// Повысить BR за выполнение сложной миссии
    func increaseBattleRating(by amount: Int = 1) {
        pilot.battleRating += amount
    }
    
    /// Изменение имени
    func rename(_ newName: String) {
        pilot.name = newName
    }
}
