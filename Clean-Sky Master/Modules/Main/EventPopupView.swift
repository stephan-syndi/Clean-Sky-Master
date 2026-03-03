//
//  EventPopupView.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import SwiftUI

// MARK: - Event Models
// NOTE: Это активная версия моделей событий.
// Другая версия в Models/EconomyModel.swift планируется для будущей реализации.

enum EventType {
    case accident
    case discovery
    case opportunity
    case warning
    case achievement
    
    var color: Color {
        switch self {
        case .accident: return .red
        case .discovery: return .yellow
        case .opportunity: return .green
        case .warning: return .orange
        case .achievement: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .accident: return "exclamationmark.triangle.fill"
        case .discovery: return "sparkles"
        case .opportunity: return "gift.fill"
        case .warning: return "exclamationmark.circle.fill"
        case .achievement: return "trophy.fill"
        }
    }
}

struct EventChoice {
    let id = UUID()
    let text: String
    let consequence: EventConsequence
}

struct EventConsequence {
    let description: String
    let fuelChange: Double?
    let healthChange: Double?
    let moneyChange: Int?
    let experienceChange: Int?
}

struct GameEvent {
    let id = UUID()
    let type: EventType
    let title: String
    let description: String
    let choices: [EventChoice]?
    let autoConsequence: EventConsequence?
}

// MARK: - Event Popup View

struct EventPopupView: View {
    let event: GameEvent
    let onChoice: (EventChoice?) -> Void
    @State private var selectedChoice: EventChoice?
    @State private var showResult = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Затемнённый фон
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    if event.choices == nil && !showResult {
                        dismissPopup()
                    }
                }
            
            VStack(spacing: 0) {
                // Карточка события
                VStack(spacing: 20) {
                    // Иконка
                    ZStack {
                        Circle()
                            .fill(event.type.color.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: event.type.icon)
                            .font(.system(size: 40))
                            .foregroundColor(event.type.color)
                    }
                    .scaleEffect(scale)
                    .opacity(opacity)
                    
                    // Заголовок
                    Text(event.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(opacity)
                    
                    // Описание
                    Text(event.description)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 8)
                        .opacity(opacity)
                    
                    // Показываем результат выбора
                    if showResult, let choice = selectedChoice {
                        ResultView(consequence: choice.consequence)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Варианты выбора или кнопка закрытия
                    if !showResult {
                        if let choices = event.choices {
                            ChoicesView(choices: choices) { choice in
                                handleChoice(choice)
                            }
                            .opacity(opacity)
                        } else {
                            // Событие без выбора
                            Button(action: {
                                dismissPopup()
                            }) {
                                Text("Понятно")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(event.type.color)
                                    )
                            }
                            .padding(.horizontal)
                            .opacity(opacity)
                        }
                    } else {
                        // Кнопка продолжить после выбора
                        Button(action: {
                            dismissPopup()
                        }) {
                            Text("Продолжить")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(event.type.color)
                                )
                        }
                        .padding(.horizontal)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(28)
                .frame(maxWidth: 400)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(red: 0.08, green: 0.12, blue: 0.22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(event.type.color.opacity(0.5), lineWidth: 2)
                        )
                        .shadow(color: event.type.color.opacity(0.3), radius: 20, y: 10)
                )
                .scaleEffect(scale)
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
    
    private func handleChoice(_ choice: EventChoice) {
        selectedChoice = choice
        withAnimation(.spring(response: 0.4)) {
            showResult = true
        }
    }
    
    private func dismissPopup() {
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 0.8
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onChoice(selectedChoice)
        }
    }
}

// MARK: - Choices View

