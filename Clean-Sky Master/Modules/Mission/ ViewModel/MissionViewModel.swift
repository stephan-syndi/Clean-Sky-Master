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
// АКТИВНЫЙ MVVM VIEW MODEL
//
// Управляет доступными миссиями для выполнения:
// - Генерация доступных миссий на основе Battle Rating
// - Управление выбранной миссией
// - Проверка возможности запуска миссии
// - Фильтрация доступных миссий
//
// ИСТОРИЯ МИССИЙ теперь управляется через MissionHistoryViewModel в GameState
//
// Использует модели данных:
// - MissionTemplate из MissionTemplates.swift
// - MissionResult из Mission.swift

/// ViewModel для управления доступными миссиями
class MissionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Доступные миссии для выполнения
    @Published var availableMissions: [MissionTemplate] = []
    
    /// Текущая выбранная миссия
    @Published var selectedMission: MissionTemplate?
    
    /// Последний результат выполнения миссии
    @Published var lastResult: MissionResult?
    
    /// Выбранный индекс решения в миссии с выбором
    @Published var selectedChoiceIndex: Int?
    
    // MARK: - Initialization
    
    init() {
        // MissionViewModel теперь отвечает только за доступные миссии
        // История миссий управляется через MissionHistoryViewModel в GameState
    }
    
    // MARK: - Mission Generation
    
    /// Генерирует новые доступные миссии на основе Battle Rating
    /// - Parameters:
    ///   - battleRating: Текущий Battle Rating самолёта
    ///   - count: Количество миссий для генерации (по умолчанию 3-5)
    func generateMissions(battleRating: Int, count: Int = Int.random(in: 3...5)) {
        availableMissions.removeAll()
        
        // Определяем диапазон сложности
        let minDifficulty = 0.0
        let maxDifficulty = min(3.0, Double(battleRating) / 10.0 + 1.5)
        
        // Генерируем уникальные миссии
        var attempts = 0
        while availableMissions.count < count && attempts < count * 3 {
            let mission = MissionTemplatesLibrary.getRandomMission(
                minDifficulty: minDifficulty,
                maxDifficulty: maxDifficulty,
                battleRating: battleRating
            )
            
            // Избегаем дубликатов
            if !availableMissions.contains(where: { $0.name == mission.name }) {
                availableMissions.append(mission)
            }
            
            attempts += 1
        }
    }
    
    /// Обновляет список доступных миссий (удаляет выполненную, добавляет новую при необходимости)
    /// - Parameters:
    ///   - completedMissionName: Название выполненной миссии
    ///   - battleRating: Battle Rating для генерации новой миссии
    func refreshMissions(completedMissionName: String, battleRating: Int) {
        // Удаляем выполненную миссию
        availableMissions.removeAll { $0.name == completedMissionName }
        
        // Если миссий стало мало, генерируем новые
        if availableMissions.count < 3 {
            generateMissions(battleRating: battleRating, count: 5 - availableMissions.count)
        }
    }
    
    // MARK: - Mission Execution
    
    /// Выполняет миссию через координацию с GameViewModel
    /// - Parameters:
    ///   - template: Шаблон миссии
    ///   - choiceIndex: Индекс выбора игрока (если миссия имеет выборы)
    ///   - gameVM: GameViewModel для доступа к aircraft/pilot/economy
    /// - Returns: Результат выполнения миссии
    func executeMission(
        template: MissionTemplate,
        choiceIndex: Int? = nil,
        gameVM: GameViewModel
    ) -> MissionResult {
        // Сохраняем выбор
        self.selectedChoiceIndex = choiceIndex
        
        // Проверка готовности самолёта
        let readiness = gameVM.aircraft.isReadyForMission()
        guard readiness.ready else {
            let result = MissionResult(
                success: false,
                reward: 0,
                fuelUsed: 0,
                damageReceived: 0,
                experienceGained: 0,
                message: readiness.reason ?? "Миссия невозможна"
            )
            lastResult = result
            return result
        }
        
        // Проверка требований миссии
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
                message: canStart.reason ?? "Требования не выполнены"
            )
            lastResult = result
            return result
        }
        
        // Базовая сложность с модификаторами
        let totalDifficulty = template.baseDifficulty * template.modifier.difficultyModifier
        
        // Модификатор награды от выбора
        var rewardMultiplier = 1.0
        var riskModifier = 0.0
        if let index = choiceIndex, let choices = template.choices {
            rewardMultiplier = choices[index].rewardMultiplier
            riskModifier = choices[index].riskLevel
        }
        
        // Расход топлива (базовый - 20-40% в зависимости от сложности)
        let baseFuelCost = 20.0 + (totalDifficulty * 10.0)
        let fuelCostPercent = baseFuelCost * gameVM.pilot.navigationBonus()
        let fuelUnitsNeeded = Int(ceil(fuelCostPercent))
        
        // Проверяем наличие топлива
        guard gameVM.economy.fuelUnits >= fuelUnitsNeeded else {
            let result = MissionResult(
                success: false,
                reward: 0,
                fuelUsed: 0,
                damageReceived: 0,
                experienceGained: 0,
                message: "Недостаточно топлива (нужно \(fuelUnitsNeeded) ед.)"
            )
            lastResult = result
            return result
        }
        
        // Списываем топливо
        gameVM.economyVM.useFuel(fuelUnitsNeeded)
        gameVM.aircraftVM.consumeFuel(fuelCostPercent)
        
        // Шанс успеха
        let baseSuccessChance = max(0.3, 1.0 - (totalDifficulty / 5.0))
        let pilotCombatBonus = Double(gameVM.pilot.combatSkill) * 0.02
        let brBonus = Double(gameVM.pilot.battleRating) / 200.0
        var finalSuccessChance = baseSuccessChance + pilotCombatBonus + brBonus - riskModifier
        finalSuccessChance = max(0.1, min(0.95, finalSuccessChance))
        
        let success = Double.random(in: 0...1) < finalSuccessChance
        
        // Провал миссии
        if !success {
            let damage = 15.0 * totalDifficulty
            let _ = gameVM.aircraftVM.takeDamage(damage)
            
            // Опыт даже за провал (меньше)
            let failExperience = Int(30.0 * totalDifficulty)
            
            // Запоминаем уровень до добавления опыта
            let oldLevel = gameVM.pilot.level
            let oldSkillPoints = gameVM.pilot.skillPoints
            
            // Добавляем опыт даже за провал
            gameVM.pilotVM.addExperience(failExperience)
            
            // Проверяем повышение уровня
            let leveledUp = gameVM.pilot.level > oldLevel
            let newLevel = leveledUp ? gameVM.pilot.level : nil
            let skillPointsGained = gameVM.pilot.skillPoints - oldSkillPoints
            
            let result = MissionResult(
                success: false,
                reward: 0,
                fuelUsed: fuelCostPercent,
                damageReceived: damage,
                experienceGained: failExperience,
                message: "Миссия провалена",
                leveledUp: leveledUp,
                newLevel: newLevel,
                skillPointsGained: skillPointsGained
            )
            lastResult = result
            
            return result
        }
        
        // Успешная миссия - проверка урона в бою
        var damageReceived = 0.0
        if totalDifficulty > 1.0 {
            let evasionSuccess = Double.random(in: 0...1) < gameVM.aircraft.evasionChance
            if !evasionSuccess {
                let rawDamage = 10.0 * totalDifficulty * (1.0 + riskModifier)
                damageReceived = gameVM.aircraftVM.takeDamage(rawDamage)
            }
        }
        
        // Награда
        let baseReward = Double(template.baseReward) * template.modifier.difficultyModifier * rewardMultiplier
        let cargoBonus = 1.0 + (Double(gameVM.aircraft.cargo) / 500.0)
        let pilotEfficiencyBonus = gameVM.pilot.efficiencyBonus()
        let reward = Int(baseReward * cargoBonus * pilotEfficiencyBonus)
        gameVM.economyVM.addCredits(reward)
        
        // Шанс получить запчасти (выше для сложных миссий)
        let partsChance = min(0.6, 0.2 + (totalDifficulty * 0.15))
        if Double.random(in: 0...1) < partsChance {
            let partsFound = Int.random(in: 1...Int(max(3, totalDifficulty * 2)))
            gameVM.economyVM.addParts(partsFound)
        }
        
        // Опыт и повышение уровня
        let experience = Int(60.0 * totalDifficulty * (1.0 + riskModifier))
        
        // Запоминаем уровень до добавления опыта
        let oldLevel = gameVM.pilot.level
        let oldSkillPoints = gameVM.pilot.skillPoints
        
        // Добавляем опыт
        gameVM.pilotVM.addExperience(experience)
        
        // Проверяем повышение уровня
        let leveledUp = gameVM.pilot.level > oldLevel
        let newLevel = leveledUp ? gameVM.pilot.level : nil
        let skillPointsGained = gameVM.pilot.skillPoints - oldSkillPoints
        
        // Дополнительные skill points за особо сложные миссии (3.0+)
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
            message: "Миссия выполнена успешно!",
            leveledUp: leveledUp,
            newLevel: newLevel,
            skillPointsGained: totalSkillPointsGained
        )
        lastResult = result
        
        return result
    }
    
    // MARK: - Mission Selection
    
    /// Выбирает миссию для выполнения
    /// - Parameter mission: Шаблон миссии
    func selectMission(_ mission: MissionTemplate) {
        selectedMission = mission
        selectedChoiceIndex = nil
    }
    
    /// Очищает выбранную миссию
    func clearSelection() {
        selectedMission = nil
        selectedChoiceIndex = nil
        lastResult = nil
    }
    
    /// Проверяет, может ли миссия быть начата
    /// - Parameters:
    ///   - template: Шаблон миссии
    ///   - battleRating: Battle Rating самолёта
    ///   - modules: Установленные модули
    /// - Returns: Кортеж (можно начать, причина если нельзя)
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
