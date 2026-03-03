//
//  AircraftDetailsView.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import SwiftUI
import Combine

struct AircraftDetailsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var gameState: GameState
    @State private var selectedTab: DetailTab = .aircraft
    
    enum DetailTab: String, CaseIterable {
        case aircraft = "Aircraft"
        case pilot = "Pilot"
        
        var icon: String {
            switch self {
            case .aircraft: return "airplane"
            case .pilot: return "person.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background
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
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("CHARACTERISTICS")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Balance
                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.yellow)
                        Text("\(gameState.economy.credits)")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )
                }
                .padding()
                .background(Color.black.opacity(0.3))
                
                // Tab switcher
                Picker("Tab", selection: $selectedTab) {
                    ForEach(DetailTab.allCases, id: \.self) { tab in
                        Label(tab.rawValue, systemImage: tab.icon)
                            .tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                ScrollView {
                    if selectedTab == .aircraft {
                        AircraftStatsContent(gameState: gameState)
                    } else {
                        PilotStatsContent(gameState: gameState)
                    }
                }
            }
        }
    }
}

// MARK: - Aircraft Stats Content

struct AircraftStatsContent: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        VStack(spacing: 20) {
            // Main parameters
            VStack(alignment: .leading, spacing: 12) {
                Text("MAIN PARAMETERS")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                VStack(spacing: 10) {
                    StatBar(
                        icon: "fuelpump.fill",
                        title: "Fuel",
                        value: gameState.aircraft.fuel,
                        maxValue: gameState.aircraft.maxFuel,
                        color: .green,
                        suffix: "%"
                    )
                    
                    StatBar(
                        icon: "heart.fill",
                        title: "Health",
                        value: gameState.aircraft.health,
                        maxValue: 100,
                        color: .cyan,
                        suffix: "%"
                    )
                }
            }
            
            // Combat characteristics
            VStack(alignment: .leading, spacing: 12) {
                Text("COMBAT CHARACTERISTICS")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                VStack(spacing: 10) {
                    StatNumber(
                        icon: "shield.fill",
                        title: "Armor",
                        value: gameState.aircraft.armor,
                        color: .blue,
                        description: "Reduces damage by \(gameState.aircraft.armor * 5)%"
                    )
                    
                    StatNumber(
                        icon: "scope",
                        title: "Weapons",
                        value: gameState.aircraft.firepower,
                        color: .red,
                        description: "Base damage: \(gameState.aircraft.firepower * 10)"
                    )
                    
                    StatNumber(
                        icon: "speedometer",
                        title: "Speed",
                        value: gameState.aircraft.speed,
                        color: .purple,
                        description: "Evasion: \(Int(gameState.aircraft.evasionChance * 100)) %",
                    )
                }
            }
            
            // Cargo capacity
            VStack(alignment: .leading, spacing: 12) {
                Text("LOGISTICS")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                StatNumber(
                    icon: "shippingbox.fill",
                    title: "Cargo Capacity",
                    value: gameState.aircraft.cargo,
                    color: .orange,
                    description: "Affects income (+\(Int((Double(gameState.aircraft.cargo) / 500.0) * 100))%)"
                )
            }
            
            // Calculated metrics
            VStack(alignment: .leading, spacing: 12) {
                Text("CALCULATED STATS")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                VStack(spacing: 10) {
                    CalculatedStatRow(
                        icon: "map",
                        title: "Max range",
                        value: "\(Int(gameState.aircraft.maxRange)) km"
                    )
                    
                    CalculatedStatRow(
                        icon: "bolt.fill",
                        title: "Evasion chance",
                        value: "\(Int(gameState.aircraft.evasionChance * 100)) %"
                    )
                }
            }
            
            Spacer(minLength: 30)
        }
        .padding(.vertical)
    }
}

// MARK: - Pilot Stats Content

