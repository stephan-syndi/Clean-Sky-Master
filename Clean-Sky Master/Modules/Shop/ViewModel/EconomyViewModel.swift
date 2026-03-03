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
// ACTIVE MVVM VIEW MODEL (ready to use)
// Uses struct EconomyData from Models/EconomyModel.swift
//
// NOTE: Project still uses legacy class EconomyManager from Economy.swift
// This ViewModel is ready to use when migrating to full MVVM

/// ViewModel for economy management
class EconomyViewModel: ObservableObject {
    @Published var economy: EconomyData
    
    // Constants
    private let fuelRefillInterval: TimeInterval = 300 // 5 minutes
    private let fuelRefillAmount = 5
    private let maxFuelStorage = 100
    
    init(economy: EconomyData = EconomyData()) {
        self.economy = economy
    }
    
    // MARK: - Credits
    
    /// Add credits
    func addCredits(_ amount: Int) {
        economy.credits += amount
    }
    
    /// Spend credits
    func spendCredits(_ amount: Int) -> Bool {
        guard economy.credits >= amount else { return false }
        economy.credits -= amount
        return true
    }
    
    var credits: Int {
        economy.credits
    }
    
    // MARK: - Fuel
    
    /// Add fuel
    func addFuel(_ amount: Int) {
        economy.fuelUnits = min(maxFuelStorage, economy.fuelUnits + amount)
    }
    
    /// Use fuel
    func useFuel(_ amount: Int) -> Bool {
        guard economy.fuelUnits >= amount else { return false }
        economy.fuelUnits -= amount
        return true
    }
    
    var fuelUnits: Int {
        economy.fuelUnits
    }
    
    // MARK: - Parts
    
    /// Add parts
    func addParts(_ amount: Int) {
        economy.parts += amount
    }
    
    /// Use parts
    func useParts(_ amount: Int) -> Bool {
        guard economy.parts >= amount else { return false }
        economy.parts -= amount
        return true
    }
    
    var parts: Int {
        economy.parts
    }
    
    // MARK: - Auto Refill
    
    /// Check and apply auto refill
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
    
    /// Calculate repair cost
    func calculateRepairCost(currentHealth: Double) -> (credits: Int, parts: Int) {
        let healthDeficit = 100.0 - currentHealth
        let creditsNeeded = Int(healthDeficit * 5)
        let partsNeeded = Int(healthDeficit / 10)
        return (creditsNeeded, partsNeeded)
    }
    
    /// Check if repair is affordable
    func canAffordRepair(currentHealth: Double) -> Bool {
        let cost = calculateRepairCost(currentHealth: currentHealth)
        return economy.credits >= cost.credits && economy.parts >= cost.parts
    }
    
    /// Perform repair
    func performRepair(currentHealth: Double) -> Bool {
        let cost = calculateRepairCost(currentHealth: currentHealth)
        guard spendCredits(cost.credits) && useParts(cost.parts) else {
            return false
        }
        return true
    }
    
    // MARK: - Refuel
    
    /// Refuel cost (10 credits per unit)
    func refuelCost(units: Int) -> Int {
        return units * 10
    }
    
    /// Perform refuel
    func performRefuel(units: Int) -> Bool {
        let cost = refuelCost(units: units)
        guard spendCredits(cost) else { return false }
        addFuel(units)
        return true
    }
}
