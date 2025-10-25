//
//  MaintenanceStatsView.swift
//  tax-manager
//
//  Created by Murat AKMAMEDAU on 25.10.2025.
//

import SwiftUI
import SwiftData
import Charts

struct MaintenanceStatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\MaintenanceRecord.date, order: .reverse)])
    private var allRecords: [MaintenanceRecord]

    @State private var selectedYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                totalCostCard

                yearSelectorCard

                costByTypeCard

                monthlyBreakdownCard

                Spacer(minLength: 20)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Maintenance Stats")
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("Maintenance Statistics")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Track your vehicle expenses")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 8)
    }

    private var totalCostCard: some View {
        let totalCost = allRecords.reduce(0.0) { total, record in
            let costInGEL: Double
            switch record.currency {
            case .gel:
                costInGEL = record.cost
            case .eur:
                costInGEL = record.cost * 3.0
            case .usd:
                costInGEL = record.cost * 2.8
            }
            return total + costInGEL
        }

        return VStack(spacing: 16) {
            HStack {
                Image(systemName: "sum")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Total Expenses (All Time)")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            VStack(spacing: 8) {
                Text("₾\(String(format: "%.2f", totalCost))")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.primary)

                Text("\(allRecords.count) service\(allRecords.count == 1 ? "" : "s") recorded")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var yearSelectorCard: some View {
        let availableYears = Array(Set(allRecords.map {
            Calendar.current.component(.year, from: $0.date)
        })).sorted(by: >)

        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Select Year")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            if availableYears.isEmpty {
                Text("No data available")
                    .foregroundColor(.secondary)
            } else {
                Picker("Year", selection: $selectedYear) {
                    ForEach(availableYears, id: \.self) { year in
                        Text("\(year)").tag(year)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var costByTypeCard: some View {
        let yearRecords = allRecords.filter {
            Calendar.current.component(.year, from: $0.date) == selectedYear
        }

        let costByType = Dictionary(grouping: yearRecords, by: { $0.type })
            .mapValues { records in
                records.reduce(0.0) { total, record in
                    let costInGEL: Double
                    switch record.currency {
                    case .gel:
                        costInGEL = record.cost
                    case .eur:
                        costInGEL = record.cost * 3.0
                    case .usd:
                        costInGEL = record.cost * 2.8
                    }
                    return total + costInGEL
                }
            }
            .sorted { $0.value > $1.value }

        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.pie")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Cost by Service Type (\(selectedYear))")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            if costByType.isEmpty {
                Text("No data for \(selectedYear)")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(costByType, id: \.key) { type, cost in
                    HStack {
                        Label(type.rawValue, systemImage: type.icon)
                            .font(.subheadline)

                        Spacer()

                        Text("₾\(String(format: "%.2f", cost))")
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var monthlyBreakdownCard: some View {
        let yearRecords = allRecords.filter {
            Calendar.current.component(.year, from: $0.date) == selectedYear
        }

        let monthlyData = Dictionary(grouping: yearRecords) { record in
            Calendar.current.component(.month, from: record.date)
        }
        .mapValues { records in
            records.reduce(0.0) { total, record in
                let costInGEL: Double
                switch record.currency {
                case .gel:
                    costInGEL = record.cost
                case .eur:
                    costInGEL = record.cost * 3.0
                case .usd:
                    costInGEL = record.cost * 2.8
                }
                return total + costInGEL
            }
        }
        .sorted { $0.key < $1.key }

        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Monthly Breakdown (\(selectedYear))")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            if monthlyData.isEmpty {
                Text("No data for \(selectedYear)")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(monthlyData, id: \.key) { month, cost in
                    let monthName = DateFormatter().monthSymbols[month - 1]

                    HStack {
                        Text(monthName)
                            .font(.subheadline)
                            .frame(width: 100, alignment: .leading)

                        Spacer()

                        Text("₾\(String(format: "%.2f", cost))")
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}
