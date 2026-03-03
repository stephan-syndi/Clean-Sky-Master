//
//  EconomyModel.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import Foundation

// MARK: - Economy (Model)
// NOTE: These are MVVM models for future implementation.
// Current active version is in Economy.swift (legacy)
//
// DUPLICATES REMOVED:
// - ShopItem, ShopCategory → use versions from Economy.swift
// - Upgrade, UpgradeEffect, UpgradeCategory → use versions from UpgradeView.swift
// - GameEvent, EventChoice, EventConsequence → use versions from EventPopupView.swift

/// Economy model - clean data for future MVVM architecture
struct EconomyData {
    var credits: Int // Main currency
    var fuelUnits: Int // Fuel as a resource
    var parts: Int // Repair parts
    var lastFuelRefillTime: Date // Time of last auto-refill
    
    init(
        credits: Int = 1000,
        fuelUnits: Int = 50,
        parts: Int = 10,
        lastFuelRefillTime: Date = Date()
    ) {
        self.credits = credits
        self.fuelUnits = fuelUnits
        self.parts = parts
        self.lastFuelRefillTime = lastFuelRefillTime
    }
}
