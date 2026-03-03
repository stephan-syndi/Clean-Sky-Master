//
//  MissionHistoryViewModel.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 02.03.26.
//

import Foundation
import Combine

// MARK: - Completed Mission Model

/// Модель завершенной миссии для истории
struct CompletedMission: Identifiable, Codable {
    let id: UUID
    let templateName: String
    let category: MissionCategory
    let date: Date
    let status: MissionStatus
    let distance: Int
    let flightTime: Int // минуты
    let reward: Int
    let experienceGained: Int
    let fuelUsed: Double
    let damageReceived: Double
    let report: String
    
    // Для отображения в UI (совместимость с существующим кодом)
    var type: MissionType {
        return category.asMissionType
    }
    
    var name: String {
        return templateName
    }
    
    var aircraft: String {
        return "Текущий самолёт" // TODO: добавить сохранение названия самолета
    }
    
    init(
        id: UUID = UUID(),
        templateName: String,
        category: MissionCategory,
        date: Date = Date(),
        status: MissionStatus,
        distance: Int,
        flightTime: Int,
        reward: Int,
        experienceGained: Int,
        fuelUsed: Double,
        damageReceived: Double,
        report: String
    ) {
        self.id = id
        self.templateName = templateName
        self.category = category
        self.date = date
        self.status = status
        self.distance = distance
        self.flightTime = flightTime
        self.reward = reward
        self.experienceGained = experienceGained
        self.fuelUsed = fuelUsed
        self.damageReceived = damageReceived
        self.report = report
    }
}

// MARK: - Mission Category Extension

extension MissionCategory {
    var asMissionType: MissionType {
        switch self {
        case .patrol: return .training
        case .smuggling: return .cargo
        case .bossHunt: return .special
        case .storm: return .rescue
        case .rescue: return .rescue
        case .escort: return .passenger
        }
    }
}

// MARK: - Mission History ViewModel

/// ViewModel для управления историей миссий
class MissionHistoryViewModel: ObservableObject {
    @Published private(set) var missions: [CompletedMission] = []
    
    private let saveKey = "mission_history"
    
    init() {
        loadMissions()
    }
    
    // MARK: - Public Methods
    
    /// Добавить миссию в историю
    func addMission(
        template: MissionTemplate,
        result: MissionResult,
        distance: Int,
        flightTime: Int
    ) {
        let status: MissionStatus = result.success ? .success : .failure
        
        let mission = CompletedMission(
            templateName: template.name,
            category: template.category,
            date: Date(),
            status: status,
            distance: distance,
            flightTime: flightTime,
            reward: result.reward,
            experienceGained: result.experienceGained,
            fuelUsed: result.fuelUsed,
            damageReceived: result.damageReceived,
            report: result.message
        )
        
        missions.insert(mission, at: 0) // Добавляем в начало (новые сверху)
        saveMissions()
    }
    
    /// Получить статистику по всем миссиям
    func getStatistics() -> MissionStatistics {
        let total = missions.count
        let successful = missions.filter { $0.status == .success }.count
        let failed = missions.filter { $0.status == .failure }.count
        let partial = missions.filter { $0.status == .partial }.count
        let totalReward = missions.reduce(0) { $0 + $1.reward }
        let totalDistance = missions.reduce(0) { $0 + $1.distance }
        let totalFlightTime = missions.reduce(0) { $0 + $1.flightTime }
        
        return MissionStatistics(
            totalMissions: total,
            successfulMissions: successful,
            failedMissions: failed,
            partialMissions: partial,
            totalReward: totalReward,
            totalDistance: totalDistance,
            totalFlightTime: totalFlightTime
        )
    }
    
    /// Фильтровать миссии по типу
    func missions(ofType type: MissionType?) -> [CompletedMission] {
        guard let type = type else { return missions }
        return missions.filter { $0.type == type }
    }
    
    /// Фильтровать миссии по периоду
    func missions(inRange range: DateRange) -> [CompletedMission] {
        return missions.filter { range.contains($0.date) }
    }
    
    /// Удалить все миссии (для отладки)
    func clearHistory() {
        missions.removeAll()
        saveMissions()
    }
    
    // MARK: - Private Methods
    
    private func saveMissions() {
        if let encoded = try? JSONEncoder().encode(missions) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadMissions() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([CompletedMission].self, from: data) {
            missions = decoded
        }
    }
}
