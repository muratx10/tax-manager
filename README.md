# Personal Manager

A comprehensive macOS desktop application built with SwiftUI for managing personal finances, debts, and vehicle maintenance. Modular design allows easy expansion with new features.

## Overview

Personal Manager is a multi-module personal management application with:
- **Modular Architecture**: Easy-to-navigate sidebar with independent modules
- **Finance Tracking**: Income, taxes, and multi-currency payments
- **Debt Management**: Track debts and loans with contacts integration
- **Vehicle Maintenance**: Car service tracking with reminders

## Modules

### 💰 Finance Module
Complete financial tracking with tax calculations.

**Features:**
- **Dashboard**: Monthly/yearly income overview with cumulative totals
- **Add Payment**: Multi-currency payment entry (EUR, USD, GEL)
- **Payment History**: Filter by date, search by company
- **Exchange Rates**: Live rates from banking API with calculator

**Tax Calculation:**
- Automatic 1% tax computation on income
- GEL-based tax reporting
- Monthly and cumulative tracking

### 💳 Debts & Loans Module
Track money owed and borrowed.

**Features:**
- **Debt Tracking**: Record debts with type (I Owe / Owes Me)
- **Payment History**: Track partial payments and settlements
- **Contacts Integration**: Quick contact selection from macOS Contacts
- **Status Management**: Pending, Partially Paid, Paid
- **Multi-Currency**: EUR, USD, GEL, BYN support

### 🚗 Car Maintenance Module
Vehicle service tracking and expense management.

**Features:**
- **Service History**: Complete maintenance log with filtering
- **Add Service**: Log oil changes, tires, brakes, inspections, etc.
- **Statistics**: Track expenses by service type and month
- **Reminders**: Mileage and date-based service notifications
- **USD Only**: All costs tracked in US dollars

**Service Types:**
- Oil Change
- Inspection (Technical)
- Tires
- Brakes
- Filters
- Other

## Technical Specifications

### Requirements
- **macOS**: 14.0 or later
- **Architecture**: Universal (Apple Silicon + Intel)
- **Network**: Internet required for exchange rates

### Built With
- **SwiftUI**: Modern UI framework
- **SwiftData**: Local data persistence
- **Contacts Framework**: macOS contacts integration
- **Foundation**: Networking and data handling

### Data Models

**Finance Module:**
- `Payment`: Payment records with currency conversion
- `ExchangeRate`: Historical exchange rate data
- `MonthlySummary`: Monthly aggregated income
- `Currency`: EUR, USD, GEL

**Debts Module:**
- `Debt`: Debt/loan records with status
- `DebtPayment`: Payment history entries
- `DebtCurrency`: EUR, USD, GEL, BYN
- `DebtType`: I Owe, Owes Me
- `DebtStatus`: Pending, Partially Paid, Paid

**Car Maintenance Module:**
- `MaintenanceRecord`: Service records with mileage
- `MaintenanceType`: Oil, Tires, Brakes, Inspection, etc.

## Installation

