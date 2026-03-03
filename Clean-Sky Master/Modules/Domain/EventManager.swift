//
//  EventManager.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import Foundation
import Combine

/// Manager for random game events
class EventManager: ObservableObject {
    @Published var currentEvent: GameEvent?
    @Published var showEvent: Bool = false
    
    private var availableEvents: [GameEvent] = GameEvent.sampleEvents
    private var eventHistory: [UUID] = []
    private let maxHistorySize = 5
    
    /// Triggers a random event
    func triggerRandomEvent() {
        // Filter events that were recently shown
        let unusedEvents = availableEvents.filter { event in
            !eventHistory.contains(event.id)
        }
        
        // If all events were shown, clear history
        let eventsToChooseFrom = unusedEvents.isEmpty ? availableEvents : unusedEvents
        
        guard let event = eventsToChooseFrom.randomElement() else { return }
        
        currentEvent = event
        showEvent = true
        
        // Add to history
        eventHistory.append(event.id)
        if eventHistory.count > maxHistorySize {
            eventHistory.removeFirst()
        }
    }
    
    /// Triggers an event of specific type
    func triggerEvent(ofType type: EventType) {
        let eventsOfType = availableEvents.filter { $0.type == type }
        guard let event = eventsOfType.randomElement() else { return }
        
        currentEvent = event
        showEvent = true
        eventHistory.append(event.id)
    }
    
    /// Closes the current event
    func dismissEvent() {
        showEvent = false
        currentEvent = nil
    }
    
    /// Returns the probability of an event occurring (can be used for automatic events)
    func shouldTriggerRandomEvent(baseProbability: Double = 0.1) -> Bool {
        return Double.random(in: 0...1) < baseProbability
    }
}

// MARK: - Event Extensions

extension GameEvent {
    /// Additional events for variety
    static var additionalEvents: [GameEvent] {
        [
            GameEvent(
                type: .discovery,
                title: "TALENTED PILOT",
                description: "Your reputation has attracted the attention of a talented young pilot. He wants to join your fleet.",
                choices: [
                    EventChoice(
                        text: "Hire the pilot",
                        consequence: EventConsequence(
                            description: "New pilot has joined the team! Now you can perform more missions.",
                            fuelChange: nil,
                            healthChange: nil,
                            moneyChange: -200,
                            experienceChange: 100
                        )
                    ),
                    EventChoice(
                        text: "Decline",
                        consequence: EventConsequence(
                            description: "Perhaps you'll reconsider this decision later.",
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
                title: "BIRD FLOCK",
                description: "Air traffic control warns of a large flock of birds at your flight level.",
                choices: [
                    EventChoice(
                        text: "Change altitude",
                        consequence: EventConsequence(
                            description: "Maneuver executed successfully. The flock is left behind.",
                            fuelChange: -5,
                            healthChange: nil,
                            moneyChange: nil,
                            experienceChange: 30
                        )
                    ),
                    EventChoice(
                        text: "Continue at current altitude",
                        consequence: EventConsequence(
                            description: "Risky decision! Fortunately, collision was avoided.",
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
                title: "RADIO FAILURE",
                description: "Communication with the control tower has suddenly been lost. You must proceed using visual signals.",
                choices: nil,
                autoConsequence: EventConsequence(
                    description: "Communication restored after 10 minutes. That was a tense time.",
                    fuelChange: nil,
                    healthChange: -5,
                    moneyChange: nil,
                    experienceChange: 60
                )
            ),
            
            GameEvent(
                type: .opportunity,
                title: "ADVERTISING OFFER",
                description: "A company wants to place advertisements on your aircraft. They're offering a good sum.",
                choices: [
                    EventChoice(
                        text: "Accept the offer",
                        consequence: EventConsequence(
                            description: "Contract signed! Regular income secured.",
                            fuelChange: nil,
                            healthChange: nil,
                            moneyChange: 700,
                            experienceChange: nil
                        )
                    ),
                    EventChoice(
                        text: "Decline",
                        consequence: EventConsequence(
                            description: "You've maintained the clean appearance of your aircraft.",
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
                title: "ACCIDENT-FREE RECORD",
                description: "Congratulations! You've flown 1000 hours without a single accident. This is an outstanding achievement!",
                choices: nil,
                autoConsequence: EventConsequence(
                    description: "Flight safety bonus received!",
                    fuelChange: nil,
                    healthChange: 10,
                    moneyChange: 1500,
                    experienceChange: 300
                )
            )
        ]
    }
    
    /// All available events
    static var allEvents: [GameEvent] {
        sampleEvents + additionalEvents
    }
}
