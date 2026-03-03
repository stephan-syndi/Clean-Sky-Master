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
// АКТИВНЫЙ MVVM VIEW MODEL
//
// Управляет системой апгрейдов:
// - Список доступных апгрейдов
// - Купленные апгрейды
// - Баланс очков улучшений
// - Дерево зависимостей и разблокировка
// - Применение эффектов к самолету
// - Сохранение/загрузка прогресса
//
// Использует модели данных из Upgrade.swift:
// - Upgrade, UpgradeEffect, EffectType
// - UpgradeCategory

/// ViewModel для управления апгрейдами
class UpgradeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Список всех апгрейдов
    @Published var upgrades: [Upgrade] = []
    
    /// Категории апгрейдов
    @Published var categories: [UpgradeCategory] = []
    
    /// Баланс очков улучшений
    @Published var upgradePoints: Int = 1500
    
    /// Текущий выбранный апгрейд
    @Published var selectedUpgrade: Upgrade?
    
    /// Фильтр по категории (nil = все)
    @Published var selectedCategoryFilter: String?
    
    // MARK: - Initialization
    
    init() {
        loadDefaultUpgrades()
    }
    
    // MARK: - Upgrade Management
    
    /// Загружает стандартный набор апгрейдов
    func loadDefaultUpgrades() {
        upgrades = Upgrade.createDefaultUpgrades()
        categories = Upgrade.createDefaultCategories(for: upgrades)
    }
    
    /// Покупает апгрейд
    /// - Parameter upgrade: Апгрейд для покупки
    /// - Returns: true если покупка успешна, false если не хватает очков или апгрейд недоступен
    @discardableResult
    func purchaseUpgrade(_ upgrade: Upgrade) -> Bool {
        // Проверка наличия очков
        guard upgradePoints >= upgrade.cost else {
            return false
        }
        
        // Проверка разблокировки
        guard upgrade.isUnlocked else {
            return false
        }
        
        // Проверка что еще не куплен
        guard !upgrade.isPurchased else {
            return false
        }
        
        // Находим индекс апгрейда
        guard let index = upgrades.firstIndex(where: { $0.id == upgrade.id }) else {
            return false
        }
        
        // Списываем очки
        upgradePoints -= upgrade.cost
        
        // Помечаем как купленный
        upgrades[index].isPurchased = true
        
        // Разблокируем зависимые апгрейды
        unlockDependentUpgrades(for: upgrade)
        
        return true
    }
    
    /// Разблокирует апгрейды, зависящие от указанного
    /// - Parameter upgrade: Купленный апгрейд
    private func unlockDependentUpgrades(for upgrade: Upgrade) {
        for i in upgrades.indices {
            // Если требования содержат имя купленного апгрейда
            if upgrades[i].requirements.contains(upgrade.name) {
                // Проверяем все требования
                let allRequirementsMet = upgrades[i].requirements.allSatisfy { reqName in
                    upgrades.contains { $0.name == reqName && $0.isPurchased }
                }
                
                // Разблокируем если все требования выполнены
                if allRequirementsMet {
                    upgrades[i].isUnlocked = true
                }
            }
        }
    }
    
    /// Проверяет, может ли апгрейд быть куплен
    /// - Parameter upgrade: Апгрейд для проверки
    /// - Returns: Кортеж (можно купить, причина если нельзя)
    func canPurchase(_ upgrade: Upgrade) -> (canPurchase: Bool, reason: String?) {
        // Уже куплен
        if upgrade.isPurchased {
            return (false, "Уже приобретено")
        }
        
        // Не разблокирован
        if !upgrade.isUnlocked {
            let reqList = upgrade.requirements.joined(separator: ", ")
            return (false, "Требуется: \(reqList)")
        }
        
        // Недостаточно очков
        if upgradePoints < upgrade.cost {
            return (false, "Недостаточно очков (\(upgrade.cost) требуется)")
        }
        
        return (true, nil)
    }
    
    /// Применяет эффект апгрейда к самолету
    /// - Parameters:
    ///   - upgrade: Апгрейд для применения
    ///   - aircraftVM: AircraftViewModel для модификации
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
            // Health влияет на armor
            let bonusPercent = effect.value / 100.0
            let bonus = Int(Double(aircraftVM.aircraft.armor) * bonusPercent)
            aircraftVM.upgradeArmor(by: bonus)
            
        case .capacity:
            // Увеличиваем максимальное топливо
            aircraftVM.upgradeMaxFuel(by: effect.value)
            
        case .efficiency:
            // Эффективность - косвенный эффект, применяется при расчете миссий
            // Можно сохранить в отдельном свойстве или использовать модификатор
            break
            
        case .armor:
            aircraftVM.upgradeArmor(by: Int(effect.value))
            
        case .firepower:
            aircraftVM.upgradeFirepower(by: Int(effect.value))
            
        case .cargo:
            aircraftVM.upgradeCargo(by: Int(effect.value))
        }
    }
    
    /// Применяет все купленные апгрейды к самолету
    /// - Parameter aircraftVM: AircraftViewModel для модификации
    func applyAllPurchasedUpgrades(to aircraftVM: AircraftViewModel) {
        let purchased = upgrades.filter { $0.isPurchased }
        for upgrade in purchased {
            applyUpgradeEffect(upgrade, to: aircraftVM)
        }
    }
    
    // MARK: - Filtering & Search
    
    /// Возвращает апгрейды для указанной категории
    /// - Parameter category: Категория апгрейдов
    /// - Returns: Массив апгрейдов в категории
    func upgrades(for category: UpgradeCategory) -> [Upgrade] {
        return upgrades.filter { upgrade in
            category.upgradeIds.contains(upgrade.id)
        }
    }
    
    /// Возвращает все доступные для покупки апгрейды
    var availableUpgrades: [Upgrade] {
        return upgrades.filter { $0.isUnlocked && !$0.isPurchased }
    }
    
    /// Возвращает все купленные апгрейды
    var purchasedUpgrades: [Upgrade] {
        return upgrades.filter { $0.isPurchased }
    }
    
    /// Возвращает все заблокированные апгрейды
    var lockedUpgrades: [Upgrade] {
        return upgrades.filter { !$0.isUnlocked }
    }
    
    // MARK: - Points Management
    
    /// Добавляет очки улучшений
    /// - Parameter points: Количество очков для добавления
    func addPoints(_ points: Int) {
        upgradePoints += points
    }
    
    /// Снимает очки улучшений
    /// - Parameter points: Количество очков для снятия
    /// - Returns: true если успешно, false если недостаточно очков
    @discardableResult
    func spendPoints(_ points: Int) -> Bool {
        guard upgradePoints >= points else {
            return false
        }
        upgradePoints -= points
        return true
    }
    
    // MARK: - Statistics
    
    /// Возвращает статистику по апгрейдам
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
    
    /// Возвращает прогресс по каждой категории
    func categoryProgress(_ category: UpgradeCategory) -> (purchased: Int, total: Int) {
        let categoryUpgrades = upgrades(for: category)
        let purchased = categoryUpgrades.filter { $0.isPurchased }.count
        return (purchased, categoryUpgrades.count)
    }
    
    // MARK: - Utility
    
    /// Сбрасывает все апгрейды (для тестирования или новой игры)
    func resetAllUpgrades() {
        for i in upgrades.indices {
            upgrades[i].isPurchased = false
            
            // Разблокируем только те, у которых нет зависимостей
            upgrades[i].isUnlocked = upgrades[i].requirements.isEmpty
        }
        upgradePoints = 1500 // Начальное количество очков
    }
    
    /// Разблокирует все апгрейды (для тестирования)
    func unlockAll() {
        for i in upgrades.indices {
            upgrades[i].isUnlocked = true
        }
    }
    
    /// Выбирает апгрейд для просмотра деталей
    /// - Parameter upgrade: Апгрейд для выбора
    func selectUpgrade(_ upgrade: Upgrade) {
        selectedUpgrade = upgrade
    }
    
    /// Очищает выбранный апгрейд
    func clearSelection() {
        selectedUpgrade = nil
    }
}

// MARK: - Supporting Types

/// Статистика по апгрейдам
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
