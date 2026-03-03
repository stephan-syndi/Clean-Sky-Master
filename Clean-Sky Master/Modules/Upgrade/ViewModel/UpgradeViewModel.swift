//
//  UpgradeViewModel.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 2.03.26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Upgrade View Model
//
// ACTIVE MVVM VIEW MODEL
//
// Manages upgrade system:
// - List of available upgrades
// - Purchased upgrades
// - Balance of upgrade points
// - Dependency tree and unlocking
// - Applying effects to aircraft
// - Saving/loading progress
//
// Uses data models from Upgrade.swift:
// - Upgrade, UpgradeEffect, EffectType
// - UpgradeCategory

/// ViewModel for upgrades management
class UpgradeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// List of all upgrades
    @Published var upgrades: [Upgrade] = []
    
    /// Upgrade categories
    @Published var categories: [UpgradeCategory] = []
    
    /// Balance of upgrade points
    @Published var upgradePoints: Int = 1500
    
    /// Currently selected upgrade
    @Published var selectedUpgrade: Upgrade?
    
    /// Filter by category (nil = all)
    @Published var selectedCategoryFilter: String?
    
    // MARK: - Initialization
    
    init() {
        loadDefaultUpgrades()
    }
    
    // MARK: - Upgrade Management
    
    /// Loads default set of upgrades
    func loadDefaultUpgrades() {
        upgrades = Upgrade.createDefaultUpgrades()
        categories = Upgrade.createDefaultCategories(for: upgrades)
    }
    
    /// Purchase upgrade
    /// - Parameter upgrade: Upgrade to purchase
    /// - Returns: true if purchase successful, false if insufficient points or upgrade unavailable
    @discardableResult
    func purchaseUpgrade(_ upgrade: Upgrade) -> Bool {
        // Check points availability
        guard upgradePoints >= upgrade.cost else {
            return false
        }
        
        // Check unlock status
        guard upgrade.isUnlocked else {
            return false
        }
        
        // Check not already purchased
        guard !upgrade.isPurchased else {
            return false
        }
        
        // Find upgrade index
        guard let index = upgrades.firstIndex(where: { $0.id == upgrade.id }) else {
            return false
        }
        
        // Deduct points
        upgradePoints -= upgrade.cost
        
        // Mark as purchased
        upgrades[index].isPurchased = true
        
        // Unlock dependent upgrades
        unlockDependentUpgrades(for: upgrade)
        
        return true
    }
    
    /// Unlocks upgrades depending on specified one
    /// - Parameter upgrade: Purchased upgrade
    private func unlockDependentUpgrades(for upgrade: Upgrade) {
        for i in upgrades.indices {
            // If requirements contain name of purchased upgrade
            if upgrades[i].requirements.contains(upgrade.name) {
                // Check all requirements
                let allRequirementsMet = upgrades[i].requirements.allSatisfy { reqName in
                    upgrades.contains { $0.name == reqName && $0.isPurchased }
                }
                
                // Unlock if all requirements are met
                if allRequirementsMet {
                    upgrades[i].isUnlocked = true
                }
            }
        }
    }
    
    /// Checks if upgrade can be purchased
    /// - Parameter upgrade: Upgrade to check
    /// - Returns: Tuple (can purchase, reason if not)
    func canPurchase(_ upgrade: Upgrade) -> (canPurchase: Bool, reason: String?) {
        // Already purchased
        if upgrade.isPurchased {
            return (false, "Already purchased")
        }
        
        // Not unlocked
        if !upgrade.isUnlocked {
            let reqList = upgrade.requirements.joined(separator: ", ")
            return (false, "Requires: \(reqList)")
        }
        
        // Insufficient points
        if upgradePoints < upgrade.cost {
            return (false, "Insufficient points (\(upgrade.cost) required)")
        }
        
        return (true, nil)
    }
    
    /// Applies upgrade effect to aircraft
    /// - Parameters:
    ///   - upgrade: Upgrade to apply
    ///   - aircraftVM: AircraftViewModel for modification
    func applyUpgradeEffect(_ upgrade: Upgrade, to aircraftVM: AircraftViewModel) {
        let effect = upgrade.effect
        
        switch effect.type {
        case .speed:
            aircraftVM.upgradeSpeed(by: Int(effect.value))
            
        case .fuel:
            let currentMax = aircraftVM.aircraft.maxFuel
            let bonusPercent = effect.value / 100.0
            let newMax = currentMax * (1.0 + bonusPercent)
            aircraftVM.upgradeMaxFuel(by: newMax - currentMax)
            
        case .health:
            // Health affects armor
            let bonusPercent = effect.value / 100.0
            let bonus = Int(Double(aircraftVM.aircraft.armor) * bonusPercent)
            aircraftVM.upgradeArmor(by: bonus)
            
        case .capacity:
            // Increase maximum fuel
            aircraftVM.upgradeMaxFuel(by: effect.value)
            
        case .efficiency:
            // Efficiency - indirect effect, applied in mission calculations
            // Can be stored in separate property or use modifier
            break
            
        case .armor:
            aircraftVM.upgradeArmor(by: Int(effect.value))
            
        case .firepower:
            aircraftVM.upgradeFirepower(by: Int(effect.value))
            
        case .cargo:
            aircraftVM.upgradeCargo(by: Int(effect.value))
        }
    }
    
    /// Applies all purchased upgrades to aircraft
    /// - Parameter aircraftVM: AircraftViewModel for modification
    func applyAllPurchasedUpgrades(to aircraftVM: AircraftViewModel) {
        let purchased = upgrades.filter { $0.isPurchased }
        for upgrade in purchased {
            applyUpgradeEffect(upgrade, to: aircraftVM)
        }
    }
    
    // MARK: - Filtering & Search
    
    /// Returns upgrades for specified category
    /// - Parameter category: Upgrade category
    /// - Returns: Array of upgrades in category
    func upgrades(for category: UpgradeCategory) -> [Upgrade] {
        return upgrades.filter { upgrade in
            category.upgradeIds.contains(upgrade.id)
        }
    }
    
    /// Returns all available for purchase upgrades
    var availableUpgrades: [Upgrade] {
        return upgrades.filter { $0.isUnlocked && !$0.isPurchased }
    }
    
    /// Returns all purchased upgrades
    var purchasedUpgrades: [Upgrade] {
        return upgrades.filter { $0.isPurchased }
    }
    
    /// Returns all locked upgrades
    var lockedUpgrades: [Upgrade] {
        return upgrades.filter { !$0.isUnlocked }
    }
    
    // MARK: - Points Management
    
    /// Adds upgrade points
    /// - Parameter points: Number of points to add
    func addPoints(_ points: Int) {
        upgradePoints += points
    }
    
    /// Deducts upgrade points
    /// - Parameter points: Number of points to deduct
    /// - Returns: true if successful, false if insufficient points
    @discardableResult
    func spendPoints(_ points: Int) -> Bool {
        guard upgradePoints >= points else {
            return false
        }
        upgradePoints -= points
        return true
    }
    
    // MARK: - Statistics
    
    /// Returns upgrade statistics
    var statistics: UpgradeStatistics {
        let total = upgrades.count
        let purchased = purchasedUpgrades.count
        let available = availableUpgrades.count
        let locked = lockedUpgrades.count
        let totalSpent = upgrades.filter { $0.isPurchased }.reduce(0) { $0 + $1.cost }
        
        return UpgradeStatistics(
            totalUpgrades: total,
            purchasedUpgrades: purchased,
            availableUpgrades: available,
            lockedUpgrades: locked,
            totalPointsSpent: totalSpent,
            currentPoints: upgradePoints
        )
    }
    
    /// Returns progress for each category
    func categoryProgress(_ category: UpgradeCategory) -> (purchased: Int, total: Int) {
        let categoryUpgrades = upgrades(for: category)
        let purchased = categoryUpgrades.filter { $0.isPurchased }.count
        return (purchased, categoryUpgrades.count)
    }
    
    // MARK: - Utility
    
    /// Resets all upgrades (for testing or new game)
    func resetAllUpgrades() {
        for i in upgrades.indices {
            upgrades[i].isPurchased = false
            
            // Unlock only those without dependencies
            upgrades[i].isUnlocked = upgrades[i].requirements.isEmpty
        }
        upgradePoints = 1500 // Initial amount of points
    }
    
    /// Unlocks all upgrades (for testing)
    func unlockAll() {
        for i in upgrades.indices {
            upgrades[i].isUnlocked = true
        }
    }
    
    /// Selects upgrade to view details
    /// - Parameter upgrade: Upgrade to select
    func selectUpgrade(_ upgrade: Upgrade) {
        selectedUpgrade = upgrade
    }
    
    /// Clears selected upgrade
    func clearSelection() {
        selectedUpgrade = nil
    }
}

// MARK: - Supporting Types

/// Upgrade statistics
struct UpgradeStatistics {
    let totalUpgrades: Int
    let purchasedUpgrades: Int
    let availableUpgrades: Int
    let lockedUpgrades: Int
    let totalPointsSpent: Int
    let currentPoints: Int
    
    var completionPercentage: Double {
        guard totalUpgrades > 0 else { return 0 }
        return Double(purchasedUpgrades) / Double(totalUpgrades) * 100.0
    }
}
