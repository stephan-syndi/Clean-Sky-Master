//
//  MissionTemplates.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import Foundation
import SwiftUI

// MARK: - Mission Category

enum MissionCategory: String, CaseIterable, Codable {
    case patrol = "Patrol"
    case smuggling = "Smuggling"
    case bossHunt = "Hunt"
    case storm = "Storm"
    case rescue = "Rescue"
    case escort = "Escort"
    
    var icon: String {
        switch self {
        case .patrol: return "eye.fill"
        case .smuggling: return "questionmark.diamond.fill"
        case .bossHunt: return "target"
        case .storm: return "cloud.bolt.fill"
        case .rescue: return "cross.fill"
        case .escort: return "shield.lefthalf.filled"
        }
    }
    
    var color: Color {
        switch self {
        case .patrol: return .blue
        case .smuggling: return .orange
        case .bossHunt: return .red
        case .storm: return .purple
        case .rescue: return .green
        case .escort: return .cyan
        }
    }
}

// MARK: - Mission Modifier

enum MissionModifier: String {
    case none = ""
    case weather = "Bad Weather"
    case night = "Night Flight"
    case lowFuel = "Low Fuel"
    case damaged = "Damaged Aircraft"
    case timeLimit = "Strict Deadline"
    
    var description: String {
        switch self {
        case .none: return ""
        case .weather: return "Weather conditions complicate the mission"
        case .night: return "Night reduces visibility"
        case .lowFuel: return "Limited fuel supply"
        case .damaged: return "Aircraft damaged from the start"
        case .timeLimit: return "Time is limited"
        }
    }
    
    var difficultyModifier: Double {
        switch self {
        case .none: return 1.0
        case .weather: return 1.3
        case .night: return 1.2
        case .lowFuel: return 1.4
        case .damaged: return 1.5
        case .timeLimit: return 1.3
        }
    }
}

// MARK: - Mission Choice

struct MissionChoice {
    let id = UUID()
    let text: String
    let riskLevel: Double // 0.0 - 1.0
    let rewardMultiplier: Double
    let reportOutcome: String
}

// MARK: - Mission Template

struct MissionTemplate {
    let category: MissionCategory
    let name: String
    let briefing: String
    let baseReward: Int
    let baseDifficulty: Double
    let minBattleRating: Int // Minimum BR
    let requiredModules: [String] // Special modules
    let choices: [MissionChoice]? // Choice in mission
    let modifier: MissionModifier
    
    // Report generation
    func generateReport(success: Bool, choiceIndex: Int? = nil, damage: Double = 0, lootFound: Int = 0) -> String {
        var report = ""
        
        // Report header
        switch category {
        case .patrol:
            report += "[ PATROL REPORT ]\n\n"
        case .smuggling:
            report += "[ CONFIDENTIAL REPORT ]\n\n"
        case .bossHunt:
            report += "[ COMBAT REPORT ]\n\n"
        case .storm:
            report += "[ EMERGENCY REPORT ]\n\n"
        case .rescue:
            report += "[ RESCUE OPERATION ]\n\n"
        case .escort:
            report += "[ ESCORT REPORT ]\n\n"
        }
        
        // Modifier
        if modifier != .none {
            report += "⚠️ \(modifier.rawValue): \(modifier.description)\n\n"
        }
        
        // Main mission story
        if success {
            report += generateSuccessReport(choiceIndex: choiceIndex, lootFound: lootFound)
        } else {
            report += generateFailureReport(damage: damage)
        }
        
        // Conclusion
        report += "\n\n"
        if success {
            report += "✅ MISSION COMPLETED SUCCESSFULLY"
        } else {
            report += "❌ MISSION FAILED"
        }
        
        return report
    }
    
