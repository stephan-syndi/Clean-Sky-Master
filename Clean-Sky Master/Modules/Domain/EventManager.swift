//
//  EventManager.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import Foundation
import Combine

/// Менеджер случайных событий в игре
class EventManager: ObservableObject {
    @Published var currentEvent: GameEvent?
    @Published var showEvent: Bool = false
    
    private var availableEvents: [GameEvent] = GameEvent.sampleEvents
    private var eventHistory: [UUID] = []
    private let maxHistorySize = 5
    
    /// Запускает случайное событие
    func triggerRandomEvent() {
        // Фильтруем события, которые недавно показывались
        let unusedEvents = availableEvents.filter { event in
            !eventHistory.contains(event.id)
        }
        
        // Если все события были показаны, очищаем историю
        let eventsToChooseFrom = unusedEvents.isEmpty ? availableEvents : unusedEvents
        
        guard let event = eventsToChooseFrom.randomElement() else { return }
        
        currentEvent = event
        showEvent = true
        
        // Добавляем в историю
        eventHistory.append(event.id)
        if eventHistory.count > maxHistorySize {
            eventHistory.removeFirst()
        }
    }
    
    /// Запускает событие определённого типа
    func triggerEvent(ofType type: EventType) {
        let eventsOfType = availableEvents.filter { $0.type == type }
        guard let event = eventsOfType.randomElement() else { return }
        
        currentEvent = event
        showEvent = true
        eventHistory.append(event.id)
    }
    
    /// Закрывает текущее событие
    func dismissEvent() {
        showEvent = false
        currentEvent = nil
    }
    
    /// Возвращает вероятность появления события (можно использовать для автоматических событий)
    func shouldTriggerRandomEvent(baseProbability: Double = 0.1) -> Bool {
        return Double.random(in: 0...1) < baseProbability
    }
}

// MARK: - Event Extensions

extension GameEvent {
    /// Дополнительные события для разнообразия
    static var additionalEvents: [GameEvent] {
        [
            GameEvent(
                type: .discovery,
                title: "ТАЛАНТЛИВЫЙ ПИЛОТ",
                description: "Ваша репутация привлекла внимание талантливого молодого пилота. Он хочет присоединиться к вашему флоту.",
                choices: [
                    EventChoice(
                        text: "Взять пилота в команду",
                        consequence: EventConsequence(
                            description: "Новый пилот присоединился к команде! Теперь вы можете выполнять больше миссий.",
                            fuelChange: nil,
                            healthChange: nil,
                            moneyChange: -200,
                            experienceChange: 100
                        )
                    ),
                    EventChoice(
                        text: "Отказать",
                        consequence: EventConsequence(
                            description: "Возможно, это решение вы ещё пересмотрите.",
                            fuelChange: nil,
                            healthChange: nil,
                            moneyChange: nil,
                            experienceChange: nil
                        )
                    )
                ],
                autoConsequence: nil
            ),
            
            GameEvent(
                type: .warning,
                title: "ПТИЧЬЯ СТАЯ",
                description: "Диспетчер предупреждает о большой стае птиц на вашем эшелоне.",
                choices: [
                    EventChoice(
                        text: "Изменить высоту",
                        consequence: EventConsequence(
                            description: "Маневр выполнен успешно. Стая осталась позади.",
                            fuelChange: -5,
                            healthChange: nil,
                            moneyChange: nil,
                            experienceChange: 30
                        )
                    ),
                    EventChoice(
                        text: "Продолжить на текущей высоте",
                        consequence: EventConsequence(
                            description: "Рискованное решение! К счастью, столкновения удалось избежать.",
                            fuelChange: nil,
                            healthChange: -10,
                            moneyChange: nil,
                            experienceChange: 50
                        )
                    )
                ],
                autoConsequence: nil
            ),
            
            GameEvent(
                type: .accident,
                title: "ОТКАЗ РАДИОСВЯЗИ",
                description: "Внезапно пропала связь с диспетчерской вышкой. Необходимо действовать по визуальным сигналам.",
                choices: nil,
                autoConsequence: EventConsequence(
                    description: "Связь восстановлена через 10 минут. Это было напряжённое время.",
                    fuelChange: nil,
                    healthChange: -5,
                    moneyChange: nil,
                    experienceChange: 60
                )
            ),
            
            GameEvent(
                type: .opportunity,
                title: "РЕКЛАМНОЕ ПРЕДЛОЖЕНИЕ",
                description: "Компания хочет разместить рекламу на вашем самолёте. Предлагают неплохую сумму.",
                choices: [
                    EventChoice(
                        text: "Принять предложение",
                        consequence: EventConsequence(
                            description: "Контракт подписан! Регулярный доход обеспечен.",
                            fuelChange: nil,
                            healthChange: nil,
                            moneyChange: 700,
                            experienceChange: nil
                        )
                    ),
                    EventChoice(
                        text: "Отклонить",
                        consequence: EventConsequence(
                            description: "Вы сохранили чистый облик своего самолёта.",
                            fuelChange: nil,
                            healthChange: nil,
                            moneyChange: nil,
                            experienceChange: nil
                        )
                    )
                ],
                autoConsequence: nil
            ),
            
            GameEvent(
                type: .achievement,
                title: "БЕЗАВАРИЙНЫЙ СТАЖ",
                description: "Поздравляем! Вы налетали 1000 часов без единой аварии. Это выдающееся достижение!",
                choices: nil,
                autoConsequence: EventConsequence(
                    description: "Получена премия за безопасность полётов!",
                    fuelChange: nil,
                    healthChange: 10,
                    moneyChange: 1500,
                    experienceChange: 300
                )
            )
        ]
    }
    
    /// Все доступные события
    static var allEvents: [GameEvent] {
        sampleEvents + additionalEvents
    }
}
