//
//  DebtModels.swift
//  tax-manager
//
//  Created by Murat AKMAMEDAU on 29.08.2025.
//

import Foundation
import SwiftData

enum DebtCurrency: String, CaseIterable, Codable {
    case eur = "EUR"
    case usd = "USD"
    case gel = "GEL"
    case byn = "BYN"

    var symbol: String {
        switch self {
        case .eur: return "€"
        case .usd: return "$"
        case .gel: return "₾"
        case .byn: return "Br"
        }
    }
}

enum DebtType: String, CaseIterable, Codable {
    case iOwe = "I Owe"
    case owesMe = "Owes Me"

    var color: String {
        switch self {
        case .iOwe: return "red"
        case .owesMe: return "green"
        }
    }
}

enum DebtStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case partiallyPaid = "Partially Paid"
    case paid = "Paid"
}

@Model
final class Debt {
    var id: UUID
    var personName: String
    var originalAmount: Double
    var remainingAmount: Double
    var currency: DebtCurrency
    var type: DebtType
    var status: DebtStatus
    var createdDate: Date
    var dueDate: Date?
    var notes: String
    var lastUpdated: Date

    @Relationship(deleteRule: .cascade, inverse: \DebtPayment.debt)
    var payments: [DebtPayment]

    init(personName: String, amount: Double, currency: DebtCurrency, type: DebtType, dueDate: Date? = nil, notes: String = "") {
        self.id = UUID()
        self.personName = personName
        self.originalAmount = amount
        self.remainingAmount = amount
        self.currency = currency
        self.type = type
        self.status = .pending
        self.createdDate = Date()
        self.dueDate = dueDate
        self.notes = notes
        self.lastUpdated = Date()
        self.payments = []
    }

    var isPastDue: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate < Date() && status != .paid
    }

    var paidAmount: Double {
        originalAmount - remainingAmount
    }

    var paymentProgress: Double {
        guard originalAmount > 0 else { return 0 }
        return paidAmount / originalAmount
    }
}

@Model
final class DebtPayment {
    var id: UUID
    var amount: Double
    var date: Date
    var notes: String
    var debt: Debt?

    init(amount: Double, date: Date = Date(), notes: String = "") {
        self.id = UUID()
        self.amount = amount
        self.date = date
        self.notes = notes
    }
}
