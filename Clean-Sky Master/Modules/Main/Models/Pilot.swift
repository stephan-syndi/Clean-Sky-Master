//
//  Pilot.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import Foundation

// MARK: - Pilot (Model)
//
// АКТИВНАЯ MVVM МОДЕЛЬ
// Используется с PilotViewModel из ViewModels/
//
// Примечание: Название PilotData используется чтобы избежать конфликта
// с legacy class Pilot (PilotLegacy) из AircraftStats.swift

/// Модель пилота - чистые данные без логики
struct PilotData {
    var name: String
    var level: Int
    var experience: Int
    var skillPoints: Int
    var battleRating: Int // Battle Rating - показатель мастерства пилота
    
    // Навыки пилота
    var combatSkill: Int // Боевое мастерство
    var navigationSkill: Int // Навигация
    var efficiencySkill: Int // Эффективность
    
    init(
        name: String = "Капитан",
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
    
    /// Опыт для следующего уровня
    var experienceForNextLevel: Int {
        return level * 100
    }
    
    /// Прогресс до следующего уровня (0.0 - 1.0)
    var levelProgress: Double {
        return Double(experience) / Double(experienceForNextLevel)
    }
    
    // MARK: - Skill Bonuses
    
    /// Бонус к урону от боевого навыка
    func combatBonus() -> Double {
        return 1.0 + (Double(combatSkill) * 0.05)
    }
    
    /// Снижение расхода топлива от навигации
    func navigationBonus() -> Double {
        return max(0.5, 1.0 - (Double(navigationSkill) * 0.03))
    }
    
    /// Увеличение дохода от эффективности
    func efficiencyBonus() -> Double {
        return 1.0 + (Double(efficiencySkill) * 0.04)
    }
    
    /// Общий множитель эффективности
    func effectivenessMultiplier() -> Double {
        let levelBonus = 1.0 + (Double(level) * 0.02)
        let skillBonus = combatBonus()
        return levelBonus * skillBonus
    }
    
    /// Шанс критического удара
    func criticalChance() -> Double {
        return min(0.5, 0.1 + (Double(combatSkill) * 0.02))
    }
    
    // MARK: - Battle Rating
    
    /// Расчёт Battle Rating на основе уровня и навыков
    /// BR повышается с уровнем пилота и прокачкой навыков
    mutating func calculateBattleRating() {
        let levelBR = level // 1 BR за уровень
        let skillBR = (combatSkill + navigationSkill + efficiencySkill) / 3 // Средний навык
        battleRating = max(1, levelBR + skillBR)
    }
    
    /// Повысить BR после выполнения сложной миссии
    mutating func increaseBattleRating(by amount: Int = 1) {
        battleRating += amount
    }
}
