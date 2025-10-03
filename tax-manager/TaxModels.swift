//
//  TaxModels.swift
//  tax-manager
//
//  Created by Murat AKMAMEDAU on 29.08.2025.
//

import Foundation
import SwiftData

enum Currency: String, CaseIterable, Codable {
    case eur = "EUR"
    case usd = "USD"
    case gel = "GEL"

    var symbol: String {
        switch self {
        case .eur: return "€"
        case .usd: return "$"
        case .gel: return "₾"
        }
    }
}

@Model
final class Payment {
    var id: UUID
    var company: String
    var amount: Double
    var currency: Currency
    var date: Date
    var exchangeRate: Double
    var amountInGEL: Double
    var createdAt: Date
    
    init(company: String, amount: Double, currency: Currency, date: Date, exchangeRate: Double) {
        self.id = UUID()
        self.company = company
        self.amount = amount
        self.currency = currency
        self.date = date
        self.exchangeRate = exchangeRate
        self.amountInGEL = currency == .gel ? amount : ceil(amount * exchangeRate)
        self.createdAt = Date()
    }
}

@Model
final class ExchangeRate {
    var id: UUID
    var currency: Currency
    var rate: Double
    var date: Date
    var fetchedAt: Date
    
    init(currency: Currency, rate: Double, date: Date) {
        self.id = UUID()
        self.currency = currency
        self.rate = rate
        self.date = date
        self.fetchedAt = Date()
    }
}

@Model
final class MonthlySummary {
    var id: UUID
    var year: Int
    var month: Int
    var totalIncomeGEL: Double
    var cumulativeIncomeGEL: Double
    var paymentCount: Int
    var lastUpdated: Date
    
    init(year: Int, month: Int, totalIncomeGEL: Double, cumulativeIncomeGEL: Double, paymentCount: Int) {
        self.id = UUID()
        self.year = year
        self.month = month
        self.totalIncomeGEL = totalIncomeGEL
        self.cumulativeIncomeGEL = cumulativeIncomeGEL
        self.paymentCount = paymentCount
        self.lastUpdated = Date()
    }
    
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let date = Calendar.current.date(from: DateComponents(year: year, month: month)) ?? Date()
        return formatter.string(from: date)
    }
    
    var taxAmount: Double {
        return totalIncomeGEL * 0.01
    }
    
    var cumulativeTaxAmount: Double {
        return cumulativeIncomeGEL * 0.01
    }
}

// Helper function to format GEL amounts with ceiling
func formatGELAmount(_ amount: Double) -> String {
    return String(format: "%.0f", ceil(amount))
}