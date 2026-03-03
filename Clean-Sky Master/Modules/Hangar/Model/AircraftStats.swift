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
// NOTE: Это legacy версия с классами ObservableObject.
// Новая MVVM архитектура использует struct модели из Models/ и ViewModels из ViewModels/

/// Параметры самолёта
class AircraftStats: ObservableObject {
    @Published var fuel: Double // Топливо (0-100)
    @Published var maxFuel: Double // Максимальная ёмкость
    @Published var armor: Int // Броня
    @Published var firepower: Int // Оружие
    @Published var speed: Int // Скорость
    @Published var cargo: Int // Грузоподъёмность
    @Published var health: Double // Здоровье корпуса (0-100)
    @Published var installedModules: [String] // Установленные модули
    
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
    
    /// Расчёт дальности полёта
    func maxRange() -> Double {
        let baseRange = 1000.0
        let fuelCoefficient = fuel / 100.0
        let cargoModifier = 1.0 - (Double(cargo) / 500.0) // Груз уменьшает дальность
        return baseRange * fuelCoefficient * cargoModifier
    }
    
    /// Шанс успеха миссии на основе расстояния
    func successChance(forDistance distance: Double) -> Double {
        let range = maxRange()
        if distance > range * 1.5 {
            return 0.2 // Очень низкий шанс
        } else if distance > range {
            return 0.5 // Средний шанс
        } else {
            return 0.9 // Высокий шанс
        }
    }
    
    /// Расход топлива на миссию
    func fuelConsumption(forDistance distance: Double) -> Double {
        let baseFuel = (distance / 10.0) // Базовый расход
        let cargoModifier = 1.0 + (Double(cargo) / 200.0) // Груз увеличивает расход
        return baseFuel * cargoModifier
    }
    
    /// Шанс уклонения в бою
    func evasionChance() -> Double {
        let baseEvasion = 0.3
        let speedBonus = Double(speed) / 2000.0 // Максимум +0.25
        let cargoMalus = Double(cargo) / 1000.0 // Максимум -0.1
        return min(0.8, max(0.1, baseEvasion + speedBonus - cargoMalus))
    }
    
    /// Получение повреждений с учётом брони
    func takeDamage(_ rawDamage: Double) -> Double {
        let armorReduction = Double(armor) * 0.5
        let actualDamage = max(1.0, rawDamage - armorReduction)
        health = max(0, health - actualDamage)
        return actualDamage
    }
    
    /// Заправка топлива
    func refuel(amount: Double) {
        fuel = min(maxFuel, fuel + amount)
    }
    
    /// Ремонт
    func repair(amount: Double) {
        health = min(100, health + amount)
    }
    
    /// Проверка готовности к миссии
    func isReadyForMission() -> (ready: Bool, reason: String?) {
        if fuel < 20 {
            return (false, "Недостаточно топлива")
        }
        if health < 30 {
            return (false, "Самолёт требует ремонта")
        }
        return (true, nil)
    }
}

// MARK: - Pilot (Legacy)
//
// ВАЖНО: Это legacy версия класса Pilot для обратной совместимости.
// Новый код должен использовать struct Pilot из Models/Pilot.swift + PilotViewModel
//
// TODO: Удалить этот класс после завершения миграции на MVVM

/// Пилот самолёта (LEGACY - используйте Models/Pilot.swift)
class PilotLegacy: ObservableObject {
    @Published var name: String
    @Published var level: Int
    @Published var experience: Int
    @Published var skillPoints: Int
    @Published var battleRating: Int // Battle Rating - показатель мастерства пилота
    
    // Навыки пилота
    @Published var combatSkill: Int // Боевое мастерство
    @Published var navigationSkill: Int // Навигация
    @Published var efficiencySkill: Int // Эффективность
    
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
    
    // MARK: - Methods
    
    /// Опыт для следующего уровня
    func experienceToNextLevel() -> Int {
        return level * 100
    }
    
    /// Прогресс до следующего уровня
    func experienceProgress() -> Double {
        return Double(experience) / Double(experienceToNextLevel())
    }
    
    /// Добавить опыт
    func addExperience(_ amount: Int) {
        experience += amount
        checkLevelUp()
    }
    
    /// Проверка повышения уровня
    private func checkLevelUp() {
        while experience >= experienceToNextLevel() {
            experience -= experienceToNextLevel()
            level += 1
            skillPoints += 2
            // Повышаем BR при повышении уровня
            battleRating += 1
        }
    }
    
    /// Множитель эффективности
    func effectivenessMultiplier() -> Double {
        let baseMultiplier = 1.0
        let levelBonus = Double(level - 1) * 0.05 // +5% за уровень
        let skillBonus = Double(combatSkill + navigationSkill + efficiencySkill) * 0.02
        return baseMultiplier + levelBonus + skillBonus
    }
    