### Building from Source
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd tax-manager
   ```

2. Open in Xcode:
   ```bash
   open tax-manager.xcodeproj
   ```

3. Build and run:
   - Select the `tax-manager` scheme
   - Press `Cmd+R` to build and run

## Usage

### Finance Module

**Adding Payments:**
1. Select Finance module from sidebar
2. Go to "Add Payment" tab
3. Enter company, amount, currency, and date
4. Exchange rate fetched automatically
5. Save to record payment

**Viewing Dashboard:**
- Current month income and tax
- Year-to-date cumulative totals
- Monthly breakdown with charts
- Quick statistics

### Debts Module

**Adding Debts:**
1. Select Debts & Loans module
2. Click "Add New" button
3. Choose contact or enter name manually
4. Set debt type (I Owe / Owes Me)
5. Enter amount, currency, and notes
6. Set due date (optional)

**Recording Payments:**
- Click on debt to view details
- Add payment entries
- Track status automatically updates
- View complete payment history

### Car Maintenance Module

**Logging Service:**
1. Select Car Maintenance module
2. Go to "Add Service" tab
3. Choose service type
4. Enter date, mileage, and cost (USD)
5. Add notes (optional)
6. Set next service reminder

**Viewing Statistics:**
- Total expenses (all-time)
- Cost breakdown by service type
- Monthly expense analysis
- Year selector for historical data

**Service Reminders:**
- Enter current mileage
- View upcoming services
- Color-coded status indicators
- Overdue notifications

## Data Persistence

- **SwiftData**: All data stored locally
- **iCloud Backup**: Automatic if enabled
- **No Cloud Dependency**: Works fully offline (except exchange rates)
- **Data Isolation**: Each module's data is independent

## API Integration

### Banking API
- **Exchange Rates**: Real-time currency conversion
- **Caching**: Local rate storage to reduce calls
- **Error Handling**: Graceful fallback on network issues

## Project Structure

```
tax-manager/
├── tax-manager/
│   ├── PersonalManagerApp.swift      # App entry point
│   ├── Module.swift                  # Module definitions
│   ├── ModuleSidebar.swift          # Navigation sidebar
│   ├── ContentView.swift            # Main container
│   │
│   ├── Finance Module/
│   │   ├── DashboardView.swift
│   │   ├── PaymentEntryView.swift
│   │   ├── PaymentHistoryView.swift
│   │   ├── ExchangeRatesView.swift
│   │   ├── TaxModels.swift
│   │   └── ExchangeRateService.swift
│   │
│   ├── Debts Module/
│   │   ├── DebtsView.swift
│   │   └── DebtModels.swift
│   │
│   ├── Car Maintenance Module/
│   │   ├── MaintenanceHistoryView.swift
│   │   ├── AddMaintenanceView.swift
│   │   ├── MaintenanceStatsView.swift
│   │   ├── MaintenanceRemindersView.swift
│   │   └── CarMaintenanceModels.swift
│   │
│   └── Assets.xcassets
└── README.md
```

## Architecture

### Modular Design
- **Independent Modules**: Each module is self-contained
- **Easy Expansion**: Add new modules by extending `AppModule` enum
- **Sidebar Navigation**: Consistent navigation across modules
- **Module Persistence**: Last selected module is remembered

### MVVM Pattern
- **Models**: SwiftData models for persistence
- **Views**: SwiftUI declarative components
- **ViewModels**: ObservableObject for state management

### Key Components
- **Module System**: Enum-based module definitions
- **Data Layer**: SwiftData with relationships
- **Service Layer**: API integration services
- **UI Layer**: SwiftUI views with bindings

## Security & Privacy

### Permissions Required
- **Network Access**: For exchange rate API
- **Contacts**: Optional, for debt management

### Data Privacy
- **Local Storage**: All data stays on device
- **No Telemetry**: Zero data collection
- **Sandboxed**: Full macOS app sandboxing

## Roadmap

### Planned Features
- [ ] **Export**: PDF/Excel export for all modules
- [ ] **Backup/Restore**: Manual data export/import
- [ ] **Fuel Tracking**: Gas mileage and cost tracking
- [ ] **Multiple Vehicles**: Support for multiple cars
- [ ] **Task Manager**: Personal task tracking module
- [ ] **Notes Module**: Quick notes and reminders

### Known Issues
- Exchange rates require internet connection
- Large datasets may impact performance

## Contributing

### Development Setup
1. Install Xcode 15.0+
2. Clone repository
3. Open in Xcode
4. Build and run

### Code Style
- Swift API Design Guidelines
- SwiftUI best practices
- Clear naming conventions
- Inline documentation

## License

MIT License - see LICENSE file for details.

## Contact

- **Developer**: Murat AKMAMEDAU
- **Created**: August 2025
- **Updated**: October 2025
- **Version**: 2.0.0

---

*Multi-module personal management for macOS*
