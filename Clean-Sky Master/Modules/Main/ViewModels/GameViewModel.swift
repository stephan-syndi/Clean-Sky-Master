//
//  GameViewModel.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import Foundation
import Combine

// MARK: - Game View Model
//
// АКТИВНЫЙ MVVM VIEW MODEL (готов к использованию)
// 
// Координирует все подсистемы игры через MVVM паттерн
// Использует: Aircraft (struct), PilotData (struct), EconomyData (struct)
//
// NOTE: Проект пока использует legacy GameState из AircraftStats.swift
// Этот ViewModel готов к использованию при миграции на полный MVVM

/// Главный ViewModel игры - координирует все подсистемы
class GameViewModel: ObservableObject {
    @Published var aircraftVM: AircraftViewModel
    @Published var pilotVM: PilotViewModel
    @Published var economyVM: EconomyViewModel
    @Published var altitude: Double
    
    init(
        aircraftVM: AircraftViewModel = AircraftViewModel(),
        pilotVM: PilotViewModel = PilotViewModel(),
        economyVM: EconomyViewModel = EconomyViewModel(),
        altitude: Double = 5000
    ) {
        self.aircraftVM = aircraftVM
        self.pilotVM = pilotVM
        self.economyVM = economyVM
        self.altitude = altitude
    }
    
    // MARK: - Convenience Accessors
    
    var aircraft: Aircraft {
        aircraftVM.aircraft
    }
    
    var pilot: PilotData {
        pilotVM.pilot
    }
    
    var economy: EconomyData {
        economyVM.economy
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
        let readiness = aircraft.isReadyForMission()
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
        guard economyVM.fuelUnits >= fuelUnitsNeeded else {
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
        economyVM.useFuel(fuelUnitsNeeded)
        aircraftVM.consumeFuel(fuelCostPercent)
        
        // Шанс успеха
        let successChance = aircraft.successChance(forDistance: distance)
        let success = Double.random(in: 0...1) < successChance
        
        if !success {
            let damage = 10.0 * difficulty
            let _ = aircraftVM.takeDamage(damage)
            return MissionResult(
                success: false,
                reward: 0,
                fuelUsed: fuelCostPercent,
                damageReceived: damage,
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
        economyVM.addCredits(reward)
        
        // Шанс получить запчасти
        if Double.random(in: 0...1) < 0.3 {
            let partsFound = Int.random(in: 1...3)
            economyVM.addParts(partsFound)
        }
        
        // Опыт
        let experience = Int(50.0 * difficulty)
        pilotVM.addExperience(experience)
        
        return MissionResult(
            success: true,
            reward: reward,
            fuelUsed: fuelCostPercent,
            damageReceived: damageReceived,
            experienceGained: experience,
            message: "Миссия выполнена успешно!"
        )
    }
}
