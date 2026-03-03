//
//  Aircraft.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import Foundation

// MARK: - Aircraft (Model)
//
// АКТИВНАЯ MVVM МОДЕЛЬ
// Используется с AircraftViewModel из ViewModels/
//
// NOTE: Проект пока использует legacy class AircraftStats из AircraftStats.swift
// Эта модель готова к использованию при миграции на полный MVVM

/// Модель самолёта - чистые данные без логики
struct Aircraft: Codable {
    var fuel: Double // Топливо (0-100)
    var maxFuel: Double // Максимальная ёмкость
    var armor: Int // Броня
    var firepower: Int // Оружие
    var speed: Int // Скорость
    var cargo: Int // Грузоподъёмность
    var health: Double // Здоровье корпуса (0-100)
    var installedModules: [String] // Установленные модули
    
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
    
    /// Расчёт Battle Rating (боевой мощи)
    var battleRating: Int {
        let armorPoints = armor * 2
        let firepowerPoints = firepower * 3
        let speedPoints = speed / 20
        let healthBonus = Int(health / 10)
        let moduleBonus = installedModules.count * 5
        return armorPoints + firepowerPoints + speedPoints + healthBonus + moduleBonus
    }
    
    /// Максимальная дальность полёта
    var maxRange: Double {
        let baseRange = 1000.0
        let fuelCoefficient = fuel / 100.0
        let cargoModifier = 1.0 - (Double(cargo) / 500.0)
        return baseRange * fuelCoefficient * cargoModifier
    }
    
    /// Шанс уклонения в бою
    var evasionChance: Double {
        let baseEvasion = 0.3
        let speedBonus = Double(speed) / 2000.0
        let cargoMalus = Double(cargo) / 1000.0
        return min(0.8, max(0.1, baseEvasion + speedBonus - cargoMalus))
    }
    
    // MARK: - Methods
    
    /// Шанс успеха миссии на основе расстояния
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
    
    /// Расход топлива на миссию (в процентах)
    func fuelConsumption(forDistance distance: Double) -> Double {
        let baseFuel = (distance / 10.0)
        let cargoModifier = 1.0 + (Double(cargo) / 200.0)
        return baseFuel * cargoModifier
    }
    
    /// Проверка готовности к миссии
    func isReadyForMission() -> (ready: Bool, reason: String?) {
        if fuel < 20 {
            return (false, "Недостаточно топлива")
        }
        if health < 30 {
            return (false, "Самолёт требует ремонта")
        }
        return (true, nil)
    }
    
    /// Получение урона с учётом брони
    mutating func takeDamage(_ rawDamage: Double) -> Double {
        let armorReduction = Double(armor) * 0.5
        let actualDamage = max(1.0, rawDamage - armorReduction)
        health = max(0, health - actualDamage)
        return actualDamage
    }
}
