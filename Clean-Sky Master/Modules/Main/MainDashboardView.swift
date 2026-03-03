//
//  MainDashboardView.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import SwiftUI

// MARK: - Main Dashboard View
//
// Главная панель управления
// Использует единый источник данных через @EnvironmentObject:
// - GameState для доступа к economy (кредиты, топливо, запчасти)
// - Синхронизировано с ShopView и другими View
// - Все изменения отражаются во всем приложении

struct MainDashboardView: View {
    @EnvironmentObject var gameState: GameState
    @State private var showUpgradeView = false
    @State private var showDetailsView = false
    @State private var showRefuelConfirmation = false
    @State private var showRepairConfirmation = false
    
    var body: some View {
        ZStack {
            // Фоновый градиент
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
                    // Заголовок
                    VStack(spacing: 10) {
                        HStack {
                            Text("ПРИБОРНАЯ ПАНЕЛЬ")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: { showDetailsView = true }) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Баланс и ресурсы
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ResourceBadge(
                                    icon: "dollarsign.circle.fill",
                                    amount: gameState.economy.credits,
                                    color: .yellow,
                                    label: "Кредиты"
                                )
                                
                                ResourceBadge(
                                    icon: "fuelpump.fill",
                                    amount: gameState.economy.fuelUnits,
                                    color: .green,
                                    label: "Топливо"
                                )
                                
                                ResourceBadge(
                                    icon: "gearshape.fill",
                                    amount: gameState.economy.parts,
                                    color: .cyan,
                                    label: "Запчасти"
                                )
                                
                                ResourceBadge(
                                    icon: "person.fill",
                                    amount: gameState.pilot.level,
                                    color: .blue,
                                    label: "Уровень"
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
                        
                        // Подсказка о бесплатном топливе
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.green)
                            Text("Топливо пополняется каждые 5 минут")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }
                    .padding(.top, 20)
                    
                    // Основные показатели (сетка 2x2)
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            DashboardMetric(
                                title: "ТОПЛИВО",
                                value: String(format: "%.0f%%", gameState.aircraft.fuel),
                                icon: "fuelpump.fill",
                                color: gameState.aircraft.fuel > 30 ? .green : .red,
                                progress: gameState.aircraft.fuel / 100
                            )
                            
                            DashboardMetric(
                                title: "ЗДОРОВЬЕ",
                                value: String(format: "%.0f%%", gameState.aircraft.health),
                                icon: "wrench.and.screwdriver.fill",
                                color: gameState.aircraft.health > 50 ? .cyan : .orange,
                                progress: gameState.aircraft.health / 100
                            )
                        }
                        
                        HStack(spacing: 20) {
                            DashboardMetric(
                                title: "БРОНЯ",
                                value: "\(gameState.aircraft.armor)",
                                icon: "shield.fill",
                                color: .blue,
                                progress: nil
                            )
                            
                            DashboardMetric(
                                title: "ОРУЖИЕ",
                                value: "\(gameState.aircraft.firepower)",
                                icon: "scope",
                                color: .red,
                                progress: nil
                            )
                        }
                        
                        HStack(spacing: 20) {
                            DashboardMetric(
                                title: "СКОРОСТЬ",
                                value: "\(gameState.aircraft.speed)",
                                icon: "speedometer",
                                color: .purple,
                                progress: nil
                            )
                            
                            DashboardMetric(
                                title: "ГРУЗ",
                                value: "\(gameState.aircraft.cargo)",
                                icon: "shippingbox.fill",
                                color: .orange,
                                progress: nil
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Кнопки управления
                    VStack(spacing: 15) {
                        Text("УПРАВЛЕНИЕ")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                ActionButton(
                                    title: "ЗАПРАВИТЬ",
                                    icon: "fuelpump.fill",
                                    color: .blue,
                                    action: { handleRefuel() }
                                )
                                
                                ActionButton(
                                    title: "РЕМОНТ",
                                    icon: "hammer.fill",
                                    color: .orange,
                                    action: { handleRepair() }
                                )
                            }
                            
                            ActionButton(
                                title: "АПГРЕЙД",
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
        // Рассчитываем сколько топлива нужно
        let fuelNeeded = gameState.economy.calculateRefuelNeeded(
            currentFuel: gameState.aircraft.fuel,
            maxFuel: gameState.aircraft.maxFuel
        )
        
        // Ограничиваем до доступного количества
        let fuelToAdd = min(fuelNeeded, gameState.economy.fuelUnits)
        
        guard fuelToAdd > 0 else {
            // Показать сообщение о недостатке топлива или что бак полон
            return
        }
        
        // Показываем попап
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
        
        // Проверяем есть ли ремкомплекты
        guard !gameState.economy.repairKits.isEmpty else {
            // Можно показать сообщение что нет ремкомплектов
            return
        }
        
        // Показываем попап подтверждения
        showRepairConfirmation = true
    }
    
    private func performRepair(with kit: RepairKit) {
        withAnimation(.spring(response: 0.5)) {
            // Используем ремкомплект из инвентаря
            if gameState.economy.useRepairKit(kit) {
                // Восстанавливаем здоровье
                gameState.aircraftVM.repair(amount: kit.type.healthRestore)
                
                // Применяем бонусы
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
                // Иконка
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
                    Text("ДОЗАПРАВКА")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Подтвердите заправку самолёта")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                // Информация о топливе
                VStack(spacing: 16) {
                    // Текущее состояние
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ТЕКУЩЕЕ ТОПЛИВО")
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
                            Text("ПОСЛЕ ЗАПРАВКИ")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            Text(String(format: "%.0f%%", newFuelPercentage))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                        }
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    // Стоимость
                    HStack {
                        Image(systemName: "fuelpump.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                            .frame(width: 30)
                        
                        Text("Топливо")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text("-\(fuelNeeded)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.red)
                            
                            Text("(\(availableFuel) доступно)")
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
                
                // Кнопки
                VStack(spacing: 12) {
                    Button(action: {
                        onConfirm()
                        dismiss()
                    }) {
                        Text("ПРИНЯТЬ")
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
                        Text("Отмена")
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
                // Иконка
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
                    Text("РЕМОНТ")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Выберите ремкомплект для использования")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                // Текущее состояние здоровья
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ТЕКУЩЕЕ ЗДОРОВЬЕ")
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
                            Text("ПОСЛЕ РЕМОНТА")
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
                
                // Список ремкомплектов
                ScrollView {
                    VStack(spacing: 12) {
                        if groupedKits.isEmpty {
                            Text("Нет доступных ремкомплектов")
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
                
                // Кнопки
                VStack(spacing: 12) {
                    Button(action: {
                        if let kit = selectedKit {
                            onConfirm(kit)
                            dismiss()
                        }
                    }) {
                        Text(selectedKit != nil ? "ИСПОЛЬЗОВАТЬ" : "ВЫБЕРИТЕ РЕМКОМПЛЕКТ")
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
                        Text("Отмена")
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
                // Иконка
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.orange.opacity(0.3) : Color.white.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .orange : .white)
                }
                
                // Информация
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
                
                // Количество
                VStack(spacing: 4) {
                    Text("×\(count)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? .orange : .white)
                    
                    Text("в наличии")
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
            // Иконка
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            // Значение
            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // Заголовок
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
            
            // Прогресс-бар (если есть)
            if let progress = progress {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Фон прогресс-бара
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)
                        
                        // Прогресс
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
