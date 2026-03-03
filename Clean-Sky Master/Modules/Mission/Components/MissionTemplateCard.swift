//
//  MissionTemplateCard.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import SwiftUI

// MARK: - Mission Template Card

struct MissionTemplateCard: View {
    let template: MissionTemplate
    let battleRating: Int
    let modules: [String]
    let onSelect: () -> Void
    
    var canStart: (canStart: Bool, reason: String?) {
        MissionTemplatesLibrary.canStartMission(
            template: template,
            battleRating: battleRating,
            modules: modules
        )
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(template.category.color.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: template.category.icon)
                            .font(.system(size: 24))
                            .foregroundColor(template.category.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(template.name)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(template.category.rawValue)
                            .font(.system(size: 13))
                            .foregroundColor(template.category.color)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                            Text("\(Int(Double(template.baseReward) * template.modifier.difficultyModifier))")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        if !canStart.canStart {
                            Text("🔒 BR \(template.minBattleRating)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.red)
                        } else {
                            Text("✓ Доступна")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Text(template.briefing)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                if template.modifier != .none {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        Text(template.modifier.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.2))
                    )
                }
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                HStack(spacing: 20) {
                    MissionStatChip(
                        icon: "chart.bar.fill",
                        value: String(format: "×%.1f", template.baseDifficulty * template.modifier.difficultyModifier)
                    )
                    
                    if template.minBattleRating > 0 {
                        MissionStatChip(icon: "shield.fill", value: "BR \(template.minBattleRating)")
                    }
                    
                    if !template.requiredModules.isEmpty {
                        MissionStatChip(icon: "wrench.fill", value: "\(template.requiredModules.count)")
                    }
                    
                    if template.choices != nil {
                        MissionStatChip(icon: "arrow.triangle.branch", value: "Выбор")
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(canStart.canStart ? 0.05 : 0.02))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(template.category.color.opacity(canStart.canStart ? 0.4 : 0.2), lineWidth: canStart.canStart ? 1.5 : 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!canStart.canStart)
    }
}

// MARK: - Mission Stat Chip

struct MissionStatChip: View {
    let icon: String
    let value: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.blue)
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
        }
    }
}
