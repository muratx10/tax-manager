//
//  AddMaintenanceView.swift
//  tax-manager
//
//  Created by Murat AKMAMEDAU on 25.10.2025.
//

import SwiftUI
import SwiftData

struct AddMaintenanceView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedType: MaintenanceType = .oilChange
    @State private var selectedDate = Date()
    @State private var mileage = ""
    @State private var cost = ""
    @State private var selectedCurrency: Currency = .gel
    @State private var notes = ""
    @State private var nextServiceMileage = ""
    @State private var nextServiceDate: Date?
    @State private var hasNextService = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                serviceDetailsCard

                nextServiceCard

                saveButtonSection

                Spacer(minLength: 20)
            }
            .padding(24)
            .frame(maxWidth: 600)
        }
        .navigationTitle("Add Maintenance")
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

            Text("Add Maintenance Record")
                .font(.largeTitle)
                .fontWeight(.semibold)

            Text("Log your vehicle service and maintenance")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 8)
    }

    private var serviceDetailsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "wrench.and.screwdriver")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Service Details")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Service Type")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Picker("Type", selection: $selectedType) {
                        ForEach(MaintenanceType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .labelsHidden()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mileage (km)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        TextField("0", text: $mileage)
                            .textFieldStyle(.roundedBorder)
                            .frame(height: 32)
                    }
                }

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cost")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        TextField("0.00", text: $cost)
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
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes (optional)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    TextEditor(text: $notes)
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var nextServiceCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                Text("Next Service Reminder")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Toggle("Set next service reminder", isOn: $hasNextService)
                .toggleStyle(.switch)

            if hasNextService {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Next Service Mileage (km)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        TextField("0", text: $nextServiceMileage)
                            .textFieldStyle(.roundedBorder)
                            .frame(height: 32)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Next Service Date (optional)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        DatePicker("", selection: Binding(
                            get: { nextServiceDate ?? Date() },
                            set: { nextServiceDate = $0 }
                        ), displayedComponents: .date)
                        .labelsHidden()
                    }
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }

    private var saveButtonSection: some View {
        Button(action: saveRecord) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Save Record")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .disabled(mileage.isEmpty || cost.isEmpty)
    }

    private func saveRecord() {
        guard let mileageInt = Int(mileage),
              let costDouble = Double(cost.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "Please enter valid mileage and cost"
            showingAlert = true
            return
        }

        let nextMileage = hasNextService && !nextServiceMileage.isEmpty ? Int(nextServiceMileage) : nil
        let nextDate = hasNextService ? nextServiceDate : nil

        let record = MaintenanceRecord(
            date: selectedDate,
            mileage: mileageInt,
            type: selectedType,
            cost: costDouble,
            currency: selectedCurrency,
            notes: notes,
            nextServiceMileage: nextMileage,
            nextServiceDate: nextDate
        )

        modelContext.insert(record)

        do {
            try modelContext.save()
            alertMessage = "Maintenance record saved successfully!"
            clearForm()
        } catch {
            alertMessage = "Error saving record: \(error.localizedDescription)"
        }

        showingAlert = true
    }

    private func clearForm() {
        mileage = ""
        cost = ""
        notes = ""
        nextServiceMileage = ""
        nextServiceDate = nil
        hasNextService = false
        selectedDate = Date()
    }
}
