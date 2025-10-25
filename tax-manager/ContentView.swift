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
    @StateObject private var moduleManager = ModuleManager()
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            appTitleHeader

            HSplitView {
                ModuleSidebar(moduleManager: moduleManager)

                moduleContent
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 900, minHeight: 650)
        .background(Color(NSColor.windowBackgroundColor))
        .onChange(of: moduleManager.selectedModule) { _, _ in
            selectedTab = 0
        }
    }

    @ViewBuilder
    private var moduleContent: some View {
        switch moduleManager.selectedModule {
        case .finance:
            financeModuleTabs
        case .debts:
            debtsModuleContent
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)

    private var financeModuleTabs: some View {
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

    private var debtsModuleContent: some View {
        DebtsView()
    }
    
    private var appTitleHeader: some View {
        HStack {
            Image(systemName: "square.grid.2x2.fill")
                .font(.title2)
                .foregroundColor(.blue)

            Text("Personal Manager")
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
