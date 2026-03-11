//
//  MainDashboardView.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import SwiftUI

// MARK: - Main Dashboard View
//
// Main control panel
// Uses unified data source via @EnvironmentObject:
// - GameState for access to economy (credits, fuel, parts)
// - Synchronized with ShopView and other Views
// - All changes are reflected throughout the application

struct MainDashboardView: View {
    @EnvironmentObject var gameState: GameState
    @State private var showUpgradeView = false
    @State private var showDetailsView = false
    @State private var showRefuelConfirmation = false
    @State private var showRepairConfirmation = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.1, blue: 0.2),
                    Color(red: 0.1, green: 0.15, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView { 
                VStack(spacing: 25) {
                    // Title
                    VStack(spacing: 10) {
                        HStack {
                            Text("DASHBOARD")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: { openPrivacyPolicy() }) {
                                Image(systemName: "hand.raised.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.purple)
                            }
                            .padding(.trailing, 8)
                            
                            Button(action: { showDetailsView = true }) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Balance and resources
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ResourceBadge(
                                    icon: "dollarsign.circle.fill",
                                    amount: gameState.economy.credits,
                                    color: .yellow,
                                    label: "Credits"
                                )
                                
                                ResourceBadge(
                                    icon: "fuelpump.fill",
                                    amount: gameState.economy.fuelUnits,
                                    color: .green,
                                    label: "Fuel"
                                )
                                
                                ResourceBadge(
                                    icon: "gearshape.fill",
                                    amount: gameState.economy.parts,
                                    color: .cyan,
                                    label: "Parts"
                                )
                                
                                ResourceBadge(
                                    icon: "person.fill",
                                    amount: gameState.pilot.level,
                                    color: .blue,
                                    label: "Level"
                                )
                                
                                ResourceBadge(
                                    icon: "shield.fill",
                                    amount: gameState.pilot.battleRating,
                                    color: .purple,
                                    label: "Battle Rating"
                                )
                            }
                            .padding(.horizontal, 4)
                        }
                        
                        // Free fuel refill hint
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.green)
                            Text("Fuel refills every 5 minutes")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }
                    .padding(.top, 20)
                    
                    // Main metrics (2x2 grid)
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            DashboardMetric(
                                title: "FUEL",
                                value: String(format: "%.0f%%", gameState.aircraft.fuel),
                                icon: "fuelpump.fill",
                                color: gameState.aircraft.fuel > 30 ? .green : .red,
                                progress: gameState.aircraft.fuel / 100
                            )
                            
                            DashboardMetric(
                                title: "HEALTH",
                                value: String(format: "%.0f%%", gameState.aircraft.health),
                                icon: "wrench.and.screwdriver.fill",
                                color: gameState.aircraft.health > 50 ? .cyan : .orange,
                                progress: gameState.aircraft.health / 100
                            )
                        }
                        
                        HStack(spacing: 20) {
                            DashboardMetric(
                                title: "ARMOR",
                                value: "\(gameState.aircraft.armor)",
                                icon: "shield.fill",
                                color: .blue,
                                progress: nil
                            )
                            
                            DashboardMetric(
                                title: "WEAPONS",
                                value: "\(gameState.aircraft.firepower)",
                                icon: "scope",
                                color: .red,
                                progress: nil
                            )
                        }
                        
                        HStack(spacing: 20) {
                            DashboardMetric(
                                title: "SPEED",
                                value: "\(gameState.aircraft.speed)",
                                icon: "speedometer",
                                color: .purple,
                                progress: nil
                            )
                            
                            DashboardMetric(
                                title: "CARGO",
                                value: "\(gameState.aircraft.cargo)",
                                icon: "shippingbox.fill",
                                color: .orange,
                                progress: nil
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Control buttons
                    VStack(spacing: 15) {
                        Text("CONTROLS")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                ActionButton(
                                    title: "REFUEL",
                                    icon: "fuelpump.fill",
                                    color: .blue,
                                    action: { handleRefuel() }
                                )
                                
                                ActionButton(
                                    title: "REPAIR",
                                    icon: "hammer.fill",
                                    color: .orange,
                                    action: { handleRepair() }
                                )
                            }
                            
                            ActionButton(
                                title: "UPGRADE",
                                icon: "star.fill",
                                color: .purple,
                                action: { handleUpgrade() }
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 30)
                }
            }
        }
        .sheet(isPresented: $showUpgradeView) {
            UpgradeView()
        }
        .sheet(isPresented: $showDetailsView) {
            AircraftDetailsView(gameState: gameState)
        }
        .sheet(isPresented: $showRefuelConfirmation) {
            let fuelNeeded = gameState.economy.calculateRefuelNeeded(
                currentFuel: gameState.aircraft.fuel,
                maxFuel: gameState.aircraft.maxFuel
            )
            let fuelToAdd = min(fuelNeeded, gameState.economy.fuelUnits)
            
            RefuelConfirmationSheet(
                currentFuel: gameState.aircraft.fuel,
                maxFuel: gameState.aircraft.maxFuel,
                availableFuel: gameState.economy.fuelUnits,
                fuelNeeded: fuelToAdd,
                onConfirm: {
                    performRefuel(amount: fuelToAdd)
                },
                onCancel: {
                    showRefuelConfirmation = false
                }
            )
        }
        .sheet(isPresented: $showRepairConfirmation) {
            RepairConfirmationSheet(
                currentHealth: gameState.aircraft.health,
                availableKits: gameState.economy.repairKits,
                onConfirm: { selectedKit in
                    performRepair(with: selectedKit)
                },
                onCancel: {
                    showRepairConfirmation = false
                }
            )
            .environmentObject(gameState)
        }
    }
    
    // MARK: - Actions
    
    private func handleRefuel() {
        // Calculate how much fuel is needed
        let fuelNeeded = gameState.economy.calculateRefuelNeeded(
            currentFuel: gameState.aircraft.fuel,
            maxFuel: gameState.aircraft.maxFuel
        )
        
        // Limit to available amount
        let fuelToAdd = min(fuelNeeded, gameState.economy.fuelUnits)
        
        guard fuelToAdd > 0 else {
            // Show message about fuel shortage or that tank is full
            return
        }
        
        // Show popup
        showRefuelConfirmation = true
    }
    
    private func performRefuel(amount: Int) {
        withAnimation(.spring(response: 0.5)) {
            if gameState.economy.refuelAircraft(amount: amount) {
                gameState.aircraftVM.refuel(amount: Double(amount))
            }
        }
        showRefuelConfirmation = false
    }
    
    private func handleRepair() {
        let damage = 100 - gameState.aircraft.health
        
        guard damage > 0 else { return }
        
        // Check if repair kits are available
        guard !gameState.economy.repairKits.isEmpty else {
            // Can show message that there are no repair kits
            return
        }
        
        // Show confirmation popup
        showRepairConfirmation = true
    }
    
    private func performRepair(with kit: RepairKit) {
        withAnimation(.spring(response: 0.5)) {
            // Use repair kit from inventory
            if gameState.economy.useRepairKit(kit) {
                // Restore health
                gameState.aircraftVM.repair(amount: kit.type.healthRestore)
                
                // Apply bonuses
                if kit.type.fuelBonus > 0 {
                    gameState.economy.addFuel(kit.type.fuelBonus)
                }
                
                if kit.type.armorBonus > 0 {
                    gameState.aircraftVM.upgradeArmor(by: kit.type.armorBonus)
                }
            }
        }
        showRepairConfirmation = false
    }
    
    private func handleUpgrade() {
        showUpgradeView = true
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://clean-skymaster.com/privacy-policy.html") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Refuel Confirmation Sheet

struct RefuelConfirmationSheet: View {
    let currentFuel: Double
    let maxFuel: Double
    let availableFuel: Int
    let fuelNeeded: Int
    let onConfirm: () -> Void
    let onCancel: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var fuelPercentage: Double {
        (currentFuel / maxFuel) * 100
    }
    
    var newFuelPercentage: Double {
        min(100, ((currentFuel + Double(fuelNeeded)) / maxFuel) * 100)
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.12, blue: 0.22)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "fuelpump.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                }
                .padding(.top, 20)
                
                VStack(spacing: 12) {
                    Text("REFUELING")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Confirm aircraft refueling")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                // Fuel information
                VStack(spacing: 16) {
                    // Current state
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CURRENT FUEL")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            Text(String(format: "%.0f%%", fuelPercentage))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20))
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("AFTER REFUELING")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            Text(String(format: "%.0f%%", newFuelPercentage))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                        }
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    // Cost
                    HStack {
                        Image(systemName: "fuelpump.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                            .frame(width: 30)
                        
                        Text("Fuel")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text("-\(fuelNeeded)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.red)
                            
                            Text("(\(availableFuel) available)")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.05))
                )
                .padding(.horizontal)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        onConfirm()
                        dismiss()
                    }) {
                        Text("CONFIRM")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.green, .green.opacity(0.8)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                    }
                    
                    Button(action: {
                        onCancel()
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Repair Confirmation Sheet

struct RepairConfirmationSheet: View {
    let currentHealth: Double
    let availableKits: [RepairKit]
    let onConfirm: (RepairKit) -> Void
    let onCancel: () -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gameState: GameState
    @State private var selectedKit: RepairKit?
    
    var groupedKits: [(type: RepairKitType, kits: [RepairKit])] {
        let grouped = Dictionary(grouping: availableKits) { $0.type }
        return RepairKitType.allCases.compactMap { type in
            if let kits = grouped[type], !kits.isEmpty {
                return (type: type, kits: kits)
            }
            return nil
        }
    }
    
    var previewHealth: Double {
        guard let kit = selectedKit else { return currentHealth }
        return min(100, currentHealth + kit.type.healthRestore)
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.12, blue: 0.22)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                }
                .padding(.top, 20)
                
                VStack(spacing: 12) {
                    Text("REPAIR")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Select a repair kit to use")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                // Current health
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CURRENT HEALTH")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                        Text(String(format: "%.0f%%", currentHealth))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    if selectedKit != nil {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("AFTER REPAIR")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            Text(String(format: "%.0f%%", previewHealth))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.cyan)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.05))
                )
                .padding(.horizontal)
                
                // Repair kits list
                ScrollView {
                    VStack(spacing: 12) {
                        if groupedKits.isEmpty {
                            Text("No repair kits available")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(groupedKits, id: \.type) { item in
                                RepairKitRow(
                                    type: item.type,
                                    count: item.kits.count,
                                    isSelected: selectedKit?.type == item.type,
                                    onSelect: {
                                        selectedKit = item.kits.first
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        if let kit = selectedKit {
                            onConfirm(kit)
                            dismiss()
                        }
                    }) {
                        Text(selectedKit != nil ? "USE" : "SELECT REPAIR KIT")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: selectedKit != nil ? [.orange, .orange.opacity(0.8)] : [.gray, .gray.opacity(0.8)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                    }
                    .disabled(selectedKit == nil)
                    
                    Button(action: {
                        onCancel()
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Repair Kit Row

struct RepairKitRow: View {
    let type: RepairKitType
    let count: Int
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.orange.opacity(0.3) : Color.white.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .orange : .white)
                }
                
                // Information
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(type.description)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 12) {
                        if type.healthRestore > 0 {
                            Label("+\(Int(type.healthRestore))% HP", systemImage: "heart.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.cyan)
                        }
                        
                        if type.fuelBonus > 0 {
                            Label("+\(type.fuelBonus)", systemImage: "fuelpump.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                        }
                        
                        if type.armorBonus > 0 {
                            Label("+\(type.armorBonus)", systemImage: "shield.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                // Quantity
                VStack(spacing: 4) {
                    Text("×\(count)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? .orange : .white)
                    
                    Text("in stock")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.orange.opacity(0.15) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Dashboard Metric Component

struct DashboardMetric: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let progress: Double?
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            // Value
            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // Title
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
            
            // Progress bar (if any)
            if let progress = progress {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Progress bar background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(width: geometry.size.width * progress, height: 8)
                            .animation(.spring(response: 0.5), value: progress)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Action Button Component

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3)) {
                    isPressed = false
                }
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical, 18)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color,
                                color.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: color.opacity(0.5), radius: isPressed ? 5 : 10, y: isPressed ? 2 : 4)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
    }
}

// MARK: - Resource Badge

struct ResourceBadge: View {
    let icon: String
    let amount: Int
    let color: Color
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Text("\(amount)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview

#Preview {
    MainDashboardView()
        .environmentObject(GameState())
}
