//
//  PaymentHistoryView.swift
//  tax-manager
//
//  Created by Murat AKMAMEDAU on 29.08.2025.
//

import SwiftUI
import SwiftData

struct PaymentHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Payment.date, order: .reverse)])
    private var allPayments: [Payment]
    
    @State private var selectedMonth = 0
    @State private var selectedYear = 0
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var paymentToDelete: Payment?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                
                filterSection
                
                if filteredPayments.isEmpty {
                    emptyStateView
                } else {
                    paymentsContent
                }
                
                Spacer(minLength: 20)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Payment History")
        .searchable(text: $searchText, prompt: "Search companies...")
        .alert("Delete Payment", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let payment = paymentToDelete {
                    deletePayment(payment)
                }
            }
        } message: {
            Text("Are you sure you want to delete this payment? This action cannot be undone.")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Payment History")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("View and manage all your payment records")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 8)
    }
    
    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Filters")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Month")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Picker("Month", selection: $selectedMonth) {
                        Text("All Months").tag(0)
                        ForEach(1...12, id: \.self) { month in
                            Text(DateFormatter().monthSymbols[month - 1])
                                .tag(month)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(minWidth: 140)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Year")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Picker("Year", selection: $selectedYear) {
                        Text("All Years").tag(0)
                        ForEach(availableYears.filter { $0 != 0 }, id: \.self) { year in
                            Text("\(year)")
                                .tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(minWidth: 120)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text(" ")
                        .font(.subheadline)
                    
                    Button("Reset Filters") {
                        selectedMonth = 0
                        selectedYear = 0
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedMonth == 0 && selectedYear == 0)
                }
            }
            
            if selectedMonth > 0 || selectedYear > 0 {
                HStack {
                    Text("Showing: ")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if selectedMonth > 0 && selectedYear > 0 {
                        Text("\(DateFormatter().monthSymbols[selectedMonth - 1]) \(selectedYear)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    } else if selectedMonth > 0 {
                        Text("All \(DateFormatter().monthSymbols[selectedMonth - 1]) entries")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    } else if selectedYear > 0 {
                        Text("All \(selectedYear) entries")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
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
    
    private var paymentsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "creditcard")
                    .foregroundColor(.green)
                    .font(.title3)
                Text("Payments (\(filteredPayments.count))")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            LazyVStack(spacing: 16) {
                ForEach(groupedPayments, id: \.key) { monthGroup in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(monthGroup.key)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(monthGroup.value.count) payment\(monthGroup.value.count != 1 ? "s" : "")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Total: \(formatGELAmount(monthlyTotal(for: monthGroup.value))) ₾")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.horizontal, 4)
                        
                        VStack(spacing: 8) {
                            ForEach(monthGroup.value, id: \.id) { payment in
                                PaymentRowView(payment: payment) {
                                    paymentToDelete = payment
                                    showingDeleteAlert = true
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("No Payments Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(searchText.isEmpty ? 
                 "No payments for the selected period" : 
                 "No payments match your search")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var filteredPayments: [Payment] {
        var filtered = allPayments
        
        // Apply year filter if selected
        if selectedYear > 0 {
            filtered = filtered.filter { payment in
                let calendar = Calendar.current
                let paymentYear = calendar.component(.year, from: payment.date)
                return paymentYear == selectedYear
            }
        }
        
        // Apply month filter if selected
        if selectedMonth > 0 {
            filtered = filtered.filter { payment in
                let calendar = Calendar.current
                let paymentMonth = calendar.component(.month, from: payment.date)
                return paymentMonth == selectedMonth
            }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { payment in
                payment.company.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    private var groupedPayments: [(key: String, value: [Payment])] {
        let grouped = Dictionary(grouping: filteredPayments) { payment in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: payment.date)
        }
        
        return grouped.sorted { first, second in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            
            guard let firstDate = formatter.date(from: first.key),
                  let secondDate = formatter.date(from: second.key) else {
                return false
            }
            
            return firstDate > secondDate
        }
    }
    
    private var availableYears: [Int] {
        let years = Set(allPayments.map { Calendar.current.component(.year, from: $0.date) })
        return ([0] + Array(years).sorted(by: >))
    }
    
    private func monthlyTotal(for payments: [Payment]) -> Double {
        return payments.reduce(0) { $0 + $1.amountInGEL }
    }
    
    private func deletePayment(_ payment: Payment) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: payment.date)
        let month = calendar.component(.month, from: payment.date)
        
        modelContext.delete(payment)
        
        let request = FetchDescriptor<MonthlySummary>(
            predicate: #Predicate { summary in
                summary.year == year && summary.month == month
            }
        )
        
        do {
            let summaries = try modelContext.fetch(request)
            if let summary = summaries.first {
                summary.totalIncomeGEL -= payment.amountInGEL
                summary.paymentCount -= 1
                summary.lastUpdated = Date()
                
                if summary.paymentCount <= 0 {
                    modelContext.delete(summary)
                }
            }
            
            updateCumulativeTotals()
            try modelContext.save()
        } catch {
            print("Error updating monthly summary after deletion: \(error)")
        }
    }
    
    private func updateCumulativeTotals() {
        let request = FetchDescriptor<MonthlySummary>(
            sortBy: [SortDescriptor(\.year), SortDescriptor(\.month)]
        )
        
        do {
            let summaries = try modelContext.fetch(request)
            
            // Group summaries by year
            let groupedByYear = Dictionary(grouping: summaries) { $0.year }
            
            // Calculate cumulative for each year separately
            for (_, yearSummaries) in groupedByYear {
                let sortedYearSummaries = yearSummaries.sorted { 
                    $0.month < $1.month 
                }
                
                var yearCumulativeTotal: Double = 0
                
                for summary in sortedYearSummaries {
                    yearCumulativeTotal += summary.totalIncomeGEL
                    summary.cumulativeIncomeGEL = yearCumulativeTotal
                }
            }
            
        } catch {
            print("Failed to update cumulative totals: \(error)")
        }
    }
}

struct PaymentRowView: View {
    let payment: Payment
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Company icon and info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 16, weight: .medium))
                    
                    Text(payment.company)
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(payment.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if payment.currency != .gel {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Rate: \(payment.exchangeRate, specifier: "%.4f")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Amount information
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 8) {
                    Text("\(payment.amount, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(payment.currency.symbol)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(currencyColor(payment.currency))
                        .frame(minWidth: 20)
                }
                
                HStack(spacing: 4) {
                    Text("=")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(formatGELAmount(payment.amountInGEL)) ₾")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.red)
                    .frame(width: 28, height: 28)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color(NSColor.separatorColor).opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
        )
    }
    
    private func currencyColor(_ currency: Currency) -> Color {
        switch currency {
        case .eur: return .blue
        case .usd: return .green
        case .gel: return .orange
        }
    }
}

#Preview {
    PaymentHistoryView()
        .modelContainer(for: Payment.self, inMemory: true)
}