//
//  ContentView.swift
//  tax-manager
//
//  Created by Murat AKMAMEDAU on 29.08.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            PaymentEntryView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Payment")
                }
                .tag(1)
            
            PaymentHistoryView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("History")
                }
                .tag(2)
            
            ExchangeRatesView()
                .tabItem {
                    Image(systemName: "dollarsign.circle")
                    Text("Exchange Rates")
                }
                .tag(3)
        }
        .frame(minWidth: 900, minHeight: 650)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Payment.self, inMemory: true)
}
