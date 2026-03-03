//
//  Economy.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Repair Kit

struct RepairKit: Identifiable, Codable, Equatable {
    let id: UUID
    let type: RepairKitType
    
    init(type: RepairKitType) {
        self.id = UUID()
        self.type = type
    }
}

enum RepairKitType: String, Codable, CaseIterable {
    case quick = "Quick Repair"
    case full = "Full Repair"
    case premium = "Premium Service"
    
    var icon: String {
        switch self {
        case .quick: return "bandage.fill"
        case .full: return "cross.fill"
        case .premium: return "checkmark.seal.fill"
        }
    }
    
    var description: String {
        switch self {
        case .quick: return "Restore 25% health"
        case .full: return "Restore to 100%"
        case .premium: return "Repair + refuel + bonus"
        }
    }
    
    var healthRestore: Double {
        switch self {
        case .quick: return 25.0
        case .full: return 100.0
        case .premium: return 100.0
        }
    }
    
    var fuelBonus: Int {
        switch self {
        case .quick: return 0
        case .full: return 0
        case .premium: return 50
        }
    }
    
    var armorBonus: Int {
        switch self {
        case .quick: return 0
        case .full: return 0
        case .premium: return 1
        }
    }
}

// MARK: - Currency Type
// NOTE: This is the active (legacy) version of economy.
// Migration to MVVM models from Models/EconomyModel.swift is planned

enum CurrencyType {
    case credits
    case fuel
    case parts
    
    var icon: String {
        switch self {
        case .credits: return "dollarsign.circle.fill"
        case .fuel: return "fuelpump.fill"
        case .parts: return "gearshape.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .credits: return .yellow
        case .fuel: return .green
        case .parts: return .cyan
        }
    }
    
    var name: String {
        switch self {
        case .credits: return "Credits"
        case .fuel: return "Fuel"
        case .parts: return "Parts"
        }
    }
}

// MARK: - Economy Manager

class EconomyManager: ObservableObject {
    @Published var credits: Int
    @Published var fuelUnits: Int // Fuel in units (not percentages)
    @Published var parts: Int
    @Published var repairKits: [RepairKit] = [] // Repair kit inventory
    
    // Shop prices
    let fuelPrice: Int = 10 // credits per fuel unit
    let partsPrice: Int = 50 // credits per part
    
    // Auto-refill over time
    private var lastFuelRefill: Date
    private let fuelRefillInterval: TimeInterval = 300 // 5 minutes
    private let fuelRefillAmount: Int = 5
    
    init(
        credits: Int = 2000,
        fuelUnits: Int = 100,
        parts: Int = 10
    ) {
        self.credits = credits
        self.fuelUnits = fuelUnits
        self.parts = parts
        self.lastFuelRefill = Date()
    }
    
    // MARK: - Currency Operations
    
    /// Add credits
    func addCredits(_ amount: Int) {
        credits += amount
    }
    
    /// Spend credits
    func spendCredits(_ amount: Int) -> Bool {
        guard credits >= amount else { return false }
        credits -= amount
        return true
    }
    
    /// Add fuel
    func addFuel(_ amount: Int) {
        fuelUnits += amount
    }
    
    /// Use fuel
    func useFuel(_ amount: Int) -> Bool {
        guard fuelUnits >= amount else { return false }
        fuelUnits -= amount
        return true
    }
    
    /// Add parts
    func addParts(_ amount: Int) {
        parts += amount
    }
    
    /// Use parts
    func useParts(_ amount: Int) -> Bool {
        guard parts >= amount else { return false }
        parts -= amount
        return true
    }
    
    // MARK: - Shop Operations
    
    /// Buy fuel
    func buyFuel(amount: Int) -> Bool {
        let cost = amount * fuelPrice
        guard spendCredits(cost) else { return false }
        addFuel(amount)
        return true
    }
    
    /// Buy parts
    func buyParts(amount: Int) -> Bool {
        let cost = amount * partsPrice
        guard spendCredits(cost) else { return false }
        addParts(amount)
        return true
    }
    
