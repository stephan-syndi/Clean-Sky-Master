//
//  EconomyModel.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import Foundation

// MARK: - Economy (Model)
// NOTE: Это MVVM модели для будущей реализации.
// Текущая активная версия находится в Economy.swift (legacy)
//
// ДУБЛИКАТЫ УДАЛЕНЫ:
// - ShopItem, ShopCategory → используйте версии из Economy.swift
// - Upgrade, UpgradeEffect, UpgradeCategory → используйте версии из UpgradeView.swift
// - GameEvent, EventChoice, EventConsequence → используйте версии из EventPopupView.swift

/// Модель экономики - чистые данные для будущей MVVM архитектуры
struct EconomyData {
    var credits: Int // Основная валюта
    var fuelUnits: Int // Топливо как ресурс
    var parts: Int // Запчасти для ремонта
    var lastFuelRefillTime: Date // Время последней автозаправки
    
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