    /// Бонус к критическому успеху
    func criticalChance() -> Double {
        let baseChance = 0.05
        let levelBonus = Double(level) * 0.01
        let combatBonus = Double(combatSkill) * 0.02
        return min(0.5, baseChance + levelBonus + combatBonus)
    }
    
    /// Бонус к навигации (уменьшение расхода топлива)
    func navigationBonus() -> Double {
        return 1.0 - (Double(navigationSkill) * 0.03) // До -30% расхода
    }
    
    /// Бонус к эффективности (увеличение дохода)
    func efficiencyBonus() -> Double {
        return 1.0 + (Double(efficiencySkill) * 0.04) // До +40% дохода
    }
    
    /// Улучшить навык
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

/// Псевдоним для обратной совместимости
/// TODO: Удалить после миграции всего кода на struct Pilot + PilotViewModel
typealias Pilot = PilotLegacy

// MARK: - Pilot Skill

enum PilotSkill {
    case combat
    case navigation
    case efficiency
    
    var title: String {
        switch self {
        case .combat: return "Бой"
        case .navigation: return "Навигация"
        case .efficiency: return "Эффективность"
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
        case .combat: return "Повышает урон и шанс критического успеха"
        case .navigation: return "Снижает расход топлива"
        case .efficiency: return "Увеличивает доход от миссий"
        }
    }
}

// MARK: - Game State

/// Общее состояние игры
// MARK: - Game State (Главная модель игры)
//
// ObservableObject с вложенными ObservableObject (aircraft, pilot, economy)
// ВАЖНО: Изменения во вложенных объектах автоматически пробрасываются
// через objectWillChange.send() для синхронизации всех View

class GameState: ObservableObject {
    @Published var aircraftVM: AircraftViewModel
    @Published var pilot: Pilot
    @Published var economy: EconomyManager
    @Published var altitude: Double
    @Published var missionHistory: MissionHistoryViewModel
    
    // Сохраняем подписки для отслеживания изменений вложенных объектов
    private var cancellables = Set<AnyCancellable>()
    
    // Устаревшее поле для обратной совместимости
    var money: Int {
        get { economy.credits }
        set { economy.credits = newValue }
    }
    
    // Proxy для доступа к aircraft через ViewModel
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
        
        // Подписываемся на изменения вложенных ObservableObject
        // Когда они меняются, GameState тоже публикует изменение
        aircraftVM.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
            self?.saveGame() // Автосохранение при изменении самолета
        }.store(in: &cancellables)
        
