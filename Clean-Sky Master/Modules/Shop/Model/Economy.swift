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
    case quick = "Быстрый ремонт"
    case full = "Полный ремонт"
    case premium = "Премиум обслуживание"
    
    var icon: String {
        switch self {
        case .quick: return "bandage.fill"
        case .full: return "cross.fill"
        case .premium: return "checkmark.seal.fill"
        }
    }
    
    var description: String {
        switch self {
        case .quick: return "Восстановить 25% здоровья"
        case .full: return "Восстановить до 100%"
        case .premium: return "Ремонт + заправка + бонус"
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
// NOTE: Это активная (legacy) версия экономики.
// Планируется миграция на MVVM модели из Models/EconomyModel.swift

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
        case .credits: return "Кредиты"
        case .fuel: return "Топливо"
        case .parts: return "Запчасти"
        }
    }
}

// MARK: - Economy Manager

class EconomyManager: ObservableObject {
    @Published var credits: Int
    @Published var fuelUnits: Int // Топливо в единицах (не процентах)
    @Published var parts: Int
    @Published var repairKits: [RepairKit] = [] // Инвентарь ремкомплектов
    
    // Цены в магазине
    let fuelPrice: Int = 10 // кредитов за единицу топлива
    let partsPrice: Int = 50 // кредитов за запчасть
    
    // Пополнение с течением времени
    private var lastFuelRefill: Date
    private let fuelRefillInterval: TimeInterval = 300 // 5 минут
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
    
    /// Добавить кредиты
    func addCredits(_ amount: Int) {
        credits += amount
    }
    
    /// Потратить кредиты
    func spendCredits(_ amount: Int) -> Bool {
        guard credits >= amount else { return false }
        credits -= amount
        return true
    }
    
    /// Добавить топливо
    func addFuel(_ amount: Int) {
        fuelUnits += amount
    }
    
    /// Использовать топливо
    func useFuel(_ amount: Int) -> Bool {
        guard fuelUnits >= amount else { return false }
        fuelUnits -= amount
        return true
    }
    
    /// Добавить запчасти
    func addParts(_ amount: Int) {
        parts += amount
    }
    
    /// Использовать запчасти
    func useParts(_ amount: Int) -> Bool {
        guard parts >= amount else { return false }
        parts -= amount
        return true
    }
    
    // MARK: - Shop Operations
    
    /// Купить топливо
    func buyFuel(amount: Int) -> Bool {
        let cost = amount * fuelPrice
        guard spendCredits(cost) else { return false }
        addFuel(amount)
        return true
    }
    
    /// Купить запчасти
    func buyParts(amount: Int) -> Bool {
        let cost = amount * partsPrice
        guard spendCredits(cost) else { return false }
        addParts(amount)
        return true
    }
    
    /// Продать запчасти (за половину цены)
    func sellParts(amount: Int) -> Bool {
        guard useParts(amount) else { return false }
        addCredits(amount * (partsPrice / 2))
        return true
    }
    
    // MARK: - Auto Refill
    
    /// Проверка и автоматическое пополнение топлива
    func checkFuelRefill() {
        let now = Date()
        let timePassed = now.timeIntervalSince(lastFuelRefill)
        let refillsAvailable = Int(timePassed / fuelRefillInterval)
        
        if refillsAvailable > 0 {
            addFuel(refillsAvailable * fuelRefillAmount)
            lastFuelRefill = now
        }
    }
    
    /// Время до следующего пополнения топлива
    func timeUntilNextRefill() -> TimeInterval {
        let now = Date()
        let timePassed = now.timeIntervalSince(lastFuelRefill)
        let remaining = fuelRefillInterval - timePassed.truncatingRemainder(dividingBy: fuelRefillInterval)
        return remaining
    }
    
    /// Получить время последнего пополнения (для сохранения)
    func getLastFuelRefill() -> Date {
        return lastFuelRefill
    }
    
    /// Установить время последнего пополнения (при загрузке)
    func setLastFuelRefill(_ date: Date) {
        lastFuelRefill = date
    }
    
    // MARK: - Repair Cost
    
    /// Рассчитать стоимость ремонта
    func calculateRepairCost(healthDamage: Double) -> (credits: Int, parts: Int) {
        let baseCreditCost = Int(healthDamage * 5)
        let partsNeeded = Int(healthDamage / 10) // 1 запчасть на каждые 10% урона
        return (baseCreditCost, partsNeeded)
    }
    
    /// Выполнить ремонт
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
    
    /// Рассчитать сколько топлива нужно для заправки до максимума
    func calculateRefuelNeeded(currentFuel: Double, maxFuel: Double) -> Int {
        let fuelNeeded = maxFuel - currentFuel
        return max(0, Int(ceil(fuelNeeded)))
    }
    
