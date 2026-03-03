//
//  Aircraft.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import Foundation

// MARK: - Aircraft (Model)
//
// ACTIVE MVVM MODEL
// Used with AircraftViewModel from ViewModels/
//
// NOTE: Project currently uses legacy class AircraftStats from AircraftStats.swift
// This model is ready for use when migrating to full MVVM

/// Aircraft model - pure data without logic
struct Aircraft: Codable {
    var fuel: Double // Fuel (0-100)
    var maxFuel: Double // Maximum capacity
    var armor: Int // Armor
    var firepower: Int // Weapons
    var speed: Int // Speed
    var cargo: Int // Cargo capacity
    var health: Double // Hull health (0-100)
    var installedModules: [String] // Installed modules
    
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
    
    // MARK: - Computed Properties
    
    /// Battle Rating calculation (combat power)
    var battleRating: Int {
        let armorPoints = armor * 2
        let firepowerPoints = firepower * 3
        let speedPoints = speed / 20
        let healthBonus = Int(health / 10)
        let moduleBonus = installedModules.count * 5
        return armorPoints + firepowerPoints + speedPoints + healthBonus + moduleBonus
    }
    
    /// Maximum flight range
    var maxRange: Double {
        let baseRange = 1000.0
        let fuelCoefficient = fuel / 100.0
        let cargoModifier = 1.0 - (Double(cargo) / 500.0)
        return baseRange * fuelCoefficient * cargoModifier
    }
    
    /// Evasion chance in combat
    var evasionChance: Double {
        let baseEvasion = 0.3
        let speedBonus = Double(speed) / 2000.0
        let cargoMalus = Double(cargo) / 1000.0
        return min(0.8, max(0.1, baseEvasion + speedBonus - cargoMalus))
    }
    
    // MARK: - Methods
    
    /// Mission success chance based on distance
    func successChance(forDistance distance: Double) -> Double {
        let range = maxRange
        if distance > range * 1.5 {
            return 0.2
        } else if distance > range {
            return 0.5
        } else {
            return 0.9
        }
    }
    
    /// Fuel consumption for mission (in percentage)
    func fuelConsumption(forDistance distance: Double) -> Double {
        let baseFuel = (distance / 10.0)
        let cargoModifier = 1.0 + (Double(cargo) / 200.0)
        return baseFuel * cargoModifier
    }
    
    /// Check readiness for mission
    func isReadyForMission() -> (ready: Bool, reason: String?) {
        if fuel < 20 {
            return (false, "Insufficient fuel")
        }
        if health < 30 {
            return (false, "Aircraft requires repair")
        }
        return (true, nil)
    }
    
    /// Take damage accounting for armor
    mutating func takeDamage(_ rawDamage: Double) -> Double {
        let armorReduction = Double(armor) * 0.5
        let actualDamage = max(1.0, rawDamage - armorReduction)
        health = max(0, health - actualDamage)
        return actualDamage
    }
}
