//
//  MaintenanceHistoryView.swift
//  tax-manager
//
//  Created by Murat AKMAMEDAU on 25.10.2025.
//

import SwiftUI
import SwiftData

struct MaintenanceHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\MaintenanceRecord.date, order: .reverse)])
    private var allRecords: [MaintenanceRecord]

    @State private var selectedType: MaintenanceType?
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var recordToDelete: MaintenanceRecord?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                filterSection

                if filteredRecords.isEmpty {
                    emptyStateView
                } else {
                    recordsContent
                }

                Spacer(minLength: 20)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Maintenance History")
        .alert("Delete Record", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let record = recordToDelete {
                    deleteRecord(record)
                }
            }
        } message: {
            Text("Are you sure you want to delete this maintenance record?")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "wrench.and.screwdriver")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("Maintenance History")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("View all your vehicle service records")
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

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Service Type")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        Picker("Type", selection: $selectedType) {
                            Text("All Types").tag(nil as MaintenanceType?)
                            ForEach(MaintenanceType.allCases, id: \.self) { type in
                                Label(type.rawValue, systemImage: type.icon)
                                    .tag(type as MaintenanceType?)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(minWidth: 180)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Search Notes")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        TextField("Search...", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .frame(minWidth: 200)
                    }

                    Spacer()

                    if selectedType != nil || !searchText.isEmpty {
                        Button("Clear Filters") {
                            selectedType = nil
                            searchText = ""
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var recordsContent: some View {
        VStack(spacing: 16) {
            HStack {
                Text("\(filteredRecords.count) Record\(filteredRecords.count == 1 ? "" : "s")")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
            }

            ForEach(filteredRecords) { record in
                MaintenanceRecordRow(record: record) {
                    recordToDelete = record
                    showingDeleteAlert = true
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "car")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("No maintenance records")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add your first service record to start tracking")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(60)
    }

    private var filteredRecords: [MaintenanceRecord] {
        allRecords.filter { record in
            let matchesType = selectedType == nil || record.type == selectedType
            let matchesSearch = searchText.isEmpty || record.notes.localizedCaseInsensitiveContains(searchText)
            return matchesType && matchesSearch
        }
    }

    private func deleteRecord(_ record: MaintenanceRecord) {
        modelContext.delete(record)
        try? modelContext.save()
    }
}

struct MaintenanceRecordRow: View {
    let record: MaintenanceRecord
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: record.type.icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(record.type.rawValue)
                    .font(.headline)

                HStack(spacing: 12) {
                    Label("\(record.mileage) km", systemImage: "gauge")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Label(record.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if !record.notes.isEmpty {
                    Text(record.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.2f", record.cost))")
                    .font(.headline)
                    .foregroundColor(.primary)

                if let nextMileage = record.nextServiceMileage {
                    Text("Next: \(nextMileage) km")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .help("Delete record")
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}