    /// Заправить самолёт топливом
    func refuelAircraft(amount: Int) -> Bool {
        return useFuel(amount)
    }
    
    // MARK: - Repair Kits Inventory
    
    /// Добавить ремкомплект в инвентарь
    func addRepairKit(type: RepairKitType) {
        let kit = RepairKit(type: type)
        repairKits.append(kit)
    }
    
    /// Использовать ремкомплект из инвентаря
    func useRepairKit(_ kit: RepairKit) -> Bool {
        if let index = repairKits.firstIndex(where: { $0.id == kit.id }) {
            repairKits.remove(at: index)
            return true
        }
        return false
    }
    
    /// Получить количество ремкомплектов определенного типа
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
    case resources = "Ресурсы"
    case upgrades = "Улучшения"
    case repairs = "Ремонт"
    
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
                name: "Топливо ×10",
                description: "Пакет топлива для полётов",
                icon: "fuelpump.fill",
                price: .credits(100),
                category: .resources,
                effectDescription: "+10 единиц топлива"
            ),
            ShopItem(
                name: "Топливо ×50",
                description: "Большой запас топлива",
                icon: "fuelpump.fill",
                price: .credits(450),
                category: .resources,
                effectDescription: "+50 единиц топлива (скидка 10%)"
            ),
            ShopItem(
                name: "Топливо ×100",
                description: "Огромный запас топлива",
                icon: "fuelpump.fill",
                price: .credits(800),
                category: .resources,
                effectDescription: "+100 единиц топлива (скидка 20%)"
            ),
            ShopItem(
                name: "Запчасти ×5",
                description: "Набор запчастей для ремонта",
                icon: "gearshape.2.fill",
                price: .credits(250),
                category: .resources,
                effectDescription: "+5 запчастей"
            ),
            ShopItem(
                name: "Запчасти ×20",
                description: "Большой набор запчастей",
                icon: "gearshape.2.fill",
                price: .credits(900),
                category: .resources,
                effectDescription: "+20 запчастей (скидка 10%)"
            ),
            ShopItem(
                name: "Набор выживания",
                description: "Топливо и запчасти",
                icon: "cross.case.fill",
                price: .credits(600),
                category: .resources,
                effectDescription: "+25 топлива, +10 запчастей"
            )
        ]
    }
    
    static var upgradeItems: [ShopItem] {
        [
            ShopItem(
                name: "Усиленная броня",
                description: "Повышает защиту самолёта",
                icon: "shield.fill",
                price: .mixed(credits: 500, parts: 5),
                category: .upgrades,
                effectDescription: "+5 брони"
            ),
            ShopItem(
                name: "Улучшенный двигатель",
                description: "Увеличивает скорость",
                icon: "speedometer",
                price: .mixed(credits: 800, parts: 8),
                category: .upgrades,
                effectDescription: "+50 к скорости"
            ),
            ShopItem(
                name: "Оружейная система Mk.II",
                description: "Усиливает вооружение",
                icon: "scope",
                price: .mixed(credits: 600, parts: 6),
                category: .upgrades,
                effectDescription: "+3 к оружию"
            ),
            ShopItem(
                name: "Грузовой отсек",
                description: "Увеличивает грузоподъёмность",
                icon: "shippingbox.fill",
                price: .mixed(credits: 400, parts: 4),
                category: .upgrades,
                effectDescription: "+50 к грузу"
            ),
            ShopItem(
                name: "Расширенный топливный бак",
                description: "Увеличивает запас топлива",
                icon: "fuelpump.circle.fill",
                price: .mixed(credits: 700, parts: 7),
                category: .upgrades,
                effectDescription: "+20 к макс. топливу"
            )
        ]
    }
    
    static var repairItems: [ShopItem] {
        [
            ShopItem(
                name: "Быстрый ремонт",
                description: "Восстановить 25% здоровья",
                icon: "bandage.fill",
                price: .mixed(credits: 100, parts: 2),
                category: .repairs,
                effectDescription: "+25% здоровья"
            ),
            ShopItem(
                name: "Полный ремонт",
                description: "Восстановить до 100%",
                icon: "cross.fill",
                price: .mixed(credits: 350, parts: 7),
                category: .repairs,
                effectDescription: "Здоровье → 100%"
            ),
            ShopItem(
                name: "Премиум обслуживание",
                description: "Ремонт + заправка + бонус",
                icon: "checkmark.seal.fill",
                price: .mixed(credits: 500, parts: 5),
                category: .repairs,
                effectDescription: "100% здоровье, +50 топлива, +5% к характеристикам"
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