    /// Sell parts (for half price)
    func sellParts(amount: Int) -> Bool {
        guard useParts(amount) else { return false }
        addCredits(amount * (partsPrice / 2))
        return true
    }
    
    // MARK: - Auto Refill
    
    /// Check and auto-refill fuel
    func checkFuelRefill() {
        let now = Date()
        let timePassed = now.timeIntervalSince(lastFuelRefill)
        let refillsAvailable = Int(timePassed / fuelRefillInterval)
        
        if refillsAvailable > 0 {
            addFuel(refillsAvailable * fuelRefillAmount)
            lastFuelRefill = now
        }
    }
    
    /// Time until next fuel refill
    func timeUntilNextRefill() -> TimeInterval {
        let now = Date()
        let timePassed = now.timeIntervalSince(lastFuelRefill)
        let remaining = fuelRefillInterval - timePassed.truncatingRemainder(dividingBy: fuelRefillInterval)
        return remaining
    }
    
    /// Get last refill time (for save)
    func getLastFuelRefill() -> Date {
        return lastFuelRefill
    }
    
    /// Set last refill time (on load)
    func setLastFuelRefill(_ date: Date) {
        lastFuelRefill = date
    }
    
    // MARK: - Repair Cost
    
    /// Calculate repair cost
    func calculateRepairCost(healthDamage: Double) -> (credits: Int, parts: Int) {
        let baseCreditCost = Int(healthDamage * 5)
        let partsNeeded = Int(healthDamage / 10) // 1 part per 10% damage
        return (baseCreditCost, partsNeeded)
    }
    
    /// Perform repair
    func performRepair(healthDamage: Double) -> Bool {
        let cost = calculateRepairCost(healthDamage: healthDamage)
        
        guard credits >= cost.credits && parts >= cost.parts else {
            return false
        }
        
        _ = spendCredits(cost.credits)
        _ = useParts(cost.parts)
        return true
    }
    
    // MARK: - Refuel Cost
    
    /// Calculate fuel needed to refuel to maximum
    func calculateRefuelNeeded(currentFuel: Double, maxFuel: Double) -> Int {
        let fuelNeeded = maxFuel - currentFuel
        return max(0, Int(ceil(fuelNeeded)))
    }
    
    /// Refuel aircraft
    func refuelAircraft(amount: Int) -> Bool {
        return useFuel(amount)
    }
    
    // MARK: - Repair Kits Inventory
    
    /// Add repair kit to inventory
    func addRepairKit(type: RepairKitType) {
        let kit = RepairKit(type: type)
        repairKits.append(kit)
    }
    
    /// Use repair kit from inventory
    func useRepairKit(_ kit: RepairKit) -> Bool {
        if let index = repairKits.firstIndex(where: { $0.id == kit.id }) {
            repairKits.remove(at: index)
            return true
        }
        return false
    }
    
    /// Get count of repair kits of specific type
    func countRepairKits(ofType type: RepairKitType) -> Int {
        return repairKits.filter { $0.type == type }.count
    }
}

// MARK: - Shop Item

struct ShopItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let price: ShopPrice
    let category: ShopCategory
    let effectDescription: String
}

struct ShopPrice {
    let credits: Int
    let fuel: Int
    let parts: Int
    
    static func credits(_ amount: Int) -> ShopPrice {
        ShopPrice(credits: amount, fuel: 0, parts: 0)
    }
    
    static func parts(_ amount: Int) -> ShopPrice {
        ShopPrice(credits: 0, fuel: 0, parts: amount)
    }
    
    static func mixed(credits: Int = 0, fuel: Int = 0, parts: Int = 0) -> ShopPrice {
        ShopPrice(credits: credits, fuel: fuel, parts: parts)
    }
}

enum ShopCategory: String, CaseIterable {
    case resources = "Resources"
    case upgrades = "Upgrades"
    case repairs = "Repairs"
    
    var title: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .resources: return "cube.box.fill"
        case .upgrades: return "arrow.up.circle.fill"
        case .repairs: return "wrench.and.screwdriver.fill"
        }
    }
}

