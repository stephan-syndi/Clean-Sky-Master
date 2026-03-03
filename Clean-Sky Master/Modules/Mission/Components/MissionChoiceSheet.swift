//
//  MissionChoiceSheet.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import SwiftUI

// MARK: - Mission Choice Sheet

struct MissionChoiceSheet: View {
    let mission: MissionTemplate
    let choices: [MissionChoice]
    let onChoiceSelected: (Int) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.12, blue: 0.22)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(mission.category.color.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: mission.category.icon)
                            .font(.system(size: 40))
                            .foregroundColor(mission.category.color)
                    }
                    .padding(.top, 20)
                    
                    Text(mission.name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Make your choice")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                
                // Choice options
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(choices.enumerated()), id: \.offset) { index, choice in
                            Button(action: {
                                onChoiceSelected(index)
                            }) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(choice.text)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                    
                                    HStack(spacing: 16) {
                                        // Risk
                                        HStack(spacing: 4) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(choice.riskLevel > 0.6 ? .red : choice.riskLevel > 0.3 ? .orange : .green)
                                            Text("Risk: \(Int(choice.riskLevel * 100))%")
                                                .font(.system(size: 13))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        // Reward
                                        HStack(spacing: 4) {
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.yellow)
                                            Text("×\(String(format: "%.1f", choice.rewardMultiplier))")
                                                .font(.system(size: 13))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(mission.category.color.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}
