//
//  TimeZone+Extension.swift
//  TravelBudgetCalculator
//
//  Created by ウルトラ深瀬 on 7/9/24.
//

import Foundation

extension TimeZone {
    static var utc: TimeZone {
        return .init(identifier: "UTC")!
    }
}
