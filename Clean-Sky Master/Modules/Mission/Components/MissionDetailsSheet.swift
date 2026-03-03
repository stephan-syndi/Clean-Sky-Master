//
//  MissionDetailsSheet.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import SwiftUI

// MARK: - Mission Details Sheet

struct MissionDetailsSheet: View {
    let template: MissionTemplate
    @ObservedObject var gameState: GameState
    let choiceIndex: Int?
    let onExecute: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var rewardMultiplier: Double {
        if let index = choiceIndex, let choices = template.choices {
            return choices[index].rewardMultiplier
        }
        return 1.0
    }
    
    var estimatedReward: Int {
        Int(Double(template.baseReward) * template.modifier.difficultyModifier * rewardMultiplier)
    }
    
    var readiness: (ready: Bool, reason: String?) {
        return gameState.aircraftVM.isReadyForMission()
    }
    
    var canStart: (canStart: Bool, reason: String?) {
        return MissionTemplatesLibrary.canStartMission(
            template: template,
            battleRating: gameState.pilot.battleRating,
            modules: gameState.aircraft.installedModules
        )
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.12, blue: 0.22)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Scrollable content
                ScrollView {
                    VStack(spacing: 24) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(template.category.color.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: template.category.icon)
                                .font(.system(size: 40))
                                .foregroundColor(template.category.color)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 12) {
                            Text(template.name)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(template.briefing)
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Player's choice
                        if let index = choiceIndex, let choices = template.choices {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your choice:")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Text(choices[index].text)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(template.category.color.opacity(0.1))
                            )
                            .padding(.horizontal)
                        }
                        
                        // Mission stats
                        VStack(spacing: 12) {
                            MissionDetailRow(
                                icon: "chart.bar.fill",
                                title: "Difficulty",
                                value: String(format: "×%.1f", template.baseDifficulty * template.modifier.difficultyModifier),
                                valueColor: template.baseDifficulty > 2.0 ? .red : template.baseDifficulty > 1.5 ? .orange : .green
                            )
                            
                            if template.minBattleRating > 0 {
                                MissionDetailRow(
                                    icon: "shield.fill",
                                    title: "Required BR",
                                    value: "\(template.minBattleRating)",
                                    valueColor: gameState.pilot.battleRating >= template.minBattleRating ? .green : .red
                                )
                            }
                            
                            // Add aircraft debug info
                            Divider()
                                .background(Color.white.opacity(0.1))
                            
                            MissionDetailRow(
                                icon: "fuelpump.fill",
                                title: "Fuel",
                                value: "\(Int(gameState.aircraft.fuel))%",
                                valueColor: gameState.aircraft.fuel >= 20 ? .green : .red
                            )
                            
                            MissionDetailRow(
                                icon: "heart.fill",
                                title: "Durability",
                                value: "\(Int(gameState.aircraft.health))%",
                                valueColor: gameState.aircraft.health >= 30 ? .green : .red
                            )
                            
                            MissionDetailRow(
                                icon: "shield.fill",
                                title: "Your BR",
                                value: "\(gameState.pilot.battleRating)",
                                valueColor: .cyan
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                            
                            if !template.requiredModules.isEmpty {
                                ForEach(template.requiredModules, id: \.self) { module in
                                    MissionDetailRow(
                                        icon: "wrench.fill",
                                        title: "Module",
                                        value: module,
                                        valueColor: gameState.aircraft.installedModules.contains(module) ? .green : .red
                                    )
                                }
                            }
                            
                            MissionDetailRow(
                                icon: "star.fill",
                                title: "Reward",
                                value: "\(estimatedReward)",
                                valueColor: .yellow
                            )
                            
                            if template.modifier != .none {
                                MissionDetailRow(
                                    icon: "exclamationmark.triangle.fill",
                                    title: "Modifier",
                                    value: template.modifier.rawValue,
                                    valueColor: .orange
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
                
                // Fixed buttons at bottom
                VStack(spacing: 12) {
                    if !readiness.ready {
                        Text(readiness.reason ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                    
                    if !canStart.canStart {
                        Text(canStart.reason ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        onExecute()
                    }) {
                        Text("START MISSION")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        (readiness.ready && canStart.canStart) ?
                                        LinearGradient(
                                            gradient: Gradient(colors: [template.category.color, template.category.color.opacity(0.8)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                    }
                    .disabled(!readiness.ready || !canStart.canStart)
                    
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
                .background(
                    Color(red: 0.08, green: 0.12, blue: 0.22)
                        .shadow(color: .black.opacity(0.3), radius: 10, y: -5)
                )
            }
        }
    }
}

// MARK: - Mission Detail Row

struct MissionDetailRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .white
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(valueColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
        )
    }
}
