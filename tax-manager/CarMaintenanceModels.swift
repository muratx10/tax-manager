//
//  CarMaintenanceModels.swift
//  tax-manager
//
//  Created by Murat AKMAMEDAU on 25.10.2025.
//

import Foundation
import SwiftData

enum MaintenanceType: String, CaseIterable, Codable {
    case oilChange = "Oil Change"
    case inspection = "Inspection"
    case tires = "Tires"
    case brakes = "Brakes"
    case filters = "Filters"
    case other = "Other"

    var icon: String {
        switch self {
        case .oilChange:
            return "drop.fill"
        case .inspection:
            return "checklist"
        case .tires:
            return "circle.fill"
        case .brakes:
            return "stop.fill"
        case .filters:
            return "line.3.horizontal.decrease.circle.fill"
        case .other:
            return "wrench.and.screwdriver.fill"
        }
    }
}

@Model
final class MaintenanceRecord {
    var id: UUID
    var date: Date
    var mileage: Int
    var type: MaintenanceType
    var cost: Double
    var notes: String
    var nextServiceMileage: Int?
    var nextServiceDate: Date?
    var createdAt: Date

    init(date: Date, mileage: Int, type: MaintenanceType, cost: Double, notes: String = "", nextServiceMileage: Int? = nil, nextServiceDate: Date? = nil) {
        self.id = UUID()
        self.date = date
        self.mileage = mileage
        self.type = type
        self.cost = cost
        self.notes = notes
        self.nextServiceMileage = nextServiceMileage
        self.nextServiceDate = nextServiceDate
        self.createdAt = Date()
    }
}
