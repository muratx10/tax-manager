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
        VStack(spacing: 0) {
            appTitleHeader
            
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
        }
        .frame(minWidth: 900, minHeight: 650)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var appTitleHeader: some View {
        HStack {
            Image(systemName: "doc.text.fill")
                .font(.title2)
                .foregroundColor(.blue)
            
            Text("Tax management app for Murat")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .bottom
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Payment.self, inMemory: true)
}
