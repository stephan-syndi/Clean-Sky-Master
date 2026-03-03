//
//  Mission.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import Foundation
import SwiftUI
import Combine
// MARK: - Mission Type

enum MissionType: String, CaseIterable, Codable {
    case passenger = "Пассажирская"
    case cargo = "Грузовая"
    case rescue = "Спасательная"
    case training = "Тренировочная"
    case special = "Специальная"
    
    var icon: String {
        switch self {
        case .passenger: return "person.2.fill"
        case .cargo: return "box.truck.fill"
        case .rescue: return "cross.fill"
        case .training: return "graduationcap.fill"
        case .special: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .passenger: return .blue
        case .cargo: return .orange
        case .rescue: return .red
        case .training: return .green
        case .special: return .purple
        }
    }
}

// MARK: - Mission Status

enum MissionStatus: String, Codable {
    case success = "Успешно"
    case failure = "Провал"
    case partial = "Частично"
}

// MARK: - Mission (Model)

struct Mission: Identifiable {
    let id = UUID()
    let type: MissionType
    let name: String
    let aircraft: String
    let date: Date
    let status: MissionStatus
    let distance: Int
    let flightTime: Int // в минутах
    let reward: Int
    let report: String
}

// MARK: - Mission Result

struct MissionResult {
    let success: Bool
    let reward: Int
    let fuelUsed: Double
    let damageReceived: Double
    let experienceGained: Int
    let message: String
    
    // Прогресс пилота
    let leveledUp: Bool // Повысился ли уровень
    let newLevel: Int? // Новый уровень (если повысился)
    let skillPointsGained: Int // Полученные очки улучшений
    
    init(
        success: Bool,
        reward: Int,
        fuelUsed: Double,
        damageReceived: Double,
        experienceGained: Int,
        message: String,
        leveledUp: Bool = false,
        newLevel: Int? = nil,
        skillPointsGained: Int = 0
    ) {
        self.success = success
        self.reward = reward
        self.fuelUsed = fuelUsed
        self.damageReceived = damageReceived
        self.experienceGained = experienceGained
        self.message = message
        self.leveledUp = leveledUp
        self.newLevel = newLevel
        self.skillPointsGained = skillPointsGained
    }
}

// MARK: - Available Mission (для списка миссий)

struct AvailableMission: Identifiable {
    let id = UUID()
    let name: String
    let type: MissionType
    let description: String
    let distance: Double
    let baseReward: Int
    let difficulty: Double
    let timeEstimate: Int // минуты
}

// MARK: - Date Range (для фильтрации)

enum DateRange: Equatable {
    case all
    case today
    case week
    case month
    case year
    case custom(from: Date, to: Date)
    
    var displayName: String {
        switch self {
        case .all: return "Все время"
        case .today: return "Сегодня"
        case .week: return "Неделя"
        case .month: return "Месяц"
        case .year: return "Год"
        case .custom: return "Период"
        }
    }
    
    static var allDisplayableCases: [DateRange] {
        return [.all, .today, .week, .month, .year]
    }
    
    func contains(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .all:
            return true
        case .today:
            return calendar.isDateInToday(date)
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            return date >= weekAgo
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            return date >= monthAgo
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
            return date >= yearAgo
        case .custom(let from, let to):
            return date >= from && date <= to
        }
    }
}

// MARK: - Mission Statistics

struct MissionStatistics {
    let totalMissions: Int
    let successfulMissions: Int
    let failedMissions: Int
    let partialMissions: Int
    let totalReward: Int
    let totalDistance: Int
    let totalFlightTime: Int
    
    var successRate: Double {
        guard totalMissions > 0 else { return 0 }
        return Double(successfulMissions) / Double(totalMissions)
    }
    
    var averageReward: Int {
        guard totalMissions > 0 else { return 0 }
        return totalReward / totalMissions
    }
}
