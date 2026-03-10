//
//  Date+Extension.swift
//  Feature
//
//  Created by 김준표 on 2/24/26.
//  Copyright © 2026 HARIBO. All rights reserved.
//

import Foundation

extension Date {

    func lastWednesday() -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)

        let daysToSubtract: Int

        switch weekday {
        case 1: daysToSubtract = 4
        case 2: daysToSubtract = 5
        case 3: daysToSubtract = 6
        case 4: daysToSubtract = 7
        case 5: daysToSubtract = 1
        case 6: daysToSubtract = 2
        case 7: daysToSubtract = 3
        default: daysToSubtract = 0
        }

        return calendar.date(byAdding: .day, value: -daysToSubtract, to: self)!
    }
}
