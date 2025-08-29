# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
This is a comprehensive macOS desktop application for personal tax management built with SwiftUI and SwiftData. The app helps Georgian tax residents manage multi-currency income from different companies, automatically converting EUR/USD payments to GEL using official exchange rates from the National Bank of Georgia.

## Key Features
- Multi-currency payment tracking (EUR, USD, GEL)
- Automatic exchange rate fetching from NBG API
- Monthly income summaries with cumulative totals
- Payment history with filtering and search
- Dashboard with visual summaries and quick stats
- Local data persistence using SwiftData

## Architecture

### Data Models (`TaxModels.swift`)
- **Payment**: Core payment entity with company, amount, currency, date, exchange rate
- **ExchangeRate**: Historical exchange rate data from NBG
- **MonthlySummary**: Calculated monthly totals and cumulative amounts
- **Currency**: Enum supporting EUR, USD, GEL with symbols

### Views Structure
- **ContentView.swift**: Main TabView navigation with 4 tabs
- **DashboardView.swift**: Monthly summaries, year selector, and quick stats
- **PaymentEntryView.swift**: Form for adding new payments with rate fetching
- **PaymentHistoryView.swift**: Searchable payment history with filtering
- **ExchangeRatesView.swift**: Current and historical exchange rates

### Services
- **ExchangeRateService.swift**: Fetches exchange rates from NBG API
  - Endpoint: `https://nbg.gov.ge/gw/api/ct/monetarypolicy/currencies`
  - Supports historical and current rate fetching

## Development Commands

### Building and Running
```bash
# Open project in Xcode
open tax-manager.xcodeproj

# Build from command line
xcodebuild -project tax-manager.xcodeproj -scheme tax-manager build

# Run tests
xcodebuild test -project tax-manager.xcodeproj -scheme tax-manager
```

### Key Files Structure
- `tax-manager/` - Main app target containing Swift source files
- `TaxModels.swift` - Core data models for payments, rates, summaries
- `ExchangeRateService.swift` - NBG API integration service
- `PaymentEntryView.swift` - Payment input form with validation
- `DashboardView.swift` - Main overview with monthly calculations
- `PaymentHistoryView.swift` - Historical data with search/filter
- `ExchangeRatesView.swift` - Exchange rate management

## SwiftData Integration
The app uses SwiftData for local persistence with:
- ModelContainer configured with Payment, ExchangeRate, MonthlySummary models
- @Query property wrapper for reactive data fetching
- @Environment(\.modelContext) for CRUD operations
- Automatic monthly summary calculations and cumulative totals

## API Integration
- Uses National Bank of Georgia public API for exchange rates
- Handles both current and historical rate fetching
- Automatic rate caching and local storage
- Error handling for network failures

## Business Logic
- Automatic GEL conversion based on payment date exchange rates
- Monthly summary generation with cumulative calculations
- Payment validation and duplicate detection
- Historical data filtering and search capabilities

## Target Platform
- macOS desktop application
- Minimum frame size: 800x600
- Designed for personal/private use
- Local data storage only (no cloud sync)