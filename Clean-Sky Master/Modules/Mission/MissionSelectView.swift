//
//  MissionSelectView.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import SwiftUI

// MARK: - Mission Select View
//
// Основной экран выбора миссий.
// Использует MissionViewModel для управления состоянием миссий:
// - Список доступных миссий
// - Выбранная миссия и результаты
// - Генерация новых миссий
//
// Интегрирован с GameState для выполнения миссий (legacy совместимость)
//
// Компоненты вынесены в отдельные файлы:
// - MissionTemplateCard - карточка миссии
// - MissionChoiceSheet - окно выбора варианта
// - MissionDetailsSheet - детали миссии
// - MissionResultSheet - результаты миссии

struct MissionSelectView: View {
    @ObservedObject var gameState: GameState
    @StateObject private var missionVM = MissionViewModel()
    @State private var showMissionDetails = false
    @State private var showMissionChoice = false
    @State private var showMissionResult = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок с Battle Rating
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ДОСТУПНЫЕ МИССИИ")
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
            
            // Проверка готовности
            let readiness = gameState.aircraft.isReadyForMission()
            if !readiness.ready {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(readiness.reason ?? "Не готов к миссии")
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
            
            // Список миссий
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
                            // Обновляем список миссий через ViewModel
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
    
    /// Выполняет миссию через GameState (legacy совместимость)
    private func executeMission(_ template: MissionTemplate) {
        showMissionDetails = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let result = gameState.executeMissionFromTemplate(
                template: template,
                choiceIndex: missionVM.selectedChoiceIndex
            )
            
            // Сохраняем результат в ViewModel
            missionVM.lastResult = result
            showMissionResult = true
        }
    }
}

// MARK: - Preview

#Preview {
    MissionSelectView(gameState: GameState())
}

