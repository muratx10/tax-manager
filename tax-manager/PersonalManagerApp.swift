//
//  tax_managerApp.swift
//  tax-manager
//
//  Created by Murat AKMAMEDAU on 29.08.2025.
//

import SwiftUI
import SwiftData

@main
struct PersonalManagerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Payment.self,
            ExchangeRate.self,
            MonthlySummary.self,
            Debt.self,
            DebtPayment.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup("Personal Manager") {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