struct ChoicesView: View {
    let choices: [EventChoice]
    let onSelect: (EventChoice) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(choices.enumerated()), id: \.element.id) { index, choice in
                Button(action: {
                    onSelect(choice)
                }) {
                    HStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("\(index + 1)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        Text(choice.text)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Result View

struct ResultView: View {
    let consequence: EventConsequence
    
    var body: some View {
        VStack(spacing: 16) {
            Text(consequence.description)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Показываем изменения
            VStack(spacing: 8) {
                if let fuelChange = consequence.fuelChange {
                    ChangeIndicator(
                        icon: "fuelpump.fill",
                        label: "Топливо",
                        value: fuelChange,
                        suffix: "%",
                        color: fuelChange > 0 ? .green : .red
                    )
                }
                
                if let healthChange = consequence.healthChange {
                    ChangeIndicator(
                        icon: "wrench.and.screwdriver.fill",
                        label: "Здоровье",
                        value: healthChange,
                        suffix: "%",
                        color: healthChange > 0 ? .cyan : .red
                    )
                }
                
                if let moneyChange = consequence.moneyChange {
                    ChangeIndicator(
                        icon: "star.fill",
                        label: "Очки",
                        value: Double(moneyChange),
                        suffix: "",
                        color: moneyChange > 0 ? .yellow : .red
                    )
                }
                
                if let expChange = consequence.experienceChange {
                    ChangeIndicator(
                        icon: "chart.line.uptrend.xyaxis",
                        label: "Опыт",
                        value: Double(expChange),
                        suffix: " XP",
                        color: .purple
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
        )
        .padding(.horizontal)
    }
}

// MARK: - Change Indicator

struct ChangeIndicator: View {
    let icon: String
    let label: String
    let value: Double
    let suffix: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 4) {
                Image(systemName: value > 0 ? "arrow.up" : "arrow.down")
                    .font(.system(size: 12, weight: .bold))
                
                Text("\(value > 0 ? "+" : "")\(Int(value))\(suffix)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Sample Events

extension GameEvent {
    static var sampleEvents: [GameEvent] {
        [
            // Авария
            GameEvent(
                type: .accident,
                title: "ОТКАЗ ДВИГАТЕЛЯ!",
                description: "Во время полёта произошёл частичный отказ левого двигателя. Требуется принять решение.",
                choices: [
                    EventChoice(
                        text: "Экстренная посадка в ближайшем аэропорту",
                        consequence: EventConsequence(
                            description: "Вы успешно совершили вынужденную посадку. Самолёт требует ремонта.",
                            fuelChange: -10,
                            healthChange: -15,
                            moneyChange: -200,
                            experienceChange: 50
                        )
                    ),
                    EventChoice(
                        text: "Попытаться долететь до пункта назначения",
                        consequence: EventConsequence(
                            description: "Рискованный манёвр! Вам удалось долететь, но самолёт сильно пострадал.",
                            fuelChange: -20,
                            healthChange: -30,
                            moneyChange: 100,
                            experienceChange: 100
                        )
                    )
                ],
                autoConsequence: nil
            ),
            
            // Находка
            GameEvent(
                type: .discovery,
                title: "НЕОБЫЧНАЯ НАХОДКА",
                description: "Во время осмотра самолёта механик обнаружил спрятанный тайник с ценностями!",
                choices: [
                    EventChoice(
                        text: "Забрать находку себе",
                        consequence: EventConsequence(
                            description: "Вы нашли 500 очков! Однако это может привлечь нежелательное внимание.",
                            fuelChange: nil,
                            healthChange: nil,
                            moneyChange: 500,
                            experienceChange: nil
                        )
                    ),
                    EventChoice(
                        text: "Передать находку властям",
                        consequence: EventConsequence(
                            description: "Власти отблагодарили вас за честность и выдали награду. Репутация повышена!",
                            fuelChange: nil,
                            healthChange: nil,
                            moneyChange: 300,
                            experienceChange: 75
                        )
                    )
                ],
                autoConsequence: nil
            ),
            
            // Возможность
            GameEvent(
                type: .opportunity,
                title: "СРОЧНЫЙ ЗАКАЗ",
                description: "Поступил срочный заказ на VIP-доставку. Требуется немедленный вылет, но вознаграждение щедрое.",
                choices: [
                    EventChoice(
                        text: "Принять заказ",
                        consequence: EventConsequence(
                            description: "Успешно выполнили срочную доставку! Клиент очень доволен.",
                            fuelChange: -30,
                            healthChange: -5,
                            moneyChange: 800,
                            experienceChange: 120
                        )
                    ),
                    EventChoice(
                        text: "Отказаться от заказа",
                        consequence: EventConsequence(
                            description: "Вы решили отдохнуть. Это был мудрый выбор для восстановления сил.",
                            fuelChange: 10,
                            healthChange: 10,
                            moneyChange: nil,
                            experienceChange: nil
                        )
                    )
                ],
                autoConsequence: nil
            ),
            
            // Предупреждение
            GameEvent(
                type: .warning,
                title: "МЕТЕОПРЕДУПРЕЖДЕНИЕ",
                description: "Синоптики предупреждают о надвигающемся шторме на вашем маршруте через 2 часа.",
                choices: nil,
                autoConsequence: EventConsequence(
                    description: "Вы получили предупреждение вовремя. Рекомендуется отложить полёт или изменить маршрут.",
                    fuelChange: nil,
                    healthChange: nil,
                    moneyChange: nil,
                    experienceChange: 10
                )
            ),
            
            // Достижение
            GameEvent(
                type: .achievement,
                title: "НОВЫЙ РЕКОРД!",
                description: "Поздравляем! Вы совершили 100-й успешный полёт. Ваш профессионализм растёт!",
                choices: nil,
                autoConsequence: EventConsequence(
                    description: "Получена награда за выдающиеся достижения в авиации!",
                    fuelChange: nil,
                    healthChange: nil,
                    moneyChange: 1000,
                    experienceChange: 250
                )
            ),
            
            // Авария простая
            GameEvent(
                type: .accident,
                title: "ПОВРЕЖДЕНИЕ ШАССИ",
                description: "При посадке произошёл сильный удар. Шасси повреждено, требуется срочный ремонт.",
                choices: nil,
                autoConsequence: EventConsequence(
                    description: "Самолёт отправлен на ремонт. Придётся потратиться на восстановление.",
                    fuelChange: nil,
                    healthChange: -25,
                    moneyChange: -350,
                    experienceChange: nil
                )
            ),
            
            // Находка простая
            GameEvent(
                type: .discovery,
                title: "БОНУС ОТ СПОНСОРА",
                description: "Ваш основной спонсор впечатлён вашими результатами и выделил дополнительное финансирование!",
                choices: nil,
                autoConsequence: EventConsequence(
                    description: "Получен бонус от спонсора!",
                    fuelChange: nil,
                    healthChange: nil,
                    moneyChange: 600,
                    experienceChange: 50
                )
            ),
            
            // Выбор с риском
            GameEvent(
                type: .opportunity,
                title: "ЭКСПЕРИМЕНТАЛЬНОЕ ТОПЛИВО",
                description: "Поставщик предлагает протестировать новый вид экологичного топлива со скидкой 50%.",
                choices: [
                    EventChoice(
                        text: "Согласиться на эксперимент",
                        consequence: EventConsequence(
                            description: "Эксперимент удался! Топливо показало отличные результаты, эффективность выросла.",
                            fuelChange: 20,
                            healthChange: 5,
                            moneyChange: -100,
                            experienceChange: 80
                        )
                    ),
                    EventChoice(
                        text: "Использовать обычное топливо",
                        consequence: EventConsequence(
                            description: "Вы остались при своём. Надёжность проверенного топлива важнее экспериментов.",
                            fuelChange: nil,
                            healthChange: nil,
                            moneyChange: -200,
                            experienceChange: nil
                        )
                    ),
                    EventChoice(
                        text: "Отложить заправку",
                        consequence: EventConsequence(
                            description: "Решили подождать лучших условий.",
                            fuelChange: nil,
                            healthChange: nil,
                            moneyChange: nil,
                            experienceChange: nil
                        )
                    )
                ],
                autoConsequence: nil
            )
        ]
    }
}

// MARK: - Preview

#Preview {
    EventPopupView(event: GameEvent.sampleEvents[0]) { choice in
        print("Selected: \(choice?.text ?? "none")")
    }
}

#Preview("No Choice Event") {
    EventPopupView(event: GameEvent.sampleEvents[3]) { choice in
        print("Dismissed")
    }
}
