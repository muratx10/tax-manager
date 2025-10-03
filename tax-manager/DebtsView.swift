//
//  DebtsView.swift
//  tax-manager
//
//  Created by Murat AKMAMEDAU on 29.08.2025.
//

import SwiftUI
import SwiftData
import Contacts
import AppKit

private func formatAmount(_ amount: Double) -> String {
    String(format: "%.2f", amount)
}

struct DebtsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Debt.createdDate, order: .reverse)])
    private var allDebts: [Debt]

    @State private var showingAddDebt = false
    @State private var selectedFilter: DebtFilter = .all
    @State private var searchText = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                summaryCards

                filterSection

                if filteredDebts.isEmpty {
                    emptyStateView
                } else {
                    debtsListSection
                }

                Spacer(minLength: 20)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Debts & Loans")
        .searchable(text: $searchText, prompt: "Search by name...")
        .sheet(isPresented: $showingAddDebt) {
            AddDebtView()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "creditcard.and.123")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("Debts & Loans")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Track who owes you and who you owe")
                .font(.title3)
                .foregroundColor(.secondary)

            Button(action: { showingAddDebt = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add New")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .padding(.bottom, 8)
    }

    private var summaryCards: some View {
        HStack(spacing: 16) {
            multiCurrencySummaryCard(
                title: "I Owe",
                totals: totalIOwe,
                color: .red,
                icon: "arrow.up.circle.fill"
            )

            multiCurrencySummaryCard(
                title: "Owes Me",
                totals: totalOwesMe,
                color: .green,
                icon: "arrow.down.circle.fill"
            )
        }
    }

    private func multiCurrencySummaryCard(title: String, totals: [DebtCurrency: Double], color: Color, icon: String) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            if totals.isEmpty {
                Text("0")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(color.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(totals.sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { currency, amount in
                        Text("\(formatAmount(amount)) \(currency.symbol)")
                            .font(totals.count == 1 ? .title : .title3)
                            .fontWeight(.bold)
                            .foregroundColor(color)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    private var filterSection: some View {
        HStack(spacing: 12) {
            ForEach(DebtFilter.allCases, id: \.self) { filter in
                Button(action: { selectedFilter = filter }) {
                    Text(filter.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedFilter == filter ? Color.blue : Color(NSColor.controlColor))
                        .foregroundColor(selectedFilter == filter ? .white : .primary)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 4)
    }

    private var debtsListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet")
                    .foregroundColor(.blue)
                Text("\(filteredDebts.count) Debts/Loans")
                    .font(.headline)
                Spacer()
            }

            LazyVStack(spacing: 12) {
                ForEach(filteredDebts, id: \.id) { debt in
                    DebtRowView(debt: debt)
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
            Image(systemName: "tray")
                .font(.system(size: 64))
                .foregroundColor(.gray)

            Text("No Debts Found")
                .font(.title2)
                .fontWeight(.semibold)

            Text(searchText.isEmpty ?
                 "Add a debt or loan to get started" :
                 "No debts match your search")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private var filteredDebts: [Debt] {
        var filtered = allDebts

        switch selectedFilter {
        case .all:
            break
        case .iOwe:
            filtered = filtered.filter { $0.type == .iOwe }
        case .owesMe:
            filtered = filtered.filter { $0.type == .owesMe }
        case .active:
            filtered = filtered.filter { $0.status != .paid }
        case .paid:
            filtered = filtered.filter { $0.status == .paid }
        }

        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.personName.localizedCaseInsensitiveContains(searchText)
            }
        }

        return filtered
    }

    private var totalIOwe: [DebtCurrency: Double] {
        let debts = allDebts.filter { $0.type == .iOwe && $0.status != .paid }
        var totals: [DebtCurrency: Double] = [:]

        for debt in debts {
            totals[debt.currency, default: 0] += debt.remainingAmount
        }

        return totals
    }

    private var totalOwesMe: [DebtCurrency: Double] {
        let debts = allDebts.filter { $0.type == .owesMe && $0.status != .paid }
        var totals: [DebtCurrency: Double] = [:]

        for debt in debts {
            totals[debt.currency, default: 0] += debt.remainingAmount
        }

        return totals
    }
}

enum DebtFilter: String, CaseIterable {
    case all = "All"
    case iOwe = "I Owe"
    case owesMe = "Owes Me"
    case active = "Active"
    case paid = "Paid"
}

struct DebtRowView: View {
    @Environment(\.modelContext) private var modelContext
    let debt: Debt

    @State private var showingDetails = false
    @State private var showingAddPayment = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: debt.type == .iOwe ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .foregroundColor(debt.type == .iOwe ? .red : .green)

                        Text(debt.personName)
                            .font(.headline)
                            .fontWeight(.semibold)

                        if debt.isPastDue {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }

                    HStack(spacing: 12) {
                        Text(debt.type.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if let dueDate = debt.dueDate {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption2)
                                Text("Due: \(dueDate, style: .date)")
                            }
                            .font(.caption)
                            .foregroundColor(debt.isPastDue ? .orange : .secondary)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(formatAmount(debt.remainingAmount)) \(debt.currency.symbol)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(debt.type == .iOwe ? .red : .green)

                    if debt.status != .pending {
                        Text(debt.status.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(statusColor(debt.status).opacity(0.2))
                            .foregroundColor(statusColor(debt.status))
                            .cornerRadius(4)
                    }
                }
            }

            if debt.status == .partiallyPaid {
                VStack(spacing: 4) {
                    ProgressView(value: debt.paymentProgress)
                        .tint(debt.type == .iOwe ? .red : .green)

                    HStack {
                        Text("Paid: \(formatAmount(debt.paidAmount)) of \(formatAmount(debt.originalAmount)) \(debt.currency.symbol)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }

            HStack(spacing: 8) {
                Button(action: { showingDetails.toggle() }) {
                    HStack {
                        Image(systemName: showingDetails ? "chevron.up" : "chevron.down")
                        Text(showingDetails ? "Hide Details" : "Show Details")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)

                if debt.status != .paid {
                    Button(action: { showingAddPayment = true }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Payment")
                        }
                        .font(.caption)
                        .foregroundColor(.green)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button(action: deleteDebt) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }

            if showingDetails {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    if !debt.notes.isEmpty {
                        HStack(alignment: .top) {
                            Text("Notes:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 60, alignment: .leading)
                            Text(debt.notes)
                                .font(.caption)
                        }
                    }

                    HStack {
                        Text("Created:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 60, alignment: .leading)
                        Text(debt.createdDate, style: .date)
                            .font(.caption)
                    }

                    if !debt.payments.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Payment History:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.top, 4)

                            ForEach(debt.payments.sorted(by: { $0.date > $1.date }), id: \.id) { payment in
                                HStack {
                                    Text(payment.date, style: .date)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("-")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("\(formatAmount(payment.amount)) \(debt.currency.symbol)")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                    if !payment.notes.isEmpty {
                                        Text("(\(payment.notes))")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.leading, 8)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(NSColor.separatorColor).opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
        )
        .sheet(isPresented: $showingAddPayment) {
            AddPaymentView(debt: debt)
        }
    }

    private func statusColor(_ status: DebtStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .partiallyPaid: return .blue
        case .paid: return .green
        }
    }

    private func deleteDebt() {
        modelContext.delete(debt)
        try? modelContext.save()
    }
}

struct AddDebtView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var personName = ""
    @State private var amount = ""
    @State private var selectedCurrency: DebtCurrency = .byn
    @State private var selectedType: DebtType = .owesMe
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var notes = ""
    @State private var showingContactPicker = false
    @State private var contacts: [(name: String, contact: CNContact)] = []

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Add Debt/Loan")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))

            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Person/Company Name")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Button(action: pickFromContacts) {
                                HStack(spacing: 4) {
                                    Image(systemName: "person.crop.circle")
                                    Text("Pick from Contacts")
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                        }
                        TextField("Enter name", text: $personName)
                            .textFieldStyle(.roundedBorder)
                    }

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField("0.00", text: $amount)
                                .textFieldStyle(.roundedBorder)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Currency")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Picker("Currency", selection: $selectedCurrency) {
                                ForEach(DebtCurrency.allCases, id: \.self) { currency in
                                    Text("\(currency.symbol) \(currency.rawValue)").tag(currency)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Type")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Picker("Type", selection: $selectedType) {
                            ForEach(DebtType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Set Due Date", isOn: $hasDueDate)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        if hasDueDate {
                            DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                                .datePickerStyle(.field)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (Optional)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextEditor(text: $notes)
                            .padding(8)
                            .frame(height: 80)
                            .border(Color.gray.opacity(0.2), width: 1)
                            .cornerRadius(4)
                    }

                    Button(action: saveDebt) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(isFormValid ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!isFormValid)
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
        }
        .frame(width: 500, height: 600)
        .sheet(isPresented: $showingContactPicker) {
            ContactPickerView(contacts: contacts) { selectedName in
                personName = selectedName
                showingContactPicker = false
            }
        }
    }

    private var isFormValid: Bool {
        !personName.isEmpty && !amount.isEmpty && Double(amount) != nil
    }

    private func pickFromContacts() {
        print("🔍 pickFromContacts called")
        let store = CNContactStore()

        store.requestAccess(for: .contacts) { granted, error in
            print("🔐 Access granted: \(granted), error: \(String(describing: error))")
            if granted {
                self.fetchContacts()
            } else {
                print("❌ Contact access denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func fetchContacts() {
        print("📱 fetchContacts called")
        let store = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)

        var fetchedContacts: [(name: String, contact: CNContact)] = []

        do {
            try store.enumerateContacts(with: request) { contact, _ in
                let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
                if !fullName.isEmpty {
                    fetchedContacts.append((name: fullName, contact: contact))
                }
            }

            print("✅ Fetched \(fetchedContacts.count) contacts")
            fetchedContacts.sort { $0.name < $1.name }

            DispatchQueue.main.async {
                self.contacts = fetchedContacts
                if !fetchedContacts.isEmpty {
                    print("🎯 Showing contact picker with \(fetchedContacts.count) contacts")
                    self.showingContactPicker = true
                } else {
                    print("⚠️ No contacts found")
                }
            }
        } catch {
            print("❌ Error fetching contacts: \(error)")
        }
    }

    private func saveDebt() {
        guard let amountValue = Double(amount) else { return }

        let debt = Debt(
            personName: personName,
            amount: amountValue,
            currency: selectedCurrency,
            type: selectedType,
            dueDate: hasDueDate ? dueDate : nil,
            notes: notes
        )

        modelContext.insert(debt)
        try? modelContext.save()
        dismiss()
    }
}

struct AddPaymentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let debt: Debt

    @State private var amount = ""
    @State private var paymentDate = Date()
    @State private var notes = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Add Payment")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))

            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Remaining Amount: \(String(format: "%.2f", debt.remainingAmount)) \(debt.currency.symbol)")
                        .font(.headline)
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Payment Amount")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("0.00", text: $amount)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Payment Date")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    DatePicker("", selection: $paymentDate, displayedComponents: .date)
                        .datePickerStyle(.field)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes (Optional)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextEditor(text: $notes)
                        .padding(8)
                        .frame(height: 60)
                        .border(Color.gray.opacity(0.2), width: 1)
                        .cornerRadius(4)
                }

                Button(action: savePayment) {
                    Text("Save Payment")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(isFormValid ? Color.green : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!isFormValid)
                .buttonStyle(.plain)
            }
            .padding(20)

            Spacer()
        }
        .frame(width: 400, height: 400)
    }

    private var isFormValid: Bool {
        guard let amountValue = Double(amount) else { return false }
        return amountValue > 0 && amountValue <= debt.remainingAmount
    }

    private func savePayment() {
        guard let amountValue = Double(amount) else { return }

        let payment = DebtPayment(amount: amountValue, date: paymentDate, notes: notes)
        payment.debt = debt

        debt.remainingAmount -= amountValue
        debt.lastUpdated = Date()

        if debt.remainingAmount <= 0 {
            debt.status = .paid
        } else {
            debt.status = .partiallyPaid
        }

        modelContext.insert(payment)
        try? modelContext.save()
        dismiss()
    }
}

struct ContactPickerView: View {
    let contacts: [(name: String, contact: CNContact)]
    let onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var filteredContacts: [(name: String, contact: CNContact)] {
        if searchText.isEmpty {
            return contacts
        } else {
            return contacts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Select Contact")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))

            VStack(spacing: 12) {
                TextField("Search contacts", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredContacts, id: \.contact.identifier) { contact in
                            Button(action: {
                                onSelect(contact.name)
                            }) {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                    Text(contact.name)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color(NSColor.controlBackgroundColor).opacity(0.001))
                            }
                            .buttonStyle(.plain)
                            .background(Color(NSColor.controlBackgroundColor))

                            Divider()
                        }
                    }
                }
            }
        }
        .frame(width: 400, height: 500)
    }
}

#Preview {
    DebtsView()
        .modelContainer(for: Debt.self, inMemory: true)
}
