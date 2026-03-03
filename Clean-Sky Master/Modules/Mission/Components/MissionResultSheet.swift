//
//  MissionResultSheet.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import SwiftUI

// MARK: - Mission Result Sheet

struct MissionResultSheet: View {
    let result: MissionResult
    let template: MissionTemplate
    let choiceIndex: Int?
    let onDismiss: () -> Void
    
    var detailedReport: String {
        let lootFound = result.success ? Int.random(in: 20...100) : 0
        let damage = result.damageReceived
        return template.generateReport(
            success: result.success,
            choiceIndex: choiceIndex,
            damage: damage,
            lootFound: lootFound
        )
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.12, blue: 0.22)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Иконка результата
                    ZStack {
                        Circle()
                            .fill((result.success ? Color.green : Color.red).opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(result.success ? .green : .red)
                        
                        // Эффект повышения уровня
                        if result.leveledUp {
                            Circle()
                                .stroke(Color.yellow, lineWidth: 3)
                                .frame(width: 110, height: 110)
                            
                            Circle()
                                .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                                .frame(width: 120, height: 120)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Уведомление о повышении уровня
                    if result.leveledUp, let newLevel = result.newLevel {
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.yellow)
                                
                                Text("ПОВЫШЕНИЕ УРОВНЯ!")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.yellow)
                                
                                Image(systemName: "star.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.yellow)
                            }
                            
                            Text("Уровень \(newLevel)")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.3)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.yellow, lineWidth: 2)
                                )
                        )
                        .padding(.horizontal)
                    }
                    
                    // Детальный отчёт
                    VStack(alignment: .leading, spacing: 12) {
                        Text(detailedReport)
                            .font(.system(size: 15, design: .monospaced))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.3))
                    )
                    .padding(.horizontal)
                    
                    // Результаты
                    VStack(spacing: 12) {
                        if result.reward > 0 {
                            ResultStatRow(
                                icon: "star.fill",
                                title: "Получено кредитов",
                                value: "+\(result.reward)",
                                color: .yellow
                            )
                        }
                        
                        if result.fuelUsed > 0 {
                            ResultStatRow(
                                icon: "fuelpump.fill",
                                title: "Использовано топлива",
                                value: "-\(Int(result.fuelUsed))%",
                                color: .cyan
                            )
                        }
                        
                        if result.damageReceived > 0 {
                            ResultStatRow(
                                icon: "exclamationmark.triangle.fill",
                                title: "Получено повреждений",
                                value: "-\(Int(result.damageReceived))%",
                                color: .red
                            )
                        }
                        
                        if result.experienceGained > 0 {
                            ResultStatRow(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Получено опыта",
                                value: "+\(result.experienceGained) XP",
                                color: .purple
                            )
                        }
                        
                        // Повышение уровня
                        if result.leveledUp, let newLevel = result.newLevel {
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: "star.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.yellow)
                                        .frame(width: 30)
                                    
                                    Text("🎉 ПОВЫШЕНИЕ УРОВНЯ!")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.yellow)
                                    
                                    Spacer()
                                    
                                    Text("Уровень \(newLevel)")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.yellow)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.yellow.opacity(0.25), Color.orange.opacity(0.25)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Полученные skill points
                        if result.skillPointsGained > 0 {
                            ResultStatRow(
                                icon: "sparkles",
                                title: "Очки улучшений",
                                value: "+\(result.skillPointsGained)",
                                color: .cyan
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: onDismiss) {
                        Text("Продолжить")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(result.success ? Color.green : Color.blue)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

// MARK: - Result Stat Row

struct ResultStatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
    }
}
