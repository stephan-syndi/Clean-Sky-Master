//
//  MissionLogView.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import SwiftUI

// MARK: - Mission Log View

struct MissionLogView: View {
    @EnvironmentObject var gameState: GameState
    @State private var selectedType: MissionType?
    @State private var selectedAircraft: String?
    @State private var selectedDateRange: DateRange = .all
    @State private var showFilters = false
    @State private var searchText = ""
    
    var filteredMissions: [CompletedMission] {
        gameState.missionHistory.missions.filter { mission in
            let matchesType = selectedType == nil || mission.type == selectedType
            let matchesAircraft = selectedAircraft == nil || mission.aircraft == selectedAircraft
            let matchesDate = selectedDateRange.contains(mission.date)
            let matchesSearch = searchText.isEmpty || 
                mission.name.localizedCaseInsensitiveContains(searchText) ||
                mission.report.localizedCaseInsensitiveContains(searchText)
            
            return matchesType && matchesAircraft && matchesDate && matchesSearch
        }
    }
    
    var aircraftList: [String] {
        Array(Set(gameState.missionHistory.missions.map { $0.aircraft })).sorted()
    }
    
    var body: some View {
        ZStack {
            // Фон
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.1, blue: 0.2),
                    Color(red: 0.1, green: 0.15, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Шапка
                VStack(spacing: 16) {
                    HStack {
                        Text("ЖУРНАЛ МИССИЙ")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { 
                            withAnimation(.spring(response: 0.3)) {
                                showFilters.toggle()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "line.3.horizontal.decrease.circle\(showFilters ? ".fill" : "")")
                                    .font(.system(size: 20))
                                Text("Фильтры")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(showFilters ? .blue : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(showFilters ? Color.blue.opacity(0.2) : Color.white.opacity(0.1))
                            )
                        }
                    }
                    
                    // Поиск
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Поиск по названию или отчёту...", text: $searchText)
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.1))
                    )
                    
                    // Панель фильтров
                    if showFilters {
                        FiltersPanel(
                            selectedType: $selectedType,
                            selectedAircraft: $selectedAircraft,
                            selectedDateRange: $selectedDateRange,
                            aircraftList: aircraftList
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding()
                .background(Color.black.opacity(0.3))
                
                // Счётчик результатов
                HStack {
                    Text("Найдено миссий: \(filteredMissions.count)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if selectedType != nil || selectedAircraft != nil || selectedDateRange != .all {
                        Button(action: resetFilters) {
                            Text("Сбросить фильтры")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Список миссий
                if filteredMissions.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredMissions) { mission in
                                MissionCard(mission: mission)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    private func resetFilters() {
        withAnimation {
            selectedType = nil
            selectedAircraft = nil
            selectedDateRange = .all
        }
    }
}

// MARK: - Filters Panel

struct FiltersPanel: View {
    @Binding var selectedType: MissionType?
    @Binding var selectedAircraft: String?
    @Binding var selectedDateRange: DateRange
    let aircraftList: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Тип миссии
            VStack(alignment: .leading, spacing: 8) {
                Text("ТИП МИССИИ")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "Все",
                            isSelected: selectedType == nil,
                            action: { selectedType = nil }
                        )
                        
                        ForEach(MissionType.allCases, id: \.self) { type in
                            FilterChip(
                                title: type.rawValue,
                                icon: type.icon,
                                color: type.color,
                                isSelected: selectedType == type,
                                action: { selectedType = type }
                            )
                        }
                    }
                }
            }
            
            // Самолёт
            VStack(alignment: .leading, spacing: 8) {
                Text("САМОЛЁТ")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "Все",
                            isSelected: selectedAircraft == nil,
                            action: { selectedAircraft = nil }
                        )
                        
                        ForEach(aircraftList, id: \.self) { aircraft in
                            FilterChip(
                                title: aircraft,
                                icon: "airplane",
                                isSelected: selectedAircraft == aircraft,
                                action: { selectedAircraft = aircraft }
                            )
                        }
                    }
                }
            }
            
            // Период
            VStack(alignment: .leading, spacing: 8) {
                Text("ПЕРИОД")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(DateRange.allDisplayableCases, id: \.displayName) { range in
                            FilterChip(
                                title: range.displayName,
                                icon: "calendar",
                                isSelected: selectedDateRange == range,
                                action: { selectedDateRange = range }
                            )
                        }
                    }
                }
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    var icon: String?
    var color: Color = .blue
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? color : Color.white.opacity(0.1))
            )
        }
    }
}

// MARK: - Mission Card

struct MissionCard: View {
    let mission: CompletedMission
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Основная информация
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    // Иконка типа
                    ZStack {
                        Circle()
                            .fill(mission.type.color.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: mission.type.icon)
                            .font(.system(size: 22))
                            .foregroundColor(mission.type.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mission.name)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            Label(mission.type.rawValue, systemImage: mission.type.icon)
                                .font(.system(size: 12))
                                .foregroundColor(mission.type.color)
                            
                            Label(mission.aircraft, systemImage: "airplane")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Text(mission.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        StatusBadge(status: mission.status)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                }
                .padding(16)
            }
            
            // Развёрнутая информация
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    // Статистика
                    HStack(spacing: 20) {
                        StatItem(icon: "map", label: "Дистанция", value: "\(mission.distance) км")
                        StatItem(icon: "clock", label: "Время", value: "\(mission.flightTime) мин")
                        StatItem(icon: "star.fill", label: "Награда", value: "\(mission.reward)")
                    }
                    
                    // Отчёт
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ОТЧЁТ О МИССИИ")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                        
                        Text(mission.report)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                    }
                }
                .padding(16)
                .padding(.top, -8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(mission.type.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: MissionStatus
    
    var color: Color {
        switch status {
        case .success: return .green
        case .failure: return .red
        case .partial: return .orange
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.2))
            )
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
            
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Миссии не найдены")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Попробуйте изменить фильтры")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    MissionLogView()
}