    private func generateSuccessReport(choiceIndex: Int?, lootFound: Int) -> String {
        var report = ""
        
        switch category {
        case .patrol:
            report += "Sector patrol completed without incidents. "
            if let choice = choiceIndex, let choices = choices {
                report += choices[choice].reportOutcome + " "
            }
            if lootFound > 0 {
                report += "\n\nAbandoned warehouse with resources discovered (+\(lootFound) credits). "
            }
            report += "\n\nAirspace cleared. All systems operating normally."
            
        case .smuggling:
            if let choice = choiceIndex, let choices = choices {
                report += choices[choice].reportOutcome
            } else {
                report += "Contraband cargo delivered to destination. Client is satisfied. No questions asked."
            }
            
        case .bossHunt:
            report += "CONTACT WITH TARGET ESTABLISHED!\n\n"
            report += "Enemy detected at coordinates [CLASSIFIED]. Air combat engaged.\n\n"
            report += "⚔️ COMBAT OPERATIONS:\n"
            report += "• 00:42 - First volley. Enemy maneuvering.\n"
            report += "• 01:15 - Direct hit! Damage to enemy.\n"
            report += "• 02:03 - Enemy counter-attack evaded.\n"
            report += "• 03:21 - Critical hit! Target destroyed.\n\n"
            report += "🏆 Rare modules extracted from wreckage."
            
        case .storm:
            report += "🌩️ EXTREME WEATHER CONDITIONS\n\n"
            report += "Storm front caught us at 7000 meters altitude. "
            report += "Lightning damaged radio communications. Instruments failed for 90 seconds.\n\n"
            report += "Pilot showed outstanding skill, flying blind. "
            report += "Broke through storm clouds. "
            report += "Cargo delivered intact, though hull took damage.\n\n"
            report += "⚡ That was a hell of a flight, but we made it."
            
        case .rescue:
            report += "Rescue operation completed on time.\n\n"
            report += "All victims evacuated from disaster zone. "
            report += "Medical assistance provided on board.\n\n"
            report += "🚑 Lives saved: \(Int.random(in: 5...15))"
            
        case .escort:
            report += "VIP client escorted successfully.\n\n"
            report += "Route completed without incidents. "
            report += "Client delivered safe and sound.\n\n"
            report += "💼 Premium received for quality service."
        }
        
        return report
    }
    
    private func generateFailureReport(damage: Double) -> String {
        var report = ""
        
        switch category {
        case .patrol:
            report += "Patrol interrupted due to technical malfunctions. "
            report += "Had to return to base early."
            
        case .smuggling:
            report += "⚠️ OPERATION FAILED\n\n"
            report += "Detected by border patrol. "
            report += "Cargo confiscated. Took damage trying to escape."
            
        case .bossHunt:
            report += "❌ COMBAT FAILURE\n\n"
            report += "Enemy was stronger than expected. "
            report += "Critical damage sustained. "
            report += "Forced retreat.\n\n"
            report += "Firepower upgrade required before retry."
            
        case .storm:
            report += "⚠️ EMERGENCY LANDING\n\n"
            report += "Storm was stronger than forecasts. "
            report += "Multiple system failures. "
            report += "Emergency landing at backup airport."
            
        case .rescue:
            report += "Rescue operation failed.\n\n"
            report += "Failed to reach disaster zone in time. "
            report += "Weather conditions forced return."
            
        case .escort:
            report += "Escort interrupted.\n\n"
            report += "Aircraft took damage. Client is displeased."
        }
        
        if damage > 0 {
            report += "\n\n💥 Damage sustained: \(Int(damage))%"
        }
        
        return report
    }
}

// MARK: - Mission Templates Library

