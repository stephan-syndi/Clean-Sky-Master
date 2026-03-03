//
//  ShopView.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import SwiftUI
import Combine

// MARK: - Shop View
//
// Uses unified data source via @EnvironmentObject:
// - GameState for access to economy (credits, fuel, parts)
// - Synchronized with MainDashboardView and other Views
// - All changes are reflected throughout the application

struct ShopView: View {
    @EnvironmentObject var gameState: GameState
    @State private var selectedCategory: ShopCategory = .resources
    @State private var selectedItem: ShopItem?
    @State private var showPurchaseConfirmation = false
    @State private var showResult = false
    @State private var lastTransaction: TransactionResult?
    
    var filteredItems: [ShopItem] {
        ShopItem.allItems.filter { $0.category == selectedCategory }
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
                VStack(spacing: 16) {
                    Text("SHOP")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    // Currencies
                    HStack(spacing: 12) {
                        CurrencyBadge(
                            icon: CurrencyType.credits.icon,
                            amount: gameState.economy.credits,
                            color: CurrencyType.credits.color
                        )
                        
                        CurrencyBadge(
                            icon: CurrencyType.fuel.icon,
                            amount: gameState.economy.fuelUnits,
                            color: CurrencyType.fuel.color
                        )
                        
                        CurrencyBadge(
                            icon: CurrencyType.parts.icon,
                            amount: gameState.economy.parts,
                            color: CurrencyType.parts.color
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
                .background(Color.black.opacity(0.3))
                
                // Categories
                Picker("Category", selection: $selectedCategory) {
                    ForEach([ShopCategory.resources, .upgrades, .repairs], id: \.self) { category in
                        Label(category.title, systemImage: category.icon)
                            .tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Items
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredItems) { item in
                            ShopItemCard(
                                item: item,
                                onSelect: {
                                    selectedItem = item
                                    showPurchaseConfirmation = true
                                }
                            )
                            .environmentObject(gameState)
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showPurchaseConfirmation) {
            if let item = selectedItem {
                PurchaseConfirmationSheet(
                    item: item,
                    onPurchase: { result in
                        lastTransaction = result
                        showResult = true
                    }
                )
                .environmentObject(gameState)
            }
        }
        .alert("Purchase Result", isPresented: $showResult) {
            Button("OK") {
                showResult = false
                showPurchaseConfirmation = false
            }
        } message: {
            if let transaction = lastTransaction {
                Text(transaction.message)
            }
        }
    }
}

// MARK: - Currency Badge

struct CurrencyBadge: View {
    let icon: String
    let amount: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            Text("\(amount)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.1))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Shop Item Card

struct ShopItemCard: View {
    let item: ShopItem
    @EnvironmentObject var gameState: GameState
    let onSelect: () -> Void
    
    var canAfford: Bool {
        gameState.economy.credits >= item.price.credits &&
        gameState.economy.fuelUnits >= item.price.fuel &&
        gameState.economy.parts >= item.price.parts
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: item.icon)
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(item.description)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                
                // Effect
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                    Text(item.effectDescription)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.yellow)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(
                    Capsule()
                        .fill(Color.yellow.opacity(0.1))
                )
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                // Price
                HStack {
                    Text("PRICE:")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        if item.price.credits > 0 {
                            PriceTag(
                                icon: CurrencyType.credits.icon,
                                amount: item.price.credits,
                                color: CurrencyType.credits.color,
                                canAfford: gameState.economy.credits >= item.price.credits
                            )
                        }
                        
                        if item.price.fuel > 0 {
                            PriceTag(
                                icon: CurrencyType.fuel.icon,
                                amount: item.price.fuel,
                                color: CurrencyType.fuel.color,
                                canAfford: gameState.economy.fuelUnits >= item.price.fuel
                            )
                        }
                        
                        if item.price.parts > 0 {
                            PriceTag(
                                icon: CurrencyType.parts.icon,
                                amount: item.price.parts,
                                color: CurrencyType.parts.color,
                                canAfford: gameState.economy.parts >= item.price.parts
                            )
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                canAfford ? Color.blue.opacity(0.3) : Color.red.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
            .opacity(canAfford ? 1.0 : 0.6)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Price Tag

struct PriceTag: View {
    let icon: String
    let amount: Int
    let color: Color
    let canAfford: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text("\(amount)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
        }
        .foregroundColor(canAfford ? color : .red)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Purchase Confirmation Sheet

struct PurchaseConfirmationSheet: View {
    let item: ShopItem
    @EnvironmentObject var gameState: GameState
    let onPurchase: (TransactionResult) -> Void
    @Environment(\.dismiss) var dismiss
    
    var canAfford: Bool {
        gameState.economy.credits >= item.price.credits &&
        gameState.economy.fuelUnits >= item.price.fuel &&
        gameState.economy.parts >= item.price.parts
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.12, blue: 0.22)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                }
                .padding(.top, 20)
                
                VStack(spacing: 12) {
                    Text(item.name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(item.description)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text(item.effectDescription)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.yellow)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.yellow.opacity(0.1))
                        )
                }
                
                // Cost
                VStack(spacing: 12) {
                    Text("COST")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 8) {
                        if item.price.credits > 0 {
                            CostRow(
                                icon: CurrencyType.credits.icon,
                                name: CurrencyType.credits.name,
                                cost: item.price.credits,
                                available: gameState.economy.credits,
                                color: CurrencyType.credits.color
                            )
                        }
                        
                        if item.price.fuel > 0 {
                            CostRow(
                                icon: CurrencyType.fuel.icon,
                                name: CurrencyType.fuel.name,
                                cost: item.price.fuel,
                                available: gameState.economy.fuelUnits,
                                color: CurrencyType.fuel.color
                            )
                        }
                        
                        if item.price.parts > 0 {
                            CostRow(
                                icon: CurrencyType.parts.icon,
                                name: CurrencyType.parts.name,
                                cost: item.price.parts,
                                available: gameState.economy.parts,
                                color: CurrencyType.parts.color
                            )
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
                        performPurchase()
                    }) {
                        Text("BUY")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        canAfford ?
                                        LinearGradient(
                                            gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
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
                    .disabled(!canAfford)
                    
                    if !canAfford {
                        Text("Insufficient resources")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                    
                    Button(action: { dismiss() }) {
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
    
    private func performPurchase() {
        var result = TransactionResult(
            success: false,
            message: "Purchase error",
            creditsSpent: 0,
            fuelSpent: 0,
            partsSpent: 0
        )
        
        // Check and deduct resources
        guard canAfford else {
            result = TransactionResult(
                success: false,
                message: "Insufficient resources for purchase",
                creditsSpent: 0,
                fuelSpent: 0,
                partsSpent: 0
            )
            onPurchase(result)
            return
        }
        
        // Deduct currency
        if item.price.credits > 0 {
            _ = gameState.economy.spendCredits(item.price.credits)
        }
        if item.price.fuel > 0 {
            _ = gameState.economy.useFuel(item.price.fuel)
        }
        if item.price.parts > 0 {
            _ = gameState.economy.useParts(item.price.parts)
        }
        
        // Apply purchase effect
        applyItemEffect()
        
        result = TransactionResult(
            success: true,
            message: "Purchase completed successfully!",
            creditsSpent: item.price.credits,
            fuelSpent: item.price.fuel,
            partsSpent: item.price.parts
        )
        
        onPurchase(result)
    }
    
    private func applyItemEffect() {
        // Apply effects based on item
        switch item.name {
        case "Fuel ×10":
            gameState.economy.addFuel(10)
        case "Fuel ×50":
            gameState.economy.addFuel(50)
        case "Fuel ×100":
            gameState.economy.addFuel(100)
        case "Parts ×5":
            gameState.economy.addParts(5)
        case "Parts ×20":
            gameState.economy.addParts(20)
        case "Survival Kit":
            gameState.economy.addFuel(25)
            gameState.economy.addParts(10)
        case "Reinforced Armor":
            gameState.aircraft.armor += 5
        case "Improved Engine":
            gameState.aircraft.speed += 50
        case "Weapon System Mk.II":
            gameState.aircraft.firepower += 3
        case "Cargo Bay":
            gameState.aircraft.cargo += 50
        case "Extended Fuel Tank":
            gameState.aircraft.maxFuel += 20
        // Repair kits are now added to inventory
        case "Quick Repair":
            gameState.economy.addRepairKit(type: .quick)
        case "Full Repair":
            gameState.economy.addRepairKit(type: .full)
        case "Premium Service":
            gameState.economy.addRepairKit(type: .premium)
        default:
            break
        }
    }
}

// MARK: - Cost Row

struct CostRow: View {
    let icon: String
    let name: String
    let cost: Int
    let available: Int
    let color: Color
    
    var canAfford: Bool {
        available >= cost
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(name)
                .font(.system(size: 15))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("\(cost)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(canAfford ? .white : .red)
                
                Text("(\(available))")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ShopView()
        .environmentObject(GameState())
}
