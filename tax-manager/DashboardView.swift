//
//  DashboardView.swift
//  tax-manager
//
//  Created by Murat AKMAMEDAU on 29.08.2025.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\MonthlySummary.year, order: .reverse), 
                  SortDescriptor(\MonthlySummary.month, order: .reverse)])
    private var monthlySummaries: [MonthlySummary]
    
    @Query private var payments: [Payment]
    
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                
                currentMonthCard
                
                yearSelectorCard
                
                monthlyBreakdownCard
                
                quickStatsCard
                
                Spacer(minLength: 20)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Tax Dashboard")
        .refreshable {
            // Refresh data if needed
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Tax Dashboard")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Track your income and tax calculations")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 8)
    }
    
    private var currentMonthCard: some View {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        
        let currentSummary = monthlySummaries.first { summary in
            summary.year == currentYear && summary.month == currentMonth
        }
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("Current Month")
                    .font(.headline)
                Spacer()
                Text(DateFormatter().monthSymbols[currentMonth - 1])
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Monthly Income")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(currentSummary?.totalIncomeGEL ?? 0, specifier: "%.2f") ₾")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Cumulative")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(currentSummary?.cumulativeIncomeGEL ?? 0, specifier: "%.2f") ₾")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            
            if let summary = currentSummary {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.orange)
                    Text("\(summary.paymentCount) payments this month")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
                .font(.headline)
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
                                Text("\(summary.totalIncomeGEL, specifier: "%.2f") ₾")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Total: \(summary.cumulativeIncomeGEL, specifier: "%.2f") ₾")
                                    .font(.caption)
                                    .foregroundColor(.green)
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
        let totalPayments = payments.count
        let totalIncomeGEL = payments.reduce(0) { $0 + $1.amountInGEL }
        let uniqueCompanies = Set(payments.map { $0.company }).count
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Quick Stats")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(totalPayments)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Total Payments")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(uniqueCompanies)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Companies")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(totalIncomeGEL, specifier: "%.0f") ₾")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Total Income")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: Payment.self, inMemory: true)
}