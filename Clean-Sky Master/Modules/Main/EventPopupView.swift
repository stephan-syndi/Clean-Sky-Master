//
//  EventPopupView.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import SwiftUI

// MARK: - Event Models
// NOTE: This is the active version of event models.
// Another version in Models/EconomyModel.swift is planned for future implementation.

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
            // Darkened background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    if event.choices == nil && !showResult {
                        dismissPopup()
                    }
                }
            
            VStack(spacing: 0) {
                // Event card
                VStack(spacing: 20) {
                    // Icon
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
                    
                    // Title
                    Text(event.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(opacity)
                    
                    // Description
                    Text(event.description)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 8)
                        .opacity(opacity)
                    
                    // Show choice result
                    if showResult, let choice = selectedChoice {
                        ResultView(consequence: choice.consequence)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Choice options or close button
                    if !showResult {
                        if let choices = event.choices {
                            ChoicesView(choices: choices) { choice in
                                handleChoice(choice)
                            }
                            .opacity(opacity)
                        } else {
                            // Event without choice
                            Button(action: {
                                dismissPopup()
                            }) {
                                Text("Understood")
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
                        // Continue button after choice
                        Button(action: {
                            dismissPopup()
                        }) {
                            Text("Continue")
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
            
            // Show changes
            VStack(spacing: 8) {
                if let fuelChange = consequence.fuelChange {
                    ChangeIndicator(
                        icon: "fuelpump.fill",
                        label: "Fuel",
                        value: fuelChange,
                        suffix: "%",
                        color: fuelChange > 0 ? .green : .red
                    )
                }
                
                if let healthChange = consequence.healthChange {
                    ChangeIndicator(
                        icon: "wrench.and.screwdriver.fill",
                        label: "Health",
                        value: healthChange,
                        suffix: "%",
                        color: healthChange > 0 ? .cyan : .red
                    )
                }
                
                if let moneyChange = consequence.moneyChange {
                    ChangeIndicator(
                        icon: "star.fill",
                        label: "Points",
                        value: Double(moneyChange),
                        suffix: "",
                        color: moneyChange > 0 ? .yellow : .red
                    )
                }
                
                if let expChange = consequence.experienceChange {
                    ChangeIndicator(
                        icon: "chart.line.uptrend.xyaxis",
                        label: "Experience",
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
            // Accident
            GameEvent(
                type: .accident,
                title: "ENGINE FAILURE!",
                description: "During flight, a partial failure of the left engine occurred. A decision is required.",
                choices: [
                    EventChoice(
                        text: "Emergency landing at the nearest airport",
                        consequence: EventConsequence(
                            description: "You successfully made an emergency landing. The aircraft requires repair.",
                            fuelChange: -10,
                            healthChange: -15,
                            moneyChange: -200,
                            experienceChange: 50
                        )
                    ),
                    EventChoice(
                        text: "Attempt to reach the destination",
                        consequence: EventConsequence(
                            description: "Risky maneuver! You managed to reach your destination, but the aircraft was heavily damaged.",
                            fuelChange: -20,
                            healthChange: -30,
                            moneyChange: 100,
                            experienceChange: 100
                        )
                    )
                ],
                autoConsequence: nil
            ),
            
            // Discovery
            GameEvent(
                type: .discovery,
                title: "UNUSUAL DISCOVERY",
                description: "During aircraft inspection, the mechanic discovered a hidden cache of valuables!",
                choices: [
                    EventChoice(
                        text: "Keep the find for yourself",
                        consequence: EventConsequence(
                            description: "You found 500 points! However, this may attract unwanted attention.",
                            fuelChange: nil,
                            healthChange: nil,
                            moneyChange: 500,
                            experienceChange: nil
                        )
                    ),
                    EventChoice(
                        text: "Turn the find over to authorities",
                        consequence: EventConsequence(
                            description: "The authorities thanked you for your honesty and issued a reward. Reputation increased!",
                            fuelChange: nil,
                            healthChange: nil,
                            moneyChange: 300,
                            experienceChange: 75
                        )
                    )
                ],
                autoConsequence: nil
            ),
            
            // Opportunity
            GameEvent(
                type: .opportunity,
                title: "URGENT ORDER",
                description: "An urgent VIP delivery order has been received. Immediate departure required, but the reward is generous.",
                choices: [
                    EventChoice(
                        text: "Accept the order",
                        consequence: EventConsequence(
                            description: "Successfully completed urgent delivery! Client is very satisfied.",
                            fuelChange: -30,
                            healthChange: -5,
                            moneyChange: 800,
                            experienceChange: 120
                        )
                    ),
                    EventChoice(
                        text: "Decline the order",
                        consequence: EventConsequence(
                            description: "You decided to rest. This was a wise choice for recovery.",
                            fuelChange: 10,
                            healthChange: 10,
                            moneyChange: nil,
                            experienceChange: nil
                        )
                    )
                ],
                autoConsequence: nil
            ),
            
            // Warning
            GameEvent(
                type: .warning,
                title: "WEATHER WARNING",
                description: "Weather forecasters warn of an approaching storm on your route in 2 hours.",
                choices: nil,
                autoConsequence: EventConsequence(
                    description: "You received the warning in time. It is recommended to postpone the flight or change the route.",
                    fuelChange: nil,
                    healthChange: nil,
                    moneyChange: nil,
                    experienceChange: 10
                )
            ),
            
            // Achievement
            GameEvent(
                type: .achievement,
                title: "NEW RECORD!",
                description: "Congratulations! You have completed your 100th successful flight. Your professionalism is growing!",
                choices: nil,
                autoConsequence: EventConsequence(
                    description: "Received award for outstanding achievements in aviation!",
                    fuelChange: nil,
                    healthChange: nil,
                    moneyChange: 1000,
                    experienceChange: 250
                )
            ),
            
            // Simple accident
            GameEvent(
                type: .accident,
                title: "LANDING GEAR DAMAGE",
                description: "A strong impact occurred during landing. Landing gear damaged, urgent repair required.",
                choices: nil,
                autoConsequence: EventConsequence(
                    description: "Aircraft sent for repair. Will have to spend on restoration.",
                    fuelChange: nil,
                    healthChange: -25,
                    moneyChange: -350,
                    experienceChange: nil
                )
            ),
            
            // Simple discovery
            GameEvent(
                type: .discovery,
                title: "SPONSOR BONUS",
                description: "Your main sponsor is impressed with your results and has allocated additional funding!",
                choices: nil,
                autoConsequence: EventConsequence(
                    description: "Received bonus from sponsor!",
                    fuelChange: nil,
                    healthChange: nil,
                    moneyChange: 600,
                    experienceChange: 50
                )
            ),
            
            // Choice with risk
            GameEvent(
                type: .opportunity,
                title: "EXPERIMENTAL FUEL",
                description: "The supplier offers to test a new type of eco-friendly fuel at a 50% discount.",
                choices: [
                    EventChoice(
                        text: "Agree to the experiment",
                        consequence: EventConsequence(
                            description: "Experiment succeeded! The fuel showed excellent results, efficiency increased.",
                            fuelChange: 20,
                            healthChange: 5,
                            moneyChange: -100,
                            experienceChange: 80
                        )
                    ),
                    EventChoice(
                        text: "Use regular fuel",
                        consequence: EventConsequence(
                            description: "You stuck with what you know. The reliability of proven fuel is more important than experiments.",
                            fuelChange: nil,
                            healthChange: nil,
                            moneyChange: -200,
                            experienceChange: nil
                        )
                    ),
                    EventChoice(
                        text: "Postpone refueling",
                        consequence: EventConsequence(
                            description: "Decided to wait for better conditions.",
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
