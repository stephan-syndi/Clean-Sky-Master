//
//  ContentView.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var gameState = GameState()
    
    // Таймер для автоматического восстановления топлива
    let fuelRefillTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TabView {
            MainDashboardView()
                .tabItem {
                    Label("Панель", systemImage: "gauge.with.dots.needle.67percent")
                }
            
            MissionSelectView(gameState: gameState)
                .tabItem {
                    Label("Миссии", systemImage: "airplane.departure")
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.05, green: 0.1, blue: 0.2),
                            Color(red: 0.1, green: 0.15, blue: 0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            ShopView()
                .tabItem {
                    Label("Магазин", systemImage: "cart.fill")
                }
            
            MissionLogView()
                .tabItem {
                    Label("Журнал", systemImage: "book.pages")
                }
        }
        .environmentObject(gameState)
        .tint(.blue)
        .onAppear {
            // Проверяем автоматическое пополнение топлива при запуске
            gameState.economy.checkFuelRefill()
        }
        .onReceive(fuelRefillTimer) { _ in
            // Проверяем автоматическое пополнение топлива каждую минуту
            gameState.economy.checkFuelRefill()
        }
    }
}

#Preview {
    ContentView()
}