        pilot.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
            self?.saveGame() // Автосохранение при изменении пилота
        }.store(in: &cancellables)
        
        economy.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
            self?.saveGame() // Автосохранение при изменении экономики
        }.store(in: &cancellables)
        
        missionHistory.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        // Загружаем сохраненный прогресс
        _ = loadGame()
    }
    
    // MARK: - Mission Methods
    
    /// Рассчитать итоговый доход от миссии
    func calculateMissionReward(baseReward: Int) -> Int {
        let cargoBonus = 1.0 + (Double(aircraft.cargo) / 500.0)
        let pilotBonus = pilot.efficiencyBonus()
        return Int(Double(baseReward) * cargoBonus * pilotBonus)
    }
    
    /// Рассчитать расход топлива на миссию
    func calculateFuelCost(distance: Double) -> Double {
        let baseCost = aircraft.fuelConsumption(forDistance: distance)
        let pilotReduction = pilot.navigationBonus()
        return baseCost * pilotReduction
    }
    
    /// Рассчитать урон в бою
    func calculateDamage(multiplier: Double = 1.0) -> Double {
        let baseDamage = Double(aircraft.firepower) * 10.0
        let pilotMultiplier = pilot.effectivenessMultiplier()
        let criticalRoll = Double.random(in: 0...1)
        let isCritical = criticalRoll < pilot.criticalChance()
        
        return baseDamage * pilotMultiplier * multiplier * (isCritical ? 2.0 : 1.0)
    }
    
    /// Выполнить миссию (упрощённая логика)
    func executeMission(distance: Double, baseReward: Int, difficulty: Double = 1.0) -> MissionResult {
        // Проверка готовности
        let readiness = aircraftVM.isReadyForMission()
        guard readiness.ready else {
            return MissionResult(
                success: false,
                reward: 0,
                fuelUsed: 0,
                damageReceived: 0,
                experienceGained: 0,
                message: readiness.reason ?? "Миссия невозможна"
            )
        }
        
        // Расход топлива (в процентах)
        let fuelCostPercent = calculateFuelCost(distance: distance)
        
        // Конвертируем в единицы топлива (1% = 1 единица)
        let fuelUnitsNeeded = Int(ceil(fuelCostPercent))
        
        // Проверяем наличие топлива в экономике
        guard economy.fuelUnits >= fuelUnitsNeeded else {
            return MissionResult(
                success: false,
                reward: 0,
                fuelUsed: 0,
                damageReceived: 0,
                experienceGained: 0,
                message: "Недостаточно топлива (нужно \(fuelUnitsNeeded) ед.)"
            )
        }
        
        // Списываем топливо
        _ = economy.useFuel(fuelUnitsNeeded)
        aircraftVM.consumeFuel(fuelCostPercent)
        
        // Шанс успеха
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
                message: "Миссия провалена"
            )
        }
        
        // Бой (если есть)
        var damageReceived = 0.0
        if difficulty > 1.0 {
            let evasionSuccess = Double.random(in: 0...1) < aircraft.evasionChance
            if !evasionSuccess {
                let rawDamage = 15.0 * difficulty
                damageReceived = aircraftVM.takeDamage(rawDamage)
            }
        }
        
        // Награда в кредитах
        let reward = calculateMissionReward(baseReward: baseReward)
        economy.addCredits(reward)
        
        // Шанс получить запчасти
        if Double.random(in: 0...1) < 0.3 {
            let partsFound = Int.random(in: 1...3)
            economy.addParts(partsFound)
        }
        
        // Опыт
        let experience = Int(50.0 * difficulty)
        pilot.addExperience(experience)
        
        return MissionResult(
            success: true,
            reward: reward,
            fuelUsed: fuelCostPercent,
            damageReceived: damageReceived,
            experienceGained: experience,
            message: "Миссия выполнена успешно!"
        )
    }
    
    /// Выполнить миссию на основе шаблона
    func executeMissionFromTemplate(template: MissionTemplate, choiceIndex: Int? = nil) -> MissionResult {
        // Проверка готовности
        let readiness = aircraftVM.isReadyForMission()
        guard readiness.ready else {
            return MissionResult(
                success: false,
                reward: 0,
                fuelUsed: 0,
                damageReceived: 0,
                experienceGained: 0,
                message: readiness.reason ?? "Миссия невозможна"
            )
        }
        
        // Проверка требований миссии
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
                message: canStart.reason ?? "Требования не выполнены"
            )
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
        let fuelCostPercent = baseFuelCost * pilot.navigationBonus()
        let fuelUnitsNeeded = Int(ceil(fuelCostPercent))
        
        // Проверяем наличие топлива
        guard economy.fuelUnits >= fuelUnitsNeeded else {
            return MissionResult(
                success: false,
                reward: 0,
                fuelUsed: 0,
                damageReceived: 0,
                experienceGained: 0,
                message: "Недостаточно топлива (нужно \(fuelUnitsNeeded) ед.)"
            )
        }
        
        // Списываем топливо
        _ = economy.useFuel(fuelUnitsNeeded)
        aircraftVM.consumeFuel(fuelCostPercent)
        
        // Шанс успеха
        let baseSuccessChance = max(0.3, 1.0 - (totalDifficulty / 5.0))
        let pilotCombatBonus = Double(pilot.combatSkill) * 0.02
        let brBonus = Double(pilot.battleRating) / 200.0
        var finalSuccessChance = baseSuccessChance + pilotCombatBonus + brBonus - riskModifier
        finalSuccessChance = max(0.1, min(0.95, finalSuccessChance))
        
        let success = Double.random(in: 0...1) < finalSuccessChance
        
        if !success {
            let damage = 15.0 * totalDifficulty
            let actualDamage = aircraftVM.takeDamage(damage)
            
            // Опыт даже за провал (меньше)
            let failExperience = Int(30.0 * totalDifficulty)
            
            // Запоминаем уровень до добавления опыта
            let oldLevel = pilot.level
            let oldSkillPoints = pilot.skillPoints
            
            // Добавляем опыт даже за провал
            pilot.addExperience(failExperience)
            
            // Проверяем повышение уровня
            let leveledUp = pilot.level > oldLevel
            let newLevel = leveledUp ? pilot.level : nil
            let skillPointsGained = pilot.skillPoints - oldSkillPoints
            
            // Создаём результат миссии
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
            
            // Сохраняем провал в историю
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
        
        // Бой (получение урона)
        var damageReceived = 0.0
        if totalDifficulty > 1.0 {
            let evasionSuccess = Double.random(in: 0...1) < aircraft.evasionChance
            if !evasionSuccess {
                let rawDamage = 10.0 * totalDifficulty * (1.0 + riskModifier)
                damageReceived = aircraftVM.takeDamage(rawDamage)
            }
        }
        
        // Награда
        let baseReward = Double(template.baseReward) * template.modifier.difficultyModifier * rewardMultiplier
        let cargoBonus = 1.0 + (Double(aircraft.cargo) / 500.0)
        let pilotEfficiencyBonus = pilot.efficiencyBonus()
        let reward = Int(baseReward * cargoBonus * pilotEfficiencyBonus)
        economy.addCredits(reward)
        
        // Шанс получить запчасти (выше для сложных миссий)
        let partsChance = min(0.6, 0.2 + (totalDifficulty * 0.15))
        if Double.random(in: 0...1) < partsChance {
            let partsFound = Int.random(in: 1...Int(max(3, totalDifficulty * 2)))
            economy.addParts(partsFound)
        }
        
        // Опыт и повышение уровня
        let experience = Int(60.0 * totalDifficulty * (1.0 + riskModifier))
        
        // Запоминаем уровень до добавления опыта
        let oldLevel = pilot.level
        let oldSkillPoints = pilot.skillPoints
        
        // Добавляем опыт
        pilot.addExperience(experience)
        
        // Проверяем повышение уровня
        let leveledUp = pilot.level > oldLevel
        let newLevel = leveledUp ? pilot.level : nil
        let skillPointsGained = pilot.skillPoints - oldSkillPoints
        
        // Дополнительные skill points за особо сложные миссии (3.0+)
        var bonusSkillPoints = 0
        if totalDifficulty >= 3.0 {
            bonusSkillPoints = 1
            pilot.skillPoints += bonusSkillPoints
        }
        
        let totalSkillPointsGained = skillPointsGained + bonusSkillPoints
        
        // Создаём результат миссии
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
        
        // Сохраняем в историю
        let distance = Int(100.0 * totalDifficulty) // Псевдо-дистанция на основе сложности
        let flightTime = Int(60.0 * totalDifficulty) // Псевдо-время на основе сложности
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
    
    /// Сохранить прогресс игры
    func saveGame() {
        let saveData = GameSaveData(
            aircraft: aircraftVM.aircraft,
            pilot: pilot,
            economy: economy,
            altitude: altitude
        )
        
        if let encoded = try? JSONEncoder().encode(saveData) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
            print("✅ Игра сохранена: \(saveData.savedAt)")
        } else {
            print("❌ Ошибка сохранения игры")
        }
    }
    
    /// Загрузить прогресс игры
    func loadGame() -> Bool {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let saveData = try? JSONDecoder().decode(GameSaveData.self, from: data) else {
            print("⚠️ Сохранение не найдено, начинается новая игра")
            return false
        }
        
        // Загружаем Aircraft
        aircraftVM.aircraft = saveData.aircraft
        
        // Загружаем Pilot
        pilot.name = saveData.pilotName
        pilot.level = saveData.pilotLevel
        pilot.experience = saveData.pilotExperience
        pilot.skillPoints = saveData.pilotSkillPoints
        pilot.battleRating = saveData.pilotBattleRating
        pilot.combatSkill = saveData.pilotCombatSkill
        pilot.navigationSkill = saveData.pilotNavigationSkill
        pilot.efficiencySkill = saveData.pilotEfficiencySkill
        
        // Загружаем Economy
        economy.credits = saveData.credits
        economy.fuelUnits = saveData.fuelUnits
        economy.parts = saveData.parts
        economy.repairKits = saveData.repairKits.compactMap { $0.toRepairKit() }
        economy.setLastFuelRefill(saveData.lastFuelRefill)
        
        // Загружаем Altitude
        altitude = saveData.altitude
        
        print("✅ Игра загружена: сохранение от \(saveData.savedAt)")
        return true
    }
    
    /// Удалить сохранение (для отладки)
    func deleteSave() {
        UserDefaults.standard.removeObject(forKey: saveKey)
        print("🗑️ Сохранение удалено")
    }
}

// MARK: - MVVM Compatibility Type Aliases

/// Позволяет использовать новые MVVM-имена с существующими классами
/// Облегчает постепенный рефакторинг кода

// Новое имя для AircraftStats (уже ObservableObject класс)
// typealias AircraftViewModel = AircraftStats (закомментировано - избегаем конфликта имён)

// Новое имя для GameState (уже ObservableObject класс)
// typealias GameViewModel = GameState (закомментировано - избегаем конфликта имён)

// Примечание: Файлы в Models/ и ViewModels/ содержат чистые структуры данных
// которые будут использоваться в будущих рефакторингах.
// На данный момент используется монолитный подход в AircraftStats.swift