struct MissionTemplatesLibrary {
    static let allTemplates: [MissionTemplate] = [
        // PATROLS
        MissionTemplate(
            category: .patrol,
            name: "Routine Patrol",
            briefing: "Standard territory flyover. Low risk, stable reward.",
            baseReward: 150,
            baseDifficulty: 0.8,
            minBattleRating: 0,
            requiredModules: [],
            choices: [
                MissionChoice(
                    text: "Follow route strictly",
                    riskLevel: 0.1,
                    rewardMultiplier: 1.0,
                    reportOutcome: "Route completed by protocol."
                ),
                MissionChoice(
                    text: "Investigate suspicious signal",
                    riskLevel: 0.4,
                    rewardMultiplier: 1.5,
                    reportOutcome: "Signal investigation revealed smugglers. Received bonus from authorities."
                )
            ],
            modifier: .none
        ),
        
        MissionTemplate(
            category: .patrol,
            name: "Terrain Reconnaissance",
            briefing: "Flyover of new territory for mapping.",
            baseReward: 180,
            baseDifficulty: 0.9,
            minBattleRating: 1,
            requiredModules: [],
            choices: [
                MissionChoice(
                    text: "Fly at safe altitude",
                    riskLevel: 0.15,
                    rewardMultiplier: 1.0,
                    reportOutcome: "Map completed. Terrain plotted on chart."
                ),
                MissionChoice(
                    text: "Fly low for detailed photography",
                    riskLevel: 0.35,
                    rewardMultiplier: 1.4,
                    reportOutcome: "Detailed photos obtained! Interesting objects discovered."
                )
            ],
            modifier: .none
        ),
        
        MissionTemplate(
            category: .escort,
            name: "Courier Escort",
            briefing: "Ensure safety of courier flight.",
            baseReward: 220,
            baseDifficulty: 1.0,
            minBattleRating: 2,
            requiredModules: [],
            choices: [
                MissionChoice(
                    text: "Fly standard route",
                    riskLevel: 0.25,
                    rewardMultiplier: 1.0,
                    reportOutcome: "Courier delivered on time."
                ),
                MissionChoice(
                    text: "Use roundabout path",
                    riskLevel: 0.1,
                    rewardMultiplier: 0.9,
                    reportOutcome: "Safe route chosen. Slight delay, but no incidents."
                )
            ],
            modifier: .none
        ),
        
        MissionTemplate(
            category: .patrol,
            name: "Night Watch",
            briefing: "Night-time patrol. Limited visibility.",
            baseReward: 200,
            baseDifficulty: 1.2,
            minBattleRating: 3,
            requiredModules: [],
            choices: nil,
            modifier: .night
        ),
        
        MissionTemplate(
            category: .rescue,
            name: "Search for Missing",
            briefing: "Find beacon signal from crashed aircraft.",
            baseReward: 280,
            baseDifficulty: 1.3,
            minBattleRating: 4,
            requiredModules: [],
            choices: [
                MissionChoice(
                    text: "Search in designated area",
                    riskLevel: 0.3,
                    rewardMultiplier: 1.0,
                    reportOutcome: "Beacon found in designated zone. Coordinates transmitted to rescuers."
                ),
                MissionChoice(
                    text: "Expand search area",
                    riskLevel: 0.5,
                    rewardMultiplier: 1.3,
                    reportOutcome: "Found survivors! Emergency evacuation completed."
                )
            ],
            modifier: .none
        ),
        
        MissionTemplate(
            category: .patrol,
            name: "Border Guard",
            briefing: "Border zone patrol.",
            baseReward: 320,
            baseDifficulty: 1.4,
            minBattleRating: 6,
            requiredModules: [],
            choices: [
                MissionChoice(
                    text: "Regular patrol",
                    riskLevel: 0.2,
                    rewardMultiplier: 1.0,
                    reportOutcome: "Patrol completed without incidents."
                ),
                MissionChoice(
                    text: "Intercept violator",
                    riskLevel: 0.6,
                    rewardMultiplier: 1.6,
                    reportOutcome: "Violator stopped! Border service thanks for assistance."
                )
            ],
            modifier: .none
        ),
        
        MissionTemplate(
            category: .escort,
            name: "VIP Protection",
            briefing: "Escort important person. Maximum attention required.",
            baseReward: 450,
            baseDifficulty: 1.6,
            minBattleRating: 8,
            requiredModules: [],
            choices: nil,
            modifier: .none
        ),
        
        // SMUGGLING
        MissionTemplate(
            category: .smuggling,
            name: "Contraband Flight",
            briefing: "Illegal cargo delivery. Risk of fine, but generous payment.",
            baseReward: 400,
            baseDifficulty: 1.5,
            minBattleRating: 10,
            requiredModules: [],
            choices: [
                MissionChoice(
                    text: "Avoid the patrol",
                    riskLevel: 0.3,
                    rewardMultiplier: 0.7,
                    reportOutcome: "Spotted patrol from distance and took detour. Cargo delivered safely, but used more fuel."
                ),
                MissionChoice(
                    text: "Take risk and fly direct",
                    riskLevel: 0.7,
                    rewardMultiplier: 1.3,
                    reportOutcome: "Broke through patrol zone! Cargo delivered, client is thrilled. Bonus to reward!"
                )
            ],
            modifier: .none
        ),
        
        MissionTemplate(
            category: .smuggling,
            name: "Shadow Delivery",
            briefing: "Secret delivery to conflict zone. High risk of detection.",
            baseReward: 600,
            baseDifficulty: 2.0,
            minBattleRating: 15,
            requiredModules: ["Radar Jammer"],
            choices: nil,
            modifier: .none
        ),
        
        // BOSS HUNTS
        MissionTemplate(
            category: .bossHunt,
            name: "Hunt for Crimson Baron",
            briefing: "Famous mercenary ace terrorizing trade routes. Eliminate the threat.",
            baseReward: 1000,
            baseDifficulty: 2.5,
            minBattleRating: 25,
            requiredModules: ["Enhanced Armament"],
            choices: nil,
            modifier: .none
        ),
        
        MissionTemplate(
            category: .bossHunt,
            name: "Operation Thunder",
            briefing: "Destroy enemy destroyer class Titan. Maximum firepower required.",
            baseReward: 1500,
            baseDifficulty: 3.0,
            minBattleRating: 35,
            requiredModules: ["Missile Launcher", "Enhanced Armor"],
            choices: [
                MissionChoice(
                    text: "Frontal attack",
                    riskLevel: 0.8,
                    rewardMultiplier: 1.2,
                    reportOutcome: "Head-on attack! Sustained serious damage, but powerful volley destroyed target."
                ),
                MissionChoice(
                    text: "Flanking maneuver",
                    riskLevel: 0.5,
                    rewardMultiplier: 1.0,
                    reportOutcome: "Stealthy approach from flank. Caught enemy off guard. Target destroyed with minimal losses."
                )
            ],
            modifier: .none
        ),
        
        // STORMS
        MissionTemplate(
            category: .storm,
            name: "Storm Assault",
            briefing: "Urgent medicine delivery through storm front. Extreme risk.",
            baseReward: 700,
            baseDifficulty: 2.2,
            minBattleRating: 20,
            requiredModules: [],
            choices: nil,
            modifier: .weather
        ),
        
        MissionTemplate(
            category: .storm,
            name: "Through the Hurricane",
            briefing: "Only chance to save blockaded city - fly through category 5 hurricane.",
            baseReward: 900,
            baseDifficulty: 2.8,
            minBattleRating: 30,
            requiredModules: ["Reinforced Hull"],
            choices: nil,
            modifier: .weather
        ),
        
        // RESCUE
        MissionTemplate(
            category: .rescue,
            name: "Mountain Rescue",
            briefing: "Evacuate climbers from peak. Difficult high-altitude conditions.",
            baseReward: 500,
            baseDifficulty: 1.8,
            minBattleRating: 12,
            requiredModules: [],
            choices: nil,
            modifier: .none
        ),
        
        MissionTemplate(
            category: .rescue,
            name: "Operation Phoenix",
            briefing: "Rescue survivors from plane crash. Limited time.",
            baseReward: 800,
            baseDifficulty: 2.3,
            minBattleRating: 18,
            requiredModules: ["Medical Bay"],
            choices: nil,
            modifier: .timeLimit
        ),
        
        // ESCORT
        MissionTemplate(
            category: .escort,
            name: "VIP Escort",
            briefing: "Escort important person. Reputation above all.",
            baseReward: 600,
            baseDifficulty: 1.5,
            minBattleRating: 15,
            requiredModules: [],
            choices: nil,
            modifier: .none
        ),
        
        MissionTemplate(
            category: .escort,
            name: "Convoy Guard",
            briefing: "Protect trade convoy from pirates. Attacks possible.",
            baseReward: 750,
            baseDifficulty: 2.0,
            minBattleRating: 22,
            requiredModules: ["Weapons"],
            choices: [
                MissionChoice(
                    text: "Defensive tactics",
                    riskLevel: 0.4,
                    rewardMultiplier: 0.9,
                    reportOutcome: "Stayed close to convoy. Repelled all attacks. Cargo intact, but no bonus."
                ),
                MissionChoice(
                    text: "Aggressive pursuit",
                    riskLevel: 0.7,
                    rewardMultiplier: 1.3,
                    reportOutcome: "Tracked down pirate base and destroyed it! Convoy safe. Premium from traders!"
                )
            ],
            modifier: .none
        )
    ]
    
    // Get random mission by difficulty
    static func getRandomMission(minDifficulty: Double = 0.0, maxDifficulty: Double = 3.0, battleRating: Int = 1) -> MissionTemplate {
        // Filter missions by difficulty AND BR (with small margin +3)
        let suitable = allTemplates.filter { 
            $0.baseDifficulty >= minDifficulty && 
            $0.baseDifficulty <= maxDifficulty &&
            $0.minBattleRating <= battleRating + 3 // Small margin for challenge
        }
        
        // If no suitable missions with BR consideration, take any by difficulty
        if suitable.isEmpty {
            let byDifficulty = allTemplates.filter { 
                $0.baseDifficulty >= minDifficulty && $0.baseDifficulty <= maxDifficulty 
            }
            return byDifficulty.randomElement() ?? allTemplates[0]
        }
        
        return suitable.randomElement() ?? allTemplates[0]
    }
    
    // Get missions by category
    static func getMissionsByCategory(_ category: MissionCategory) -> [MissionTemplate] {
        return allTemplates.filter { $0.category == category }
    }
    
    // Check mission availability
    static func canStartMission(template: MissionTemplate, battleRating: Int, modules: [String]) -> (canStart: Bool, reason: String?) {
        // BR check
        if battleRating < template.minBattleRating {
            return (false, "BR ≥ \(template.minBattleRating) required")
        }
        
        // Module check
        for requiredModule in template.requiredModules {
            if !modules.contains(requiredModule) {
                return (false, "Required module: \(requiredModule)")
            }
        }
        
        return (true, nil)
    }
}
