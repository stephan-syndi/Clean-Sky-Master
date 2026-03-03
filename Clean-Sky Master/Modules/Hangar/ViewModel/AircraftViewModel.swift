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
// АКТИВНЫЙ MVVM VIEW MODEL (готов к использованию)
// Использует struct Aircraft из Models/Aircraft.swift
//
// NOTE: Проект пока использует legacy class AircraftStats из AircraftStats.swift
// Этот ViewModel готов к использованию при миграции на полный MVVM

/// ViewModel для управления самолётом
class AircraftViewModel: ObservableObject {
    @Published var aircraft: Aircraft
    
    init(aircraft: Aircraft = Aircraft()) {
        self.aircraft = aircraft
    }
    
    // MARK: - Actions
    
    /// Заправка топлива
    func refuel(amount: Double) {
        aircraft.fuel = min(aircraft.maxFuel, aircraft.fuel + amount)
    }
    
    /// Ремонт
    func repair(amount: Double) {
        aircraft.health = min(100, aircraft.health + amount)
    }
    
    /// Получение урона с учётом брони
    func takeDamage(_ rawDamage: Double) -> Double {
        let armorReduction = Double(aircraft.armor) * 0.5
        let actualDamage = max(1.0, rawDamage - armorReduction)
        aircraft.health = max(0, aircraft.health - actualDamage)
        return actualDamage
    }
    
    /// Использование топлива
    func consumeFuel(_ amount: Double) {
        aircraft.fuel = max(0, aircraft.fuel - amount)
    }
    
    /// Установка модуля
    func installModule(_ module: String) {
        if !aircraft.installedModules.contains(module) {
            aircraft.installedModules.append(module)
        }
    }
    
    /// Удаление модуля
    func removeModule(_ module: String) {
        aircraft.installedModules.removeAll { $0 == module }
    }
    
    /// Улучшение характеристики
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
    
    /// Проверка готовности к миссии
    func isReadyForMission() -> (ready: Bool, reason: String?) {
        if aircraft.fuel < 20 {
            return (false, "Недостаточно топлива")
        }
        if aircraft.health < 30 {
            return (false, "Самолёт требует ремонта")
        }
        return (true, nil)
    }
}
