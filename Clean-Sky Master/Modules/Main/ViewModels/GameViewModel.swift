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
// ACTIVE MVVM VIEW MODEL (ready to use)
// 
// Coordinates all game subsystems through MVVM pattern
// Uses: Aircraft (struct), PilotData (struct), EconomyData (struct)
//
// NOTE: Project still uses legacy GameState from AircraftStats.swift
// This ViewModel is ready to use when migrating to full MVVM

/// Main game ViewModel - coordinates all subsystems
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
    
    /// Calculate total mission reward
    func calculateMissionReward(baseReward: Int) -> Int {
        let cargoBonus = 1.0 + (Double(aircraft.cargo) / 500.0)
        let pilotBonus = pilot.efficiencyBonus()
        return Int(Double(baseReward) * cargoBonus * pilotBonus)
    }
    
    /// Calculate fuel cost for mission
    func calculateFuelCost(distance: Double) -> Double {
        let baseCost = aircraft.fuelConsumption(forDistance: distance)
        let pilotReduction = pilot.navigationBonus()
        return baseCost * pilotReduction
    }
    
    /// Calculate combat damage
    func calculateDamage(multiplier: Double = 1.0) -> Double {
        let baseDamage = Double(aircraft.firepower) * 10.0
        let pilotMultiplier = pilot.effectivenessMultiplier()
        let criticalRoll = Double.random(in: 0...1)
        let isCritical = criticalRoll < pilot.criticalChance()
        
        return baseDamage * pilotMultiplier * multiplier * (isCritical ? 2.0 : 1.0)
    }
    
    /// Execute mission (simplified logic)
    func executeMission(distance: Double, baseReward: Int, difficulty: Double = 1.0) -> MissionResult {
        // Check readiness
        let readiness = aircraft.isReadyForMission()
        guard readiness.ready else {
            return MissionResult(
                success: false,
                reward: 0,
                fuelUsed: 0,
                damageReceived: 0,
                experienceGained: 0,
                message: "Mission impossible"
            )
        }
        
        // Fuel cost (in percent)
        let fuelCostPercent = calculateFuelCost(distance: distance)
        
        // Convert to fuel units (1% = 1 unit)
        let fuelUnitsNeeded = Int(ceil(fuelCostPercent))
        
        // Check fuel availability in economy
        guard economyVM.fuelUnits >= fuelUnitsNeeded else {
            return MissionResult(
                success: false,
                reward: 0,
                fuelUsed: 0,
                damageReceived: 0,
                experienceGained: 0,
                message: "Insufficient fuel (need \(fuelUnitsNeeded) units)"
            )
        }
        
        // Deduct fuel
        economyVM.useFuel(fuelUnitsNeeded)
        aircraftVM.consumeFuel(fuelCostPercent)
        
        // Success chance
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
                message: "Mission failed"
            )
        }
        
        // Combat (if any)
        var damageReceived = 0.0
        if difficulty > 1.0 {
            let evasionSuccess = Double.random(in: 0...1) < aircraft.evasionChance
            if !evasionSuccess {
                let rawDamage = 15.0 * difficulty
                damageReceived = aircraftVM.takeDamage(rawDamage)
            }
        }
        
        // Reward in credits
        let reward = calculateMissionReward(baseReward: baseReward)
        economyVM.addCredits(reward)
        
        // Chance to get parts
        if Double.random(in: 0...1) < 0.3 {
            let partsFound = Int.random(in: 1...3)
            economyVM.addParts(partsFound)
        }
        
        // Experience
        let experience = Int(50.0 * difficulty)
        pilotVM.addExperience(experience)
        
        return MissionResult(
            success: true,
            reward: reward,
            fuelUsed: fuelCostPercent,
            damageReceived: damageReceived,
            experienceGained: experience,
            message: "Mission completed successfully!"
        )
    }
}
