//
//  EconomyViewModel.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import Foundation
import Combine

// MARK: - Economy View Model
//
// АКТИВНЫЙ MVVM VIEW MODEL (готов к использованию)
// Использует struct EconomyData из Models/EconomyModel.swift
//
// NOTE: Проект пока использует legacy class EconomyManager из Economy.swift
// Этот ViewModel готов к использованию при миграции на полный MVVM

/// ViewModel для управления экономикой
class EconomyViewModel: ObservableObject {
    @Published var economy: EconomyData
    
    // Константы
    private let fuelRefillInterval: TimeInterval = 300 // 5 минут
    private let fuelRefillAmount = 5
    private let maxFuelStorage = 100
    
    init(economy: EconomyData = EconomyData()) {
        self.economy = economy
    }
    
    // MARK: - Credits
    
    /// Добавить кредиты
    func addCredits(_ amount: Int) {
        economy.credits += amount
    }
    
    /// Потратить кредиты
    func spendCredits(_ amount: Int) -> Bool {
        guard economy.credits >= amount else { return false }
        economy.credits -= amount
        return true
    }
    
    var credits: Int {
        economy.credits
    }
    
    // MARK: - Fuel
    
    /// Добавить топливо
    func addFuel(_ amount: Int) {
        economy.fuelUnits = min(maxFuelStorage, economy.fuelUnits + amount)
    }
    
    /// Использовать топливо
    func useFuel(_ amount: Int) -> Bool {
        guard economy.fuelUnits >= amount else { return false }
        economy.fuelUnits -= amount
        return true
    }
    
    var fuelUnits: Int {
        economy.fuelUnits
    }
    
    // MARK: - Parts
    
    /// Добавить запчасти
    func addParts(_ amount: Int) {
        economy.parts += amount
    }
    
    /// Использовать запчасти
    func useParts(_ amount: Int) -> Bool {
        guard economy.parts >= amount else { return false }
        economy.parts -= amount
        return true
    }
    
    var parts: Int {
        economy.parts
    }
    
    // MARK: - Auto Refill
    
    /// Проверить и применить автозаправку
    func checkFuelRefill() {
        let now = Date()
        let timeSinceLastRefill = now.timeIntervalSince(economy.lastFuelRefillTime)
        let refillsAvailable = Int(timeSinceLastRefill / fuelRefillInterval)
        
        if refillsAvailable > 0 {
            let fuelToAdd = refillsAvailable * fuelRefillAmount
            addFuel(fuelToAdd)
            economy.lastFuelRefillTime = now
        }
    }
    
    // MARK: - Repair
    
    /// Расчёт стоимости ремонта
    func calculateRepairCost(currentHealth: Double) -> (credits: Int, parts: Int) {
        let healthDeficit = 100.0 - currentHealth
        let creditsNeeded = Int(healthDeficit * 5)
        let partsNeeded = Int(healthDeficit / 10)
        return (creditsNeeded, partsNeeded)
    }
    
    /// Проверка возможности ремонта
    func canAffordRepair(currentHealth: Double) -> Bool {
        let cost = calculateRepairCost(currentHealth: currentHealth)
        return economy.credits >= cost.credits && economy.parts >= cost.parts
    }
    
    /// Выполнить ремонт
    func performRepair(currentHealth: Double) -> Bool {
        let cost = calculateRepairCost(currentHealth: currentHealth)
        guard spendCredits(cost.credits) && useParts(cost.parts) else {
            return false
        }
        return true
    }
    
    // MARK: - Refuel
    
    /// Стоимость заправки (10 кредитов за единицу)
    func refuelCost(units: Int) -> Int {
        return units * 10
    }
    
    /// Выполнить заправку
    func performRefuel(units: Int) -> Bool {
        let cost = refuelCost(units: units)
        guard spendCredits(cost) else { return false }
        addFuel(units)
        return true
    }
}
