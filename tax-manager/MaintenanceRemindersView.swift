//
//  MaintenanceRemindersView.swift
//  tax-manager
//
//  Created by Murat AKMAMEDAU on 25.10.2025.
//

import SwiftUI
import SwiftData

struct MaintenanceRemindersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\MaintenanceRecord.date, order: .reverse)])
    private var allRecords: [MaintenanceRecord]

    @State private var currentMileage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                currentMileageCard

                upcomingServicesCard

                Spacer(minLength: 20)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Service Reminders")
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "bell.badge")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Service Reminders")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Track upcoming maintenance")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 8)
    }

    private var currentMileageCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "gauge")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Current Mileage")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            HStack(spacing: 12) {
                TextField("Enter current mileage", text: $currentMileage)
                    .textFieldStyle(.roundedBorder)
                    .frame(height: 32)

                Text("km")
                    .foregroundColor(.secondary)
            }

            if let lastRecord = allRecords.first {
                Text("Last recorded: \(lastRecord.mileage) km on \(lastRecord.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var upcomingServicesCard: some View {
        let upcomingServices = allRecords
            .filter { $0.nextServiceMileage != nil || $0.nextServiceDate != nil }
            .sorted { record1, record2 in
                if let mileage1 = record1.nextServiceMileage, let mileage2 = record2.nextServiceMileage {
                    return mileage1 < mileage2
                }
                return true
            }

        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet.clipboard")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Upcoming Services")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            if upcomingServices.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.green)

                    Text("No upcoming services scheduled")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("Add next service reminders when logging maintenance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
            } else {
                ForEach(upcomingServices) { record in
                    ServiceReminderRow(
                        record: record,
                        currentMileage: Int(currentMileage) ?? 0
                    )
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct ServiceReminderRow: View {
    let record: MaintenanceRecord
    let currentMileage: Int

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: record.type.icon)
                .font(.title2)
                .foregroundColor(statusColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 6) {
                Text(record.type.rawValue)
                    .font(.headline)

                if let nextMileage = record.nextServiceMileage {
                    HStack(spacing: 8) {
                        Image(systemName: "gauge.medium")
                            .font(.caption)
                        Text("\(nextMileage) km")
                            .font(.subheadline)

                        if currentMileage > 0 {
                            let remaining = nextMileage - currentMileage
                            if remaining > 0 {
                                Text("(\(remaining) km left)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("(OVERDUE by \(-remaining) km)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }

                if let nextDate = record.nextServiceDate {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(nextDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)

                        let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: nextDate).day ?? 0
                        if daysUntil < 0 {
                            Text("(OVERDUE)")
                                .font(.caption)
                                .foregroundColor(.red)
                                .fontWeight(.semibold)
                        } else if daysUntil < 30 {
                            Text("(\(daysUntil) days)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }

                Text("Last service: \(record.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            statusIndicator
        }
        .padding(16)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(statusColor.opacity(0.3), lineWidth: 2)
        )
    }

    private var statusColor: Color {
        if let nextMileage = record.nextServiceMileage, currentMileage > 0 {
            let remaining = nextMileage - currentMileage
            if remaining < 0 {
                return .red
            } else if remaining < 1000 {
                return .orange
            }
        }

        if let nextDate = record.nextServiceDate {
            let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: nextDate).day ?? 0
            if daysUntil < 0 {
                return .red
            } else if daysUntil < 30 {
                return .orange
            }
        }

        return .green
    }

    private var statusIndicator: some View {
        Group {
            if let nextMileage = record.nextServiceMileage, currentMileage > 0 {
                let remaining = nextMileage - currentMileage
                if remaining < 0 {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                } else if remaining < 1000 {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            } else {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
            }
        }
    }
}
