//
//  AircraftViewModel.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import Foundation
import Combine

// MARK: - Aircraft View Model
//
// ACTIVE MVVM VIEW MODEL (ready to use)
// Uses struct Aircraft from Models/Aircraft.swift
//
// NOTE: Project still uses legacy class AircraftStats from AircraftStats.swift
// This ViewModel is ready to use when migrating to full MVVM

/// ViewModel for aircraft management
class AircraftViewModel: ObservableObject {
    @Published var aircraft: Aircraft
    
    init(aircraft: Aircraft = Aircraft()) {
        self.aircraft = aircraft
    }
    
    // MARK: - Actions
    
    /// Refuel
    func refuel(amount: Double) {
        aircraft.fuel = min(aircraft.maxFuel, aircraft.fuel + amount)
    }
    
    /// Repair
    func repair(amount: Double) {
        aircraft.health = min(100, aircraft.health + amount)
    }
    
    /// Take damage with armor reduction
    func takeDamage(_ rawDamage: Double) -> Double {
        let armorReduction = Double(aircraft.armor) * 0.5
        let actualDamage = max(1.0, rawDamage - armorReduction)
        aircraft.health = max(0, aircraft.health - actualDamage)
        return actualDamage
    }
    
    /// Consume fuel
    func consumeFuel(_ amount: Double) {
        aircraft.fuel = max(0, aircraft.fuel - amount)
    }
    
    /// Install module
    func installModule(_ module: String) {
        if !aircraft.installedModules.contains(module) {
            aircraft.installedModules.append(module)
        }
    }
    
    /// Remove module
    func removeModule(_ module: String) {
        aircraft.installedModules.removeAll { $0 == module }
    }
    
    /// Upgrade stats
    func upgradeArmor(by value: Int) {
        aircraft.armor += value
    }
    
    func upgradeFirepower(by value: Int) {
        aircraft.firepower += value
    }
    
    func upgradeSpeed(by value: Int) {
        aircraft.speed += value
    }
    
    func upgradeCargo(by value: Int) {
        aircraft.cargo += value
    }
    
    func upgradeMaxFuel(by value: Double) {
        aircraft.maxFuel += value
    }
    
    // MARK: - Mission Readiness
    
    /// Check mission readiness
    func isReadyForMission() -> (ready: Bool, reason: String?) {
        if aircraft.fuel < 20 {
            return (false, "Insufficient fuel")
        }
        if aircraft.health < 30 {
            return (false, "Aircraft needs repair")
        }
        return (true, nil)
    }
}
