//
//  UpgradeView.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import SwiftUI

// MARK: - Upgrade View

struct UpgradeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var upgrades: [Upgrade] = Upgrade.createDefaultUpgrades()
    @State private var categories: [UpgradeCategory] = []
    @State private var playerPoints: Int = 1500
    @State private var selectedUpgrade: Upgrade?
    @State private var showPurchaseConfirmation = false
    
    init() {
        let defaultUpgrades = Upgrade.createDefaultUpgrades()
        _upgrades = State(initialValue: defaultUpgrades)
        _categories = State(initialValue: Upgrade.createDefaultCategories(for: defaultUpgrades))
    }
    
    var body: some View {
        ZStack {
            // Фон
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
                // Шапка
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Назад")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("ДЕРЕВО АПГРЕЙДОВ")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Баланс очков
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(playerPoints)")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding()
                .background(Color.black.opacity(0.3))
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Дерево апгрейдов
                        ForEach(categories, id: \.title) { category in
                            UpgradeCategorySection(
                                category: category,
                                upgrades: upgrades.filter { upgrade in
                                    category.upgradeIds.contains(upgrade.id)
                                },
                                onUpgradeSelect: { upgrade in
                                    selectedUpgrade = upgrade
                                    showPurchaseConfirmation = true
                                }
                            )
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showPurchaseConfirmation) {
            if let upgrade = selectedUpgrade {
                PurchaseConfirmationView(
                    upgrade: upgrade,
                    playerPoints: playerPoints,
                    onPurchase: { purchasedUpgrade in
                        handlePurchase(purchasedUpgrade)
                    }
                )
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func handlePurchase(_ upgrade: Upgrade) {
        if playerPoints >= upgrade.cost {
            playerPoints -= upgrade.cost
            if let index = upgrades.firstIndex(where: { $0.id == upgrade.id }) {
                upgrades[index].isPurchased = true
                
                // Разблокировать зависимые апгрейды
                for i in upgrades.indices {
                    if upgrades[i].requirements.contains(upgrade.name) {
                        upgrades[i].isUnlocked = true
                    }
                }
            }
            showPurchaseConfirmation = false
        }
    }
}

// MARK: - Category Section

struct UpgradeCategorySection: View {
    let category: UpgradeCategory
    let upgrades: [Upgrade]
    let onUpgradeSelect: (Upgrade) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок категории
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                    .foregroundColor(category.color)
                
                Text(category.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 4)
            
            // Карточки апгрейдов с соединительными линиями
            VStack(spacing: 0) {
                ForEach(Array(upgrades.enumerated()), id: \.element.id) { index, upgrade in
                    VStack(spacing: 0) {
                        UpgradeCard(upgrade: upgrade) {
                            onUpgradeSelect(upgrade)
                        }
                        
                        // Соединительная линия к следующему апгрейду
                        if index < upgrades.count - 1 {
                            ConnectionLine(isActive: upgrade.isPurchased)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(category.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Connection Line

struct ConnectionLine: View {
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { _ in
                Rectangle()
                    .fill(isActive ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 2, height: 6)
            }
        }
        .frame(height: 30)
    }
}

// MARK: - Upgrade Card

struct UpgradeCard: View {
    let upgrade: Upgrade
    let onTap: () -> Void
    
    private var iconBackgroundColor: Color {
        if upgrade.isPurchased {
            return Color.green.opacity(0.2)
        } else if upgrade.isUnlocked {
            return upgrade.effect.color.opacity(0.2)
        } else {
            return Color.gray.opacity(0.1)
        }
    }
    
    private var cardBackgroundColor: Color {
        if upgrade.isPurchased {
            return Color.green.opacity(0.1)
        } else if upgrade.isUnlocked {
            return Color.white.opacity(0.05)
        } else {
            return Color.white.opacity(0.02)
        }
    }
    
    private var cardStrokeColor: Color {
        if upgrade.isPurchased {
            return Color.green.opacity(0.4)
        } else if upgrade.isUnlocked {
            return upgrade.effect.color.opacity(0.3)
        } else {
            return Color.gray.opacity(0.2)
        }
    }
    
    private var strokeWidth: CGFloat {
        upgrade.isPurchased ? 2 : 1
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Иконка и статус
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 60, height: 60)
                    
                    if upgrade.isPurchased {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: upgrade.icon)
                            .font(.system(size: 28))
                            .foregroundColor(upgrade.isUnlocked ? upgrade.effect.color : .gray)
                    }
                }
                
                // Информация
                VStack(alignment: .leading, spacing: 6) {
                    Text(upgrade.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(upgrade.description)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    // Эффект
                    HStack(spacing: 8) {
                        Text("ЭФФЕКТ:")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Text(upgrade.effect.displayString)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(upgrade.effect.color)
                    }
                }
                
                Spacer()
                
                // Стоимость и уровень
                VStack(spacing: 6) {
                    if !upgrade.isPurchased {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                            Text("\(upgrade.cost)")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.yellow.opacity(0.2))
                        )
                    }
                    
                    Text("Ур. \(upgrade.level)/\(upgrade.maxLevel)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(cardStrokeColor, lineWidth: strokeWidth)
                    )
            )
        }
        .disabled(!upgrade.isUnlocked || upgrade.isPurchased)
        .opacity(upgrade.isUnlocked ? 1.0 : 0.5)
    }
}

// MARK: - Purchase Confirmation

struct PurchaseConfirmationView: View {
    @Environment(\.dismiss) var dismiss
    let upgrade: Upgrade
    let playerPoints: Int
    let onPurchase: (Upgrade) -> Void
    
    var canPurchase: Bool {
        playerPoints >= upgrade.cost
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.12, blue: 0.22)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Иконка
                ZStack {
                    Circle()
                        .fill(upgrade.effect.color.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: upgrade.icon)
                        .font(.system(size: 40))
                        .foregroundColor(upgrade.effect.color)
                }
                .padding(.top, 20)
                
                // Информация
                VStack(spacing: 12) {
                    Text(upgrade.name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(upgrade.description)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Эффект
                    HStack(spacing: 8) {
                        Text("ЭФФЕКТ:")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Text(upgrade.effect.displayString)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(upgrade.effect.color)
                    }
                    .padding(.top, 8)
                }
                
                Spacer()
                
                // Кнопки
                VStack(spacing: 12) {
                    Button(action: {
                        onPurchase(upgrade)
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("КУПИТЬ ЗА \(upgrade.cost)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    canPurchase ?
                                    LinearGradient(
                                        gradient: Gradient(colors: [upgrade.effect.color, upgrade.effect.color.opacity(0.8)]),
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
                    .disabled(!canPurchase)
                    
                    Button(action: { dismiss() }) {
                        Text("Отмена")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                if !canPurchase {
                    Text("Недостаточно очков")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                        .padding(.bottom, 10)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    UpgradeView()
}
