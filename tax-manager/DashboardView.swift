//
//  DashboardView.swift
//  tax-manager
//
//  Created by Murat AKMAMEDAU on 29.08.2025.
//

import SwiftUI
import SwiftData
import AppKit

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\MonthlySummary.year, order: .reverse), 
                  SortDescriptor(\MonthlySummary.month, order: .reverse)])
    private var monthlySummaries: [MonthlySummary]
    
    @Query private var payments: [Payment]
    
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var showingClearDatabaseAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                
                currentMonthCard
                
                yearSelectorCard
                
                monthlyBreakdownCard
                
                quickStatsCard
                
                databaseManagementCard
                
                Spacer(minLength: 20)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Tax Dashboard")
        .refreshable {
            // Refresh data if needed
        }
        .alert("Clear All Data", isPresented: $showingClearDatabaseAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All Data", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("Are you sure you want to delete ALL payments and data? This action cannot be undone.")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Tax Dashboard")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Track your income and tax calculations")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 8)
    }
    
    private var currentMonthCard: some View {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)

        // Calculate actual monthly income from payments for current month
        let currentMonthPayments = payments.filter { payment in
            let paymentYear = calendar.component(.year, from: payment.date)
            let paymentMonth = calendar.component(.month, from: payment.date)
            return paymentYear == currentYear && paymentMonth == currentMonth
        }
        let actualMonthlyIncome = currentMonthPayments.reduce(0) { $0 + $1.amountInGEL }

        // Calculate year-to-date cumulative for current year
        let currentYearPayments = payments.filter { payment in
            let paymentYear = calendar.component(.year, from: payment.date)
            return paymentYear == currentYear
        }
        let yearToDateCumulative = currentYearPayments.reduce(0) { $0 + $1.amountInGEL }

        // If current month has no data, fallback to last month
        let shouldShowLastMonth = currentMonthPayments.isEmpty
        var displayYear = currentYear
        var displayMonth = currentMonth
        var displayPayments = currentMonthPayments
        var displayIncome = actualMonthlyIncome
        var displayCumulative = yearToDateCumulative

        if shouldShowLastMonth {
            // Calculate last month
            let lastMonthComponents = calendar.dateInterval(of: .month, for: currentDate)?.start
                .addingTimeInterval(-1) // Go back one second to get last month
            if let lastMonthDate = lastMonthComponents {
                displayYear = calendar.component(.year, from: lastMonthDate)
                displayMonth = calendar.component(.month, from: lastMonthDate)

                displayPayments = payments.filter { payment in
                    let paymentYear = calendar.component(.year, from: payment.date)
                    let paymentMonth = calendar.component(.month, from: payment.date)
                    return paymentYear == displayYear && paymentMonth == displayMonth
                }
                displayIncome = displayPayments.reduce(0) { $0 + $1.amountInGEL }

                // Cumulative for the year of the last month being displayed
                let lastMonthYearPayments = payments.filter { payment in
                    let paymentYear = calendar.component(.year, from: payment.date)
                    return paymentYear == displayYear
                }
                displayCumulative = lastMonthYearPayments.reduce(0) { $0 + $1.amountInGEL }
            }
        }
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text(shouldShowLastMonth ? "Last Month" : "Current Month")
                    .font(.title2)
                Spacer()
                Text(DateFormatter().monthSymbols[displayMonth - 1])
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Monthly Income")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        Text("\(formatGELAmount(displayIncome)) ₾")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Button(action: {
                            copyToClipboard(formatGELAmount(displayIncome))
                        }) {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Cumulative")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        Text("\(formatGELAmount(displayCumulative)) ₾")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        Button(action: {
                            copyToClipboard(formatGELAmount(displayCumulative))
                        }) {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            if !displayPayments.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.orange)
                        Text("\(displayPayments.count) payments \(shouldShowLastMonth ? "last month" : "this month")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "percent")
                            .foregroundColor(.red)
                        Text("Tax (1%): \(displayIncome * 0.01, specifier: "%.2f") ₾")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    private var yearSelectorCard: some View {
        let currentYear = Calendar.current.component(.year, from: Date())
        let availableYears = Array(Set(monthlySummaries.map { $0.year })).sorted(by: >)
        let allYears = availableYears.isEmpty ? [currentYear] : availableYears
        
        return VStack(alignment: .leading) {
            Text("Select Year")
                .font(.title2)
                .padding(.bottom, 8)
            
            if allYears.isEmpty {
                Text("No data available")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(allYears, id: \.self) { year in
                            yearButton(for: year)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        .onAppear {
            // Set selectedYear to current year if not in available years
            if !allYears.contains(selectedYear) {
                selectedYear = allYears.first ?? currentYear
            }
        }
    }
    
    private func yearButton(for year: Int) -> some View {
        Button(action: {
            selectedYear = year
        }) {
            Text("\(year)")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(selectedYear == year ? Color.accentColor : Color(NSColor.controlColor))
                .foregroundColor(selectedYear == year ? .white : .primary)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var monthlyBreakdownCard: some View {
        let yearSummaries = monthlySummaries.filter { $0.year == selectedYear }
            .sorted { $0.month < $1.month }
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("\(selectedYear, format: .number.grouping(.never)) Monthly Breakdown")
                .font(.headline)
            
            if yearSummaries.isEmpty {
                Text("No data for \(selectedYear, format: .number.grouping(.never))")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(yearSummaries, id: \.id) { summary in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(summary.monthName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("\(summary.paymentCount) payments")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(formatGELAmount(summary.totalIncomeGEL)) ₾")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Total: \(formatGELAmount(summary.cumulativeIncomeGEL)) ₾")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text("Tax: \(summary.taxAmount, specifier: "%.2f") ₾")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    private var quickStatsCard: some View {
        let yearPayments = getYearPayments()
        let totalPayments = yearPayments.count
        let totalIncomeGEL = yearPayments.reduce(0) { $0 + $1.amountInGEL }
        let totalIncomeEUR = yearPayments.filter { $0.currency == .eur }.reduce(0) { $0 + $1.amount }
        let totalIncomeUSD = yearPayments.filter { $0.currency == .usd }.reduce(0) { $0 + $1.amount }
        let uniqueCompanies = Set(yearPayments.map { $0.company }).count
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(selectedYear, format: .number.grouping(.never)) Year Statistics")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 16) {
                yearStatColumn(
                    title: "Total Payments",
                    value: "\(totalPayments)",
                    color: .blue
                )
                
                yearStatColumn(
                    title: "Companies",
                    value: "\(uniqueCompanies)",
                    color: .orange
                )
                
                yearStatColumn(
                    title: "Total Income (GEL)",
                    value: "\(formatGELAmount(totalIncomeGEL)) ₾",
                    color: .green
                )
                
                Spacer()
            }
            
            if totalIncomeEUR > 0 || totalIncomeUSD > 0 {
                Divider()
                
                Text("Original Currency Totals")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    if totalIncomeEUR > 0 {
                        yearStatColumn(
                            title: "EUR Income",
                            value: String(format: "%.2f €", totalIncomeEUR),
                            color: .blue
                        )
                    }
                    
                    if totalIncomeUSD > 0 {
                        yearStatColumn(
                            title: "USD Income", 
                            value: String(format: "%.2f $", totalIncomeUSD),
                            color: .green
                        )
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    private var databaseManagementCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "trash.fill")
                    .foregroundColor(.red)
                    .font(.title3)
                Text("Database Management")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Clear all payment data and monthly summaries from the database.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Button("Clear All Data") {
                        showingClearDatabaseAlert = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .tint(.red)
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    private func clearAllData() {
        do {
            // Clear all payments
            let paymentRequest = FetchDescriptor<Payment>()
            let allPayments = try modelContext.fetch(paymentRequest)
            for payment in allPayments {
                modelContext.delete(payment)
            }
            
            // Clear all monthly summaries
            let summaryRequest = FetchDescriptor<MonthlySummary>()
            let allSummaries = try modelContext.fetch(summaryRequest)
            for summary in allSummaries {
                modelContext.delete(summary)
            }
            
            // Clear all exchange rates
            let rateRequest = FetchDescriptor<ExchangeRate>()
            let allRates = try modelContext.fetch(rateRequest)
            for rate in allRates {
                modelContext.delete(rate)
            }
            
            // Save the context to persist the deletions
            try modelContext.save()
            
        } catch {
            print("Error clearing database: \(error)")
        }
    }
    
    private func getYearPayments() -> [Payment] {
        payments.filter { payment in
            let calendar = Calendar.current
            let paymentYear = calendar.component(.year, from: payment.date)
            return paymentYear == selectedYear
        }
    }
    
    private func yearStatColumn(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: 80)
    }
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: Payment.self, inMemory: true)
}