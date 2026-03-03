//
//  MissionSelectView.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import SwiftUI

// MARK: - Mission Select View
//
// Main mission selection screen.
// Uses MissionViewModel for mission state management:
// - List of available missions
// - Selected mission and results
// - Generation of new missions
//
// Integrated with GameState for mission execution (legacy compatibility)
//
// Components are split into separate files:
// - MissionTemplateCard - mission card
// - MissionChoiceSheet - choice selection window
// - MissionDetailsSheet - mission details
// - MissionResultSheet - mission results

struct MissionSelectView: View {
    @ObservedObject var gameState: GameState
    @StateObject private var missionVM = MissionViewModel()
    @State private var showMissionDetails = false
    @State private var showMissionChoice = false
    @State private var showMissionResult = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Battle Rating
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AVAILABLE MISSIONS")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                        Text("BR: \(gameState.pilot.battleRating)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    missionVM.generateMissions(battleRating: gameState.pilot.battleRating)
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                        )
                }
            }
            .padding()
            
            // Readiness check
            let readiness = gameState.aircraft.isReadyForMission()
            if !readiness.ready {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(readiness.reason ?? "Not ready for mission")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.orange.opacity(0.2))
                )
                .padding(.horizontal)
            }
            
            // Mission list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(missionVM.availableMissions, id: \.name) { mission in
                        MissionTemplateCard(
                            template: mission,
                            battleRating: gameState.pilot.battleRating,
                            modules: gameState.aircraft.installedModules,
                            onSelect: {
                                missionVM.selectedMission = mission
                                if mission.choices != nil {
                                    showMissionChoice = true
                                } else {
                                    showMissionDetails = true
                                }
                            }
                        )
                    }
                }
                .padding()
            }
        }
        .onAppear {
            if missionVM.availableMissions.isEmpty {
                missionVM.generateMissions(battleRating: gameState.pilot.battleRating)
            }
        }
        .sheet(isPresented: $showMissionChoice) {
            if let mission = missionVM.selectedMission, let choices = mission.choices {
                MissionChoiceSheet(
                    mission: mission,
                    choices: choices,
                    onChoiceSelected: { index in
                        missionVM.selectedChoiceIndex = index
                        showMissionChoice = false
                        showMissionDetails = true
                    }
                )
            }
        }
        .sheet(isPresented: $showMissionDetails) {
            if let mission = missionVM.selectedMission {
                MissionDetailsSheet(
                    template: mission,
                    gameState: gameState,
                    choiceIndex: missionVM.selectedChoiceIndex,
                    onExecute: { executeMission(mission) }
                )
            }
        }
        .sheet(isPresented: $showMissionResult) {
            if let result = missionVM.lastResult, let mission = missionVM.selectedMission {
                MissionResultSheet(
                    result: result,
                    template: mission,
                    choiceIndex: missionVM.selectedChoiceIndex,
                    onDismiss: {
                        showMissionResult = false
                        if result.success {
                            // Update mission list through ViewModel
                            missionVM.refreshMissions(
                                completedMissionName: mission.name,
                                battleRating: gameState.pilot.battleRating
                            )
                        }
                        missionVM.selectedChoiceIndex = nil
                    }
                )
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Executes mission through GameState (legacy compatibility)
    private func executeMission(_ template: MissionTemplate) {
        showMissionDetails = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let result = gameState.executeMissionFromTemplate(
                template: template,
                choiceIndex: missionVM.selectedChoiceIndex
            )
            
            // Save result in ViewModel
            missionVM.lastResult = result
            showMissionResult = true
        }
    }
}

// MARK: - Preview

#Preview {
    MissionSelectView(gameState: GameState())
}