struct PilotStatsContent: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        VStack(spacing: 20) {
            // Pilot information
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                }
                
                Text(gameState.pilot.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("LEVEL")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                        Text("\(gameState.pilot.level)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                    }
                    
                    VStack(spacing: 4) {
                        Text("SKILL POINTS")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                        Text("\(gameState.pilot.skillPoints)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            .padding(.horizontal)
            
            // Experience progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("EXPERIENCE TO NEXT LEVEL")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("\(gameState.pilot.experience) / \(gameState.pilot.experienceToNextLevel())")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.purple, .blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * gameState.pilot.experienceProgress(), height: 12)
                            .animation(.spring(response: 0.5), value: gameState.pilot.experienceProgress())
                    }
                }
                .frame(height: 12)
            }
            .padding(.horizontal)
            
            // Skills
            VStack(alignment: .leading, spacing: 16) {
                Text("SKILLS")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                PilotSkillRow(
                    skill: .combat,
                    level: gameState.pilot.combatSkill,
                    canUpgrade: gameState.pilot.skillPoints > 0,
                    onUpgrade: {
                        _ = gameState.pilot.upgradeSkill(.combat)
                    }
                )
                
                PilotSkillRow(
                    skill: .navigation,
                    level: gameState.pilot.navigationSkill,
                    canUpgrade: gameState.pilot.skillPoints > 0,
                    onUpgrade: {
                        _ = gameState.pilot.upgradeSkill(.navigation)
                    }
                )
                
                PilotSkillRow(
                    skill: .efficiency,
                    level: gameState.pilot.efficiencySkill,
                    canUpgrade: gameState.pilot.skillPoints > 0,
                    onUpgrade: {
                        _ = gameState.pilot.upgradeSkill(.efficiency)
                    }
                )
            }
            
            // Bonuses
            VStack(alignment: .leading, spacing: 12) {
                Text("BONUSES")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                VStack(spacing: 10) {
                    CalculatedStatRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Effectiveness",
                        value: "×\(String(format: "%.2f", gameState.pilot.effectivenessMultiplier()))"
                    )
                    
                    CalculatedStatRow(
                        icon: "bolt.circle.fill",
                        title: "Crit chance",
                        value: "\(Int(gameState.pilot.criticalChance() * 100))%"
                    )
                    
                    CalculatedStatRow(
                        icon: "fuelpump.fill",
                        title: "Fuel economy",
                        value: "\(Int((1.0 - gameState.pilot.navigationBonus()) * 100))%"
                    )
                    
                    CalculatedStatRow(
                        icon: "dollarsign.circle.fill",
                        title: "Income bonus",
                        value: "+\(Int((gameState.pilot.efficiencyBonus() - 1.0) * 100))%"
                    )
                }
            }
            
            Spacer(minLength: 30)
        }
        .padding(.vertical)
    }
}

// MARK: - Stat Bar

struct StatBar: View {
    let icon: String
    let title: String
    let value: Double
    let maxValue: Double
    let color: Color
    let suffix: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(value))\(suffix)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(width: geometry.size.width * (value / maxValue), height: 10)
                        .animation(.spring(response: 0.5), value: value)
                }
            }
            .frame(height: 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .padding(.horizontal)
    }
}

// MARK: - Stat Number

struct StatNumber: View {
    let icon: String
    let title: String
    let value: Int
    let color: Color
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .padding(.horizontal)
    }
}

// MARK: - Calculated Stat Row

struct CalculatedStatRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.cyan)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
        )
        .padding(.horizontal)
    }
}

// MARK: - Pilot Skill Row

struct PilotSkillRow: View {
    let skill: PilotSkill
    let level: Int
    let canUpgrade: Bool
    let onUpgrade: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: skill.icon)
                    .font(.system(size: 18))
                    .foregroundColor(.purple)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(skill.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(skill.description)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if level < 10 && canUpgrade {
                    Button(action: onUpgrade) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Skill level
            HStack(spacing: 4) {
                ForEach(0..<10, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index < level ? Color.purple : Color.white.opacity(0.2))
                        .frame(height: 6)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    AircraftDetailsView(gameState: GameState())
}