// MARK: - Sample Shop Items

extension ShopItem {
    static var resourceItems: [ShopItem] {
        [
            ShopItem(
                name: "Fuel ×10",
                description: "Fuel pack for flights",
                icon: "fuelpump.fill",
                price: .credits(100),
                category: .resources,
                effectDescription: "+10 fuel units"
            ),
            ShopItem(
                name: "Fuel ×50",
                description: "Large fuel reserve",
                icon: "fuelpump.fill",
                price: .credits(450),
                category: .resources,
                effectDescription: "+50 fuel units (10% discount)"
            ),
            ShopItem(
                name: "Fuel ×100",
                description: "Huge fuel reserve",
                icon: "fuelpump.fill",
                price: .credits(800),
                category: .resources,
                effectDescription: "+100 fuel units (20% discount)"
            ),
            ShopItem(
                name: "Parts ×5",
                description: "Repair parts set",
                icon: "gearshape.2.fill",
                price: .credits(250),
                category: .resources,
                effectDescription: "+5 parts"
            ),
            ShopItem(
                name: "Parts ×20",
                description: "Large parts set",
                icon: "gearshape.2.fill",
                price: .credits(900),
                category: .resources,
                effectDescription: "+20 parts (10% discount)"
            ),
            ShopItem(
                name: "Survival Kit",
                description: "Fuel and parts",
                icon: "cross.case.fill",
                price: .credits(600),
                category: .resources,
                effectDescription: "+25 fuel, +10 parts"
            )
        ]
    }
    
    static var upgradeItems: [ShopItem] {
        [
            ShopItem(
                name: "Reinforced Armor",
                description: "Increases aircraft protection",
                icon: "shield.fill",
                price: .mixed(credits: 500, parts: 5),
                category: .upgrades,
                effectDescription: "+5 armor"
            ),
            ShopItem(
                name: "Upgraded Engine",
                description: "Increases speed",
                icon: "speedometer",
                price: .mixed(credits: 800, parts: 8),
                category: .upgrades,
                effectDescription: "+50 speed"
            ),
            ShopItem(
                name: "Weapon System Mk.II",
                description: "Enhances armament",
                icon: "scope",
                price: .mixed(credits: 600, parts: 6),
                category: .upgrades,
                effectDescription: "+3 weapons"
            ),
            ShopItem(
                name: "Cargo Bay",
                description: "Increases cargo capacity",
                icon: "shippingbox.fill",
                price: .mixed(credits: 400, parts: 4),
                category: .upgrades,
                effectDescription: "+50 cargo"
            ),
            ShopItem(
                name: "Extended Fuel Tank",
                description: "Increases fuel capacity",
                icon: "fuelpump.circle.fill",
                price: .mixed(credits: 700, parts: 7),
                category: .upgrades,
                effectDescription: "+20 max fuel"
            )
        ]
    }
    
    static var repairItems: [ShopItem] {
        [
            ShopItem(
                name: "Quick Repair",
                description: "Restore 25% health",
                icon: "bandage.fill",
                price: .mixed(credits: 100, parts: 2),
                category: .repairs,
                effectDescription: "+25% health"
            ),
            ShopItem(
                name: "Full Repair",
                description: "Restore to 100%",
                icon: "cross.fill",
                price: .mixed(credits: 350, parts: 7),
                category: .repairs,
                effectDescription: "Health → 100%"
            ),
            ShopItem(
                name: "Premium Service",
                description: "Repair + refuel + bonus",
                icon: "checkmark.seal.fill",
                price: .mixed(credits: 500, parts: 5),
                category: .repairs,
                effectDescription: "100% health, +50 fuel, +5% to stats"
            )
        ]
    }
    
    static var allItems: [ShopItem] {
        resourceItems + upgradeItems + repairItems
    }
}

// MARK: - Transaction Result

struct TransactionResult {
    let success: Bool
    let message: String
    let creditsSpent: Int
    let fuelSpent: Int
    let partsSpent: Int
}
