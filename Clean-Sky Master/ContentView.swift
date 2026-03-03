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
    
    // Timer for automatic fuel refill
    let fuelRefillTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TabView {
            MainDashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "gauge.with.dots.needle.67percent")
                }
            
            MissionSelectView(gameState: gameState)
                .tabItem {
                    Label("Missions", systemImage: "airplane.departure")
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
                    Label("Shop", systemImage: "cart.fill")
                }
            
            MissionLogView()
                .tabItem {
                    Label("Log", systemImage: "book.pages")
                }
        }
        .environmentObject(gameState)
        .tint(.blue)
        .onAppear {
            // Check automatic fuel refill on startup
            gameState.economy.checkFuelRefill()
        }
        .onReceive(fuelRefillTimer) { _ in
            // Check automatic fuel refill every minute
            gameState.economy.checkFuelRefill()
        }
    }
}

#Preview {
    ContentView()
}
