//
//  ExchangeRatesView.swift
//  tax-manager
//
//  Created by Murat AKMAMEDAU on 29.08.2025.
//

import SwiftUI
import SwiftData
import Foundation

struct ExchangeRatesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\ExchangeRate.date, order: .reverse)])
    private var storedRates: [ExchangeRate]
    
    @State private var currentRates: [Currency: Double] = [:]
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedDate = Date()
    @State private var historicalRates: [Currency: Double] = [:]
    @State private var showingAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                headerSection
                
                HStack(alignment: .top, spacing: 24) {
                    VStack(spacing: 24) {
                        currentRatesCard
                        quickActionsCard
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 24) {
                        historicalRatesCard
                        rateCalculatorCard
                    }
                    .frame(maxWidth: .infinity)
                }
                
                recentRatesHistory
                
                Spacer(minLength: 20)
            }
            .padding(28)
            .frame(minWidth: 900, maxWidth: .infinity)
        }
        .navigationTitle("Exchange Rates")
        .refreshable {
            await fetchCurrentRates()
        }
        .onAppear {
            Task {
                await fetchCurrentRates()
            }
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "Unknown error occurred")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "creditcard.and.123")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Exchange Rates")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Official rates from National Bank of Georgia")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                Image(systemName: "building.columns")
                    .foregroundColor(.blue)
                Text("NBG Official Rates")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Image(systemName: "clock")
                    .foregroundColor(.green)
                Text("Real-time Updates")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.top, 8)
        }
        .padding(.bottom, 12)
    }
    
    private var currentRatesCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Live Rates")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    Task { await fetchCurrentRates() }
                }) {
                    HStack(spacing: 6) {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 14, height: 14)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .medium))
                        }
                        Text(isLoading ? "Updating..." : "Refresh")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)
            }
            
            if isLoading {
                VStack(spacing: 16) {
                    ForEach([Currency.eur, Currency.usd], id: \.self) { currency in
                        rateLoadingRow(for: currency)
                    }
                }
            } else if currentRates.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                    Text("No rates available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Check your internet connection")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 16) {
                    ForEach([Currency.eur, Currency.usd], id: \.self) { currency in
                        if let rate = currentRates[currency] {
                            modernRateRow(currency: currency, rate: rate)
                        }
                    }
                }
            }
            
            if !currentRates.isEmpty {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Updated: \(Date(), style: .time)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
        .padding(24)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
    
    private func modernRateRow(currency: Currency, rate: Double) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 10) {
                    Text(currency.symbol)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(currency == .eur ? .blue : .green)
                        .frame(width: 32, height: 32)
                        .background(
                            (currency == .eur ? Color.blue : Color.green).opacity(0.1)
                        )
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(currency.rawValue)
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text(currency == .eur ? "Euro" : "US Dollar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(rate, specifier: "%.4f") ₾")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("per 1 \(currency.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(NSColor.separatorColor).opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
        )
    }
    
    private func rateLoadingRow(for currency: Currency) -> some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 16)
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 80, height: 12)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 18)
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 70, height: 12)
            }
        }
        .padding(16)
        .background(Color(NSColor.separatorColor).opacity(0.1))
        .cornerRadius(12)
        .redacted(reason: .placeholder)
    }
    
    private var historicalRatesCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.orange)
                    .font(.title3)
                Text("Historical Rates")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Date")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.field)
                        .frame(height: 36)
                }
                
                Button(action: {
                    Task { await fetchHistoricalRates() }
                }) {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .frame(width: 16, height: 16)
                        } else {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14, weight: .medium))
                        }
                        Text(isLoading ? "Fetching..." : "Get Historical Rates")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.orange)
                    .cornerRadius(10)
                }
                .disabled(isLoading)
            }
            
            if !historicalRates.isEmpty {
                VStack(spacing: 12) {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("\(selectedDate, style: .date)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                            Spacer()
                        }
                        
                        ForEach([Currency.eur, Currency.usd], id: \.self) { currency in
                            if let rate = historicalRates[currency] {
                                HStack(spacing: 12) {
                                    Text(currency.symbol)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(currency == .eur ? .blue : .green)
                                        .frame(width: 24, height: 24)
                                        .background(
                                            (currency == .eur ? Color.blue : Color.green).opacity(0.1)
                                        )
                                        .cornerRadius(6)
                                    
                                    Text(currency.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Text("\(rate, specifier: "%.4f") ₾")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                                .padding(12)
                                .background(Color(NSColor.separatorColor).opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
    
    private var quickActionsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "bolt")
                    .foregroundColor(.purple)
                    .font(.title3)
                Text("Quick Actions")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    Task { await fetchCurrentRates() }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Refresh Rates")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text("Get latest from NBG")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .disabled(isLoading)
                
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                    Task { await fetchHistoricalRates() }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Yesterday's Rates")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text("Quick historical lookup")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.green)
                    .cornerRadius(12)
                }
                .disabled(isLoading)
            }
        }
        .padding(24)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
    
    @State private var calculatorAmount: String = ""
    @State private var calculatorCurrency: Currency = .eur
    
    private var rateCalculatorCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "function")
                    .foregroundColor(.indigo)
                    .font(.title3)
                Text("Quick Calculator")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    TextField("Amount", text: $calculatorAmount)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                    
                    Picker("Currency", selection: $calculatorCurrency) {
                        ForEach([Currency.eur, Currency.usd], id: \.self) { currency in
                            HStack {
                                Text(currency.symbol)
                                Text(currency.rawValue)
                            }.tag(currency)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 80)
                }
                
                if let amount = Double(calculatorAmount),
                   let rate = currentRates[calculatorCurrency], amount > 0 {
                    VStack(spacing: 8) {
                        Divider()
                        
                        HStack {
                            Text("Result:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(amount * rate, specifier: "%.2f") ₾")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.indigo)
                        }
                        
                        HStack {
                            Text("\(amount, specifier: "%.2f") \(calculatorCurrency.symbol)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(amount * rate, specifier: "%.2f") ₾")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("Rate: \(rate, specifier: "%.4f")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
    
    private var recentRatesHistory: some View {
        VStack(alignment: .leading, spacing: 24) {
            recentRatesHeader
            
            if storedRates.isEmpty {
                emptyHistoryView
            } else {
                historyScrollView
            }
        }
        .padding(24)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
    
    private var emptyHistoryView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Historical Data")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Fetch some rates to see history here")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var historyScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(groupedStoredRates, id: \.key) { dateGroup in
                    historyDateGroupView(dateGroup)
                }
            }
        }
        .frame(maxHeight: 400)
    }
    
    private func historyDateGroupView(_ dateGroup: (key: String, value: [ExchangeRate])) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.teal)
                
                Text(dateGroup.key)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.teal)
                
                Spacer()
                
                Text("\(dateGroup.value.count) rates")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                ForEach(dateGroup.value, id: \.id) { rate in
                    historyRateRow(rate)
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
        )
    }
    
    private func historyRateRow(_ rate: ExchangeRate) -> some View {
        let currencyColor = rate.currency == .eur ? Color.blue : Color.green
        
        return HStack(spacing: 12) {
            currencySymbolView(rate.currency, color: currencyColor)
            
            Text(rate.currency.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            rateValueText(rate.rate)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
    
    private func currencySymbolView(_ currency: Currency, color: Color) -> some View {
        Text(currency.symbol)
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(color)
            .frame(width: 20, height: 20)
            .background(color.opacity(0.1))
            .cornerRadius(4)
    }
    
    private func rateValueText(_ rate: Double) -> some View {
        Text("\(rate, specifier: "%.4f") ₾")
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .monospaced()
    }
    
    private var recentRatesHeader: some View {
        HStack {
            Image(systemName: "chart.bar.doc.horizontal")
                .foregroundColor(.teal)
                .font(.title3)
            Text("Recent Rate History")
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text("\(storedRates.count) records")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.teal.opacity(0.1))
                .cornerRadius(12)
        }
    }
    
    private var groupedStoredRates: [(key: String, value: [ExchangeRate])] {
        let recentRates = Array(storedRates.prefix(20))
        let groupedByDate = groupRatesByDate(recentRates)
        return sortGroupedRates(groupedByDate)
    }
    
    private func groupRatesByDate(_ rates: [ExchangeRate]) -> [String: [ExchangeRate]] {
        let formatter = createMediumDateFormatter()
        return Dictionary(grouping: rates) { rate in
            formatter.string(from: rate.date)
        }
    }
    
    private func sortGroupedRates(_ grouped: [String: [ExchangeRate]]) -> [(key: String, value: [ExchangeRate])] {
        let formatter = createMediumDateFormatter()
        return grouped.sorted { first, second in
            guard let firstDate = formatter.date(from: first.key),
                  let secondDate = formatter.date(from: second.key) else {
                return false
            }
            return firstDate > secondDate
        }
    }
    
    private func createMediumDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    @MainActor
    private func fetchCurrentRates() async {
        isLoading = true
        errorMessage = nil
        
        do {
            currentRates = try await ExchangeRateService.shared.fetchLatestRates()
            
            for (currency, rate) in currentRates {
                if currency != .gel {
                    let exchangeRate = ExchangeRate(
                        currency: currency,
                        rate: rate,
                        date: Date()
                    )
                    modelContext.insert(exchangeRate)
                }
            }
            
            try modelContext.save()
            
        } catch {
            errorMessage = error.localizedDescription
            showingAlert = true
        }
        
        isLoading = false
    }
    
    @MainActor
    private func fetchHistoricalRates() async {
        isLoading = true
        errorMessage = nil
        historicalRates = [:]
        
        do {
            for currency in [Currency.eur, Currency.usd] {
                let rate = try await ExchangeRateService.shared.fetchRate(for: currency, on: selectedDate)
                historicalRates[currency] = rate
                
                let exchangeRate = ExchangeRate(
                    currency: currency,
                    rate: rate,
                    date: selectedDate
                )
                modelContext.insert(exchangeRate)
            }
            
            try modelContext.save()
            
        } catch {
            errorMessage = error.localizedDescription
            showingAlert = true
        }
        
        isLoading = false
    }
}

#Preview {
    ExchangeRatesView()
        .modelContainer(for: ExchangeRate.self, inMemory: true)
}