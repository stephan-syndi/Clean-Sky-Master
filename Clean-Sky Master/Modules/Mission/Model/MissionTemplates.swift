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
    case patrol = "Патруль"
    case smuggling = "Контрабанда"
    case bossHunt = "Охота"
    case storm = "Шторм"
    case rescue = "Спасение"
    case escort = "Эскорт"
    
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
    case weather = "Плохая погода"
    case night = "Ночной вылет"
    case lowFuel = "Нехватка топлива"
    case damaged = "Повреждённый самолёт"
    case timeLimit = "Жёсткий дедлайн"
    
    var description: String {
        switch self {
        case .none: return ""
        case .weather: return "Погодные условия усложняют миссию"
        case .night: return "Ночь снижает видимость"
        case .lowFuel: return "Ограниченный запас топлива"
        case .damaged: return "Самолёт повреждён с самого начала"
        case .timeLimit: return "Время ограничено"
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
    let minBattleRating: Int // Минимальный BR
    let requiredModules: [String] // Специальные модули
    let choices: [MissionChoice]? // Выбор в миссии
    let modifier: MissionModifier
    
    // Генерация отчёта
    func generateReport(success: Bool, choiceIndex: Int? = nil, damage: Double = 0, lootFound: Int = 0) -> String {
        var report = ""
        
        // Начало отчёта
        switch category {
        case .patrol:
            report += "[ ПАТРУЛЬНЫЙ ОТЧЁТ ]\n\n"
        case .smuggling:
            report += "[ КОНФИДЕНЦИАЛЬНЫЙ ОТЧЁТ ]\n\n"
        case .bossHunt:
            report += "[ БОЕВОЙ ОТЧЁТ ]\n\n"
        case .storm:
            report += "[ ЭКСТРЕННЫЙ ОТЧЁТ ]\n\n"
        case .rescue:
            report += "[ СПАСАТЕЛЬНАЯ ОПЕРАЦИЯ ]\n\n"
        case .escort:
            report += "[ ОТЧЁТ ОБ ЭСКОРТЕ ]\n\n"
        }
        
        // Модификатор
        if modifier != .none {
            report += "⚠️ \(modifier.rawValue): \(modifier.description)\n\n"
        }
        
        // Основной сюжет миссии
        if success {
            report += generateSuccessReport(choiceIndex: choiceIndex, lootFound: lootFound)
        } else {
            report += generateFailureReport(damage: damage)
        }
        
        // Итог
        report += "\n\n"
        if success {
            report += "✅ МИССИЯ ЗАВЕРШЕНА УСПЕШНО"
        } else {
            report += "❌ МИССИЯ ПРОВАЛЕНА"
        }
        
        return report
    }
    
    private func generateSuccessReport(choiceIndex: Int?, lootFound: Int) -> String {
        var report = ""
        
        switch category {
        case .patrol:
            report += "Патрулирование сектора прошло без происшествий. "
            if let choice = choiceIndex, let choices = choices {
                report += choices[choice].reportOutcome + " "
            }
            if lootFound > 0 {
                report += "\n\nОбнаружен заброшенный склад с ресурсами (+\(lootFound) кредитов). "
            }
            report += "\n\nВоздушное пространство очищено. Все системы работают в штатном режиме."
            
        case .smuggling:
            if let choice = choiceIndex, let choices = choices {
                report += choices[choice].reportOutcome
            } else {
                report += "Контрабандный груз доставлен в точку назначения. Клиент доволен. Никаких вопросов не возникло."
            }
            
        case .bossHunt:
            report += "КОНТАКТ С ЦЕЛЬЮ УСТАНОВЛЕН!\n\n"
            report += "Враг обнаружен на координатах [ЗАСЕКРЕЧЕНО]. Завязан воздушный бой.\n\n"
            report += "⚔️ ХОД БОЕВЫХ ДЕЙСТВИЙ:\n"
            report += "• 00:42 - Первый залп. Противник маневрирует.\n"
            report += "• 01:15 - Прямое попадание! Урон противнику.\n"
            report += "• 02:03 - Вражеский контр-удар уклонён.\n"
            report += "• 03:21 - Критическое попадание! Цель уничтожена.\n\n"
            report += "🏆 Редкие модули извлечены из обломков."
            
        case .storm:
            report += "🌩️ ЭКСТРЕМАЛЬНЫЕ ПОГОДНЫЕ УСЛОВИЯ\n\n"
            report += "Штормовой фронт застал нас на высоте 7000 метров. "
            report += "Молнии повредили радиосвязь. Приборы отказали на 90 секунд.\n\n"
            report += "Пилот проявил выдающееся мастерство, управляя самолётом вслепую. "
            report += "Пробились через грозовые облака. "
            report += "Груз доставлен целым, хотя обшивка получила повреждения.\n\n"
            report += "⚡ Это был адский полёт, но мы справились."
            
        case .rescue:
            report += "Спасательная операция выполнена в срок.\n\n"
            report += "Все пострадавшие эвакуированы из зоны бедствия. "
            report += "Медицинская помощь оказана на борту.\n\n"
            report += "🚑 Спасено жизней: \(Int.random(in: 5...15))"
            
        case .escort:
            report += "Эскортирование VIP-клиента прошло успешно.\n\n"
            report += "Маршрут пройден без инцидентов. "
            report += "Клиент доставлен в целости и сохранности.\n\n"
            report += "💼 Получена премия за качество обслуживания."
        }
        
        return report
    }
    
    private func generateFailureReport(damage: Double) -> String {
        var report = ""
        
        switch category {
        case .patrol:
            report += "Патрулирование прервано из-за технических неполадок. "
            report += "Пришлось вернуться на базу досрочно."
            
        case .smuggling:
            report += "⚠️ ПРОВАЛ ОПЕРАЦИИ\n\n"
            report += "Обнаружены патрулём пограничной службы. "
            report += "Груз конфискован. Получены повреждения при попытке уйти."
            
        case .bossHunt:
            report += "❌ БОЕВАЯ НЕУДАЧА\n\n"
            report += "Противник оказался сильнее ожидаемого. "
            report += "Получены критические повреждения. "
            report += "Вынужденное отступление.\n\n"
            report += "Требуется усиление огневой мощи перед повторной попыткой."
            
        case .storm:
            report += "⚠️ АВАРИЙНАЯ ПОСАДКА\n\n"
            report += "Шторм оказался сильнее прогнозов. "
            report += "Множественные отказы систем. "
            report += "Совершена вынужденная посадка в запасном аэропорту."
            
        case .rescue:
            report += "Спасательная операция сорвана.\n\n"
            report += "Не удалось достичь зоны бедствия в срок. "
            report += "Погодные условия вынудили вернуться."
            
        case .escort:
            report += "Эскорт прерван.\n\n"
            report += "Самолёт получил повреждения. Клиент недоволен."
        }
        
        if damage > 0 {
            report += "\n\n💥 Получено повреждений: \(Int(damage))%"
        }
        
        return report
    }
}

// MARK: - Mission Templates Library

struct MissionTemplatesLibrary {
    static let allTemplates: [MissionTemplate] = [
        // ПАТРУЛИ
        MissionTemplate(
            category: .patrol,
            name: "Рутинный патруль",
            briefing: "Стандартный облёт территории. Низкий риск, стабильная награда.",
            baseReward: 150,
            baseDifficulty: 0.8,
            minBattleRating: 0,
            requiredModules: [],
            choices: [
                MissionChoice(
                    text: "Следовать строго по маршруту",
                    riskLevel: 0.1,
                    rewardMultiplier: 1.0,
                    reportOutcome: "Маршрут пройден по протоколу."
                ),
                MissionChoice(
                    text: "Исследовать подозрительный сигнал",
                    riskLevel: 0.4,
                    rewardMultiplier: 1.5,
                    reportOutcome: "Проверка сигнала выявила контрабандистов. Получена премия от властей."
                )
            ],
            modifier: .none
        ),
        
        MissionTemplate(
            category: .patrol,
            name: "Разведка местности",
            briefing: "Облёт новой территории для составления карты.",
            baseReward: 180,
            baseDifficulty: 0.9,
            minBattleRating: 1,
            requiredModules: [],
            choices: [
                MissionChoice(
                    text: "Облететь на безопасной высоте",
                    riskLevel: 0.15,
                    rewardMultiplier: 1.0,
                    reportOutcome: "Карта составлена. Местность нанесена на схему."
                ),
                MissionChoice(
                    text: "Лететь низко для детальной съёмки",
                    riskLevel: 0.35,
                    rewardMultiplier: 1.4,
                    reportOutcome: "Получены детальные снимки! Обнаружены интересные объекты."
                )
            ],
            modifier: .none
        ),
        
        MissionTemplate(
            category: .escort,
            name: "Сопровождение курьера",
            briefing: "Обеспечить безопасность курьерского рейса.",
            baseReward: 220,
            baseDifficulty: 1.0,
            minBattleRating: 2,
            requiredModules: [],
            choices: [
                MissionChoice(
                    text: "Лететь по стандартному маршруту",
                    riskLevel: 0.25,
                    rewardMultiplier: 1.0,
                    reportOutcome: "Курьер доставлен вовремя."
                ),
                MissionChoice(
                    text: "Использовать окольный путь",
                    riskLevel: 0.1,
                    rewardMultiplier: 0.9,
                    reportOutcome: "Безопасный маршрут выбран. Небольшая задержка, но без происшествий."
                )
            ],
            modifier: .none
        ),
        
        MissionTemplate(
            category: .patrol,
            name: "Ночной дозор",
            briefing: "Патрулирование в ночное время. Ограниченная видимость.",
            baseReward: 200,
            baseDifficulty: 1.2,
            minBattleRating: 3,
            requiredModules: [],
            choices: nil,
            modifier: .night
        ),
        
        MissionTemplate(
            category: .rescue,
            name: "Поиск пропавших",
            briefing: "Найти сигнал маяка разбившегося самолёта.",
            baseReward: 280,
            baseDifficulty: 1.3,
            minBattleRating: 4,
            requiredModules: [],
            choices: [
                MissionChoice(
                    text: "Искать в указанном квадрате",
                    riskLevel: 0.3,
                    rewardMultiplier: 1.0,
                    reportOutcome: "Маяк найден в указанной зоне. Координаты переданы спасателям."
                ),
                MissionChoice(
                    text: "Расширить зону поиска",
                    riskLevel: 0.5,
                    rewardMultiplier: 1.3,
                    reportOutcome: "Обнаружили выживших! Экстренная эвакуация выполнена."
                )
            ],
            modifier: .none
        ),
        
        MissionTemplate(
            category: .patrol,
            name: "Охрана границы",
            briefing: "Патрулирование пограничной зоны.",
            baseReward: 320,
            baseDifficulty: 1.4,
            minBattleRating: 6,
            requiredModules: [],
            choices: [
                MissionChoice(
                    text: "Обычное патрулирование",
                    riskLevel: 0.2,
                    rewardMultiplier: 1.0,
                    reportOutcome: "Патруль завершён без инцидентов."
                ),
                MissionChoice(
                    text: "Перехватить нарушителя",
                    riskLevel: 0.6,
                    rewardMultiplier: 1.6,
                    reportOutcome: "Нарушитель остановлен! Пограничная служба благодарит за содействие."
                )
            ],
            modifier: .none
        ),
        
        MissionTemplate(
            category: .escort,
            name: "Охрана VIP",
            briefing: "Эскорт важной персоны. Требуется максимальная внимательность.",
            baseReward: 450,
            baseDifficulty: 1.6,
            minBattleRating: 8,
            requiredModules: [],
            choices: nil,
            modifier: .none
        ),
        
        // КОНТРАБАНДА
        MissionTemplate(
            category: .smuggling,
            name: "Контрабандный рейс",
            briefing: "Доставка нелегального груза. Риск штрафа, но щедрая оплата.",
            baseReward: 400,
            baseDifficulty: 1.5,
            minBattleRating: 10,
            requiredModules: [],
            choices: [
                MissionChoice(
                    text: "Пройти мимо патруля",
                    riskLevel: 0.3,
                    rewardMultiplier: 0.7,
                    reportOutcome: "Увидели патруль издалека и сделали крюк. Груз доставлен безопасно, но потратили больше топлива."
                ),
                MissionChoice(
                    text: "Взять риск и лететь напрямую",
                    riskLevel: 0.7,
                    rewardMultiplier: 1.3,
                    reportOutcome: "Прорвались сквозь патрульную зону! Груз доставлен, клиент в восторге. Бонус к награде!"
                )
            ],
            modifier: .none
        ),
        
        MissionTemplate(
            category: .smuggling,
            name: "Теневая доставка",
            briefing: "Секретная доставка в зону конфликта. Высокий риск обнаружения.",
            baseReward: 600,
            baseDifficulty: 2.0,
            minBattleRating: 15,
            requiredModules: ["Глушитель радаров"],
            choices: nil,
            modifier: .none
        ),
        
        // ОХОТА НА БОССОВ
        MissionTemplate(
            category: .bossHunt,
            name: "Охота на Алого Барона",
            briefing: "Известный ас-наёмник терроризирует торговые пути. Устраните угрозу.",
            baseReward: 1000,
            baseDifficulty: 2.5,
            minBattleRating: 25,
            requiredModules: ["Усиленное вооружение"],
            choices: nil,
            modifier: .none
        ),
        
        MissionTemplate(
            category: .bossHunt,
            name: "Операция «Гром»",
            briefing: "Уничтожение вражеского эсминца класса «Titan». Требуется максимальная огневая мощь.",
            baseReward: 1500,
            baseDifficulty: 3.0,
            minBattleRating: 35,
            requiredModules: ["Ракетная установка", "Усиленная броня"],
            choices: [
                MissionChoice(
                    text: "Фронтальная атака",
                    riskLevel: 0.8,
                    rewardMultiplier: 1.2,
                    reportOutcome: "Лобовая атака! Получили серьёзные повреждения, но мощный залп уничтожил цель."
                ),
                MissionChoice(
                    text: "Обходной манёвр",
                    riskLevel: 0.5,
                    rewardMultiplier: 1.0,
                    reportOutcome: "Скрытный подход с фланга. Застали врага врасплох. Цель уничтожена с минимальными потерями."
                )
            ],
            modifier: .none
        ),
        
        // ШТОРМЫ
        MissionTemplate(
            category: .storm,
            name: "Штормовой штурм",
            briefing: "Срочная доставка медикаментов сквозь грозовой фронт. Экстремальный риск.",
            baseReward: 700,
            baseDifficulty: 2.2,
            minBattleRating: 20,
            requiredModules: [],
            choices: nil,
            modifier: .weather
        ),
        
        MissionTemplate(
            category: .storm,
            name: "Через ураган",
            briefing: "Единственный шанс спасти заблокированный город - пролететь через ураган категории 5.",
            baseReward: 900,
            baseDifficulty: 2.8,
            minBattleRating: 30,
            requiredModules: ["Усиленный корпус"],
            choices: nil,
            modifier: .weather
        ),
        
        // СПАСЕНИЕ
        MissionTemplate(
            category: .rescue,
            name: "Горная спасательная",
            briefing: "Эвакуация альпинистов с вершины. Сложные условия на высоте.",
            baseReward: 500,
            baseDifficulty: 1.8,
            minBattleRating: 12,
            requiredModules: [],
            choices: nil,
            modifier: .none
        ),
        
        MissionTemplate(
            category: .rescue,
            name: "Операция «Феникс»",
            briefing: "Спасение выживших после авиакатастрофы. Ограниченное время.",
            baseReward: 800,
            baseDifficulty: 2.3,
            minBattleRating: 18,
            requiredModules: ["Медицинский отсек"],
            choices: nil,
            modifier: .timeLimit
        ),
        
        // ЭСКОРТ
        MissionTemplate(
            category: .escort,
            name: "VIP эскорт",
            briefing: "Сопровождение важной персоны. Репутация превыше всего.",
            baseReward: 600,
            baseDifficulty: 1.5,
            minBattleRating: 15,
            requiredModules: [],
            choices: nil,
            modifier: .none
        ),
        
        MissionTemplate(
            category: .escort,
            name: "Охрана конвоя",
            briefing: "Защита торгового конвоя от пиратов. Возможны атаки.",
            baseReward: 750,
            baseDifficulty: 2.0,
            minBattleRating: 22,
            requiredModules: ["Оружие"],
            choices: [
                MissionChoice(
                    text: "Оборонительная тактика",
                    riskLevel: 0.4,
                    rewardMultiplier: 0.9,
                    reportOutcome: "Держались близко к конвою. Отбили все атаки. Груз цел, но без бонуса."
                ),
                MissionChoice(
                    text: "Агрессивное преследование",
                    riskLevel: 0.7,
                    rewardMultiplier: 1.3,
                    reportOutcome: "Выследили пиратскую базу и уничтожили её! Конвой в безопасности. Премия от торговцев!"
                )
            ],
            modifier: .none
        )
    ]
    
    // Получить случайную миссию по сложности
    static func getRandomMission(minDifficulty: Double = 0.0, maxDifficulty: Double = 3.0, battleRating: Int = 1) -> MissionTemplate {
        // Фильтруем миссии по сложности И по BR (с небольшим запасом +3)
        let suitable = allTemplates.filter { 
            $0.baseDifficulty >= minDifficulty && 
            $0.baseDifficulty <= maxDifficulty &&
            $0.minBattleRating <= battleRating + 3 // Небольшой запас для челленджа
        }
        
        // Если нет подходящих миссий с учетом BR, берем любую по сложности
        if suitable.isEmpty {
            let byDifficulty = allTemplates.filter { 
                $0.baseDifficulty >= minDifficulty && $0.baseDifficulty <= maxDifficulty 
            }
            return byDifficulty.randomElement() ?? allTemplates[0]
        }
        
        return suitable.randomElement() ?? allTemplates[0]
    }
    
    // Получить миссию по категории
    static func getMissionsByCategory(_ category: MissionCategory) -> [MissionTemplate] {
        return allTemplates.filter { $0.category == category }
    }
    
    // Проверка доступности миссии
    static func canStartMission(template: MissionTemplate, battleRating: Int, modules: [String]) -> (canStart: Bool, reason: String?) {
        // Проверка BR
        if battleRating < template.minBattleRating {
            return (false, "Требуется BR ≥ \(template.minBattleRating)")
        }
        
        // Проверка модулей
        for requiredModule in template.requiredModules {
            if !modules.contains(requiredModule) {
                return (false, "Требуется модуль: \(requiredModule)")
            }
        }
        
        return (true, nil)
    }
}
