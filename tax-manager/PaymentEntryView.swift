//
//  PaymentEntryView.swift
//  tax-manager
//
//  Created by Murat AKMAMEDAU on 29.08.2025.
//

import SwiftUI
import SwiftData

struct PaymentEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var company = ""
    @State private var amount = ""
    @State private var selectedCurrency: Currency = .eur
    @State private var selectedDate = Date()
    @State private var exchangeRate = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                
                paymentDetailsCard
                
                exchangeRateCard
                
                saveButtonSection
                
                Spacer(minLength: 20)
            }
            .padding(24)
            .frame(maxWidth: 600)
        }
        .navigationTitle("Add Payment")
        .alert("Result", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Add New Payment")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Enter payment details and fetch current exchange rates")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 8)
    }
    
    private var paymentDetailsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "building.2")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Payment Details")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Company Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    TextField("Enter company name", text: $company)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 32)
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        TextField("0.00", text: $amount)
                            .textFieldStyle(.roundedBorder)
                            .frame(height: 32)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Currency")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Picker("Currency", selection: $selectedCurrency) {
                            ForEach(Currency.allCases, id: \.self) { currency in
                                HStack {
                                    Text(currency.symbol)
                                        .fontWeight(.semibold)
                                    Text(currency.rawValue)
                                }
                                .tag(currency)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedCurrency) { oldValue, newValue in
                            if newValue != .gel && !company.isEmpty {
                                fetchExchangeRate()
                            } else if newValue == .gel {
                                exchangeRate = "1.0"
                            }
                        }
                        .frame(height: 32)
                        .frame(minWidth: 120)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Payment Date")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.field)
                        .frame(height: 32)
                        .onChange(of: selectedDate) { oldValue, newValue in
                            if selectedCurrency != .gel && !company.isEmpty {
                                fetchExchangeRate()
                            }
                        }
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var exchangeRateCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "dollarsign.circle")
                    .foregroundColor(.green)
                    .font(.title3)
                Text("Exchange Rate")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            if selectedCurrency == .gel {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("No conversion needed for GEL")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    Text("Rate: 1.0000")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Rate to GEL")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            TextField("0.0000", text: $exchangeRate)
                                .textFieldStyle(.roundedBorder)
                                .frame(height: 32)
                        }
                        
                        VStack(spacing: 8) {
                            Text(" ")
                                .font(.subheadline)
                            
                            Button(action: fetchExchangeRate) {
                                HStack(spacing: 8) {
                                    if isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .frame(width: 16, height: 16)
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    Text(isLoading ? "Fetching..." : "Fetch Rate")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isLoading)
                            .frame(height: 32)
                        }
                    }
                    
                    if let rate = Double(exchangeRate), let amt = Double(amount), rate > 0, amt > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Conversion Preview")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(spacing: 8) {
                                        Text("\(amt, specifier: "%.2f") \(selectedCurrency.symbol)")
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        
                                        Image(systemName: "arrow.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text("\(amt * rate, specifier: "%.2f") ₾")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.green)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var saveButtonSection: some View {
        VStack(spacing: 12) {
            Button(action: savePayment) {
                HStack(spacing: 12) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .medium))
                    }
                    
                    Text(isLoading ? "Saving..." : "Save Payment")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isFormValid && !isLoading ? Color.blue : Color.gray)
                .cornerRadius(12)
            }
            .disabled(!isFormValid || isLoading)
            .buttonStyle(.plain)
            
            if !isFormValid {
                Text("Please fill in all required fields")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var isFormValid: Bool {
        !company.isEmpty &&
        !amount.isEmpty &&
        Double(amount) != nil &&
        !exchangeRate.isEmpty &&
        Double(exchangeRate) != nil
    }
    
    private func fetchExchangeRate() {
        isLoading = true
        
        Task {
            do {
                let rate = try await ExchangeRateService.shared.fetchRate(for: selectedCurrency, on: selectedDate)
                
                await MainActor.run {
                    self.exchangeRate = String(format: "%.4f", rate)
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.alertMessage = "Failed to fetch exchange rate: \(error.localizedDescription)"
                    self.showingAlert = true
                    self.isLoading = false
                }
            }
        }
    }
    
    private func savePayment() {
        guard let amountValue = Double(amount),
              let rateValue = Double(exchangeRate) else {
            alertMessage = "Please enter valid numbers"
            showingAlert = true
            return
        }
        
        let payment = Payment(
            company: company,
            amount: amountValue,
            currency: selectedCurrency,
            date: selectedDate,
            exchangeRate: rateValue
        )
        
        modelContext.insert(payment)
        
        do {
            try modelContext.save()
            
            company = ""
            amount = ""
            selectedDate = Date()
            exchangeRate = selectedCurrency == .gel ? "1.0" : ""
            
            alertMessage = "Payment saved successfully!"
            showingAlert = true
            
            updateMonthlySummary(for: selectedDate, with: payment.amountInGEL)
            
        } catch {
            alertMessage = "Failed to save payment: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func updateMonthlySummary(for date: Date, with amount: Double) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        let request = FetchDescriptor<MonthlySummary>(
            predicate: #Predicate { summary in
                summary.year == year && summary.month == month
            }
        )
        
        do {
            let existingSummaries = try modelContext.fetch(request)
            
            if let summary = existingSummaries.first {
                summary.totalIncomeGEL += amount
                summary.paymentCount += 1
                summary.lastUpdated = Date()
            } else {
                let previousMonth = calendar.date(byAdding: .month, value: -1, to: date) ?? date
                let prevYear = calendar.component(.year, from: previousMonth)
                let prevMonthNum = calendar.component(.month, from: previousMonth)
                
                let prevRequest = FetchDescriptor<MonthlySummary>(
                    predicate: #Predicate { summary in
                        summary.year == prevYear && summary.month == prevMonthNum
                    }
                )
                
                let previousSummaries = try modelContext.fetch(prevRequest)
                let previousCumulative = previousSummaries.first?.cumulativeIncomeGEL ?? 0
                
                let newSummary = MonthlySummary(
                    year: year,
                    month: month,
                    totalIncomeGEL: amount,
                    cumulativeIncomeGEL: previousCumulative + amount,
                    paymentCount: 1
                )
                
                modelContext.insert(newSummary)
            }
            
            updateCumulativeTotals()
            try modelContext.save()
            
        } catch {
            print("Failed to update monthly summary: \(error)")
        }
    }
    
    private func updateCumulativeTotals() {
        let request = FetchDescriptor<MonthlySummary>(
            sortBy: [SortDescriptor(\.year), SortDescriptor(\.month)]
        )
        
        do {
            let summaries = try modelContext.fetch(request)
            var cumulativeTotal: Double = 0
            
            for summary in summaries {
                cumulativeTotal += summary.totalIncomeGEL
                summary.cumulativeIncomeGEL = cumulativeTotal
            }
            
        } catch {
            print("Failed to update cumulative totals: \(error)")
        }
    }
}

#Preview {
    PaymentEntryView()
        .modelContainer(for: Payment.self, inMemory: true)
}