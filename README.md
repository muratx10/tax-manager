# Tax Management App
A comprehensive macOS desktop application built with SwiftUI for managing tax-related payments and income tracking.

## Features

### 📊 Dashboard
- **Monthly Income Overview**: View current month's income and cumulative totals
- **Year Selection**: Switch between different tax years
- **Monthly Breakdown**: Detailed view of income by month
- **Quick Stats**: Total payments, companies, and income at a glance

### 💰 Payment Management
- **Multi-Currency Support**: EUR, USD, and GEL currencies
- **Automatic Exchange Rate Conversion**: Real-time rates from official sources
- **Payment History**: View, filter, and search all payment records
- **Delete Functionality**: Remove payments with confirmation dialog

### 💱 Exchange Rates
- **Live Rate Fetching**: Integration with official banking API
- **Currency Calculator**: Convert between EUR, USD, and GEL
- **Rate History**: Track exchange rate changes over time
- **Quick Actions**: Fetch current rates with one click

### 📱 User Interface
- **Modern Design**: Professional card-based UI with smooth animations
- **Dark Mode Support**: Fully adaptive light and dark theme support
- **Responsive Layout**: Optimized for different screen sizes
- **Tab Navigation**: Easy access to all features

## Technical Specifications

### Requirements
- **macOS**: 14.0 or later
- **Architecture**: Apple Silicon (arm64) and Intel (x86_64)
- **Network**: Internet connection required for exchange rate fetching

### Built With
- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Local data persistence and modeling
- **Foundation**: Core framework for networking and data handling
- **URLSession**: HTTP networking for banking API integration

### Data Models
- **Payment**: Individual payment records with currency conversion
- **ExchangeRate**: Historical exchange rate data
- **MonthlySummary**: Aggregated monthly income calculations
- **Currency**: Enum supporting EUR, USD, GEL

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
   - Choose your target device/simulator
   - Press `Cmd+R` to build and run

### App Store (Future)
*Distribution through Mac App Store is planned for future releases.*

## Usage

### Adding Payments
1. Navigate to the **"Add Payment"** tab
2. Fill in payment details:
   - Company name
   - Payment amount
   - Currency (EUR/USD/GEL)
   - Payment date
3. The app automatically fetches current exchange rates
4. Click **"Add Payment"** to save

### Viewing Payment History
1. Go to the **"History"** tab
2. Use filters to narrow down results:
   - Filter by month and year
   - Search by company name
3. Delete payments using the trash icon with confirmation

### Checking Exchange Rates
1. Open the **"Exchange Rates"** tab
2. View current live rates from NBG
3. Use the calculator to convert amounts
4. Browse historical rate data

### Dashboard Overview
1. The **"Dashboard"** tab provides:
   - Current month income summary
   - Year-over-year comparisons
   - Payment statistics
   - Monthly breakdowns

## Data Persistence

The app uses SwiftData for local storage:
- **Automatic Backup**: Data is backed up via iCloud (if enabled)
- **Local Storage**: All data stored locally on device
- **No Cloud Dependency**: Works offline except for exchange rate updates

## API Integration

### Banking API Integration
- **Endpoint**: Official banking API for exchange rates
- **Rate Limits**: Respects API rate limiting policies
- **Error Handling**: Graceful fallback for network issues
- **Caching**: Rates cached locally to reduce API calls

## Security & Privacy

### Sandboxing
- **App Sandbox**: Enabled for security
- **Network Access**: Limited to banking API endpoints
- **File Access**: User-selected files only
- **Data Protection**: All data stored locally

### Entitlements
- `com.apple.security.app-sandbox`: ✅ Enabled
- `com.apple.security.network.client`: ✅ Enabled
- `com.apple.security.files.user-selected.read-only`: ✅ Enabled

## Development

### Project Structure
```
tax-manager/
├── tax-manager/
│   ├── ContentView.swift          # Main app interface
│   ├── DashboardView.swift        # Dashboard tab
│   ├── PaymentEntryView.swift     # Payment entry form
│   ├── PaymentHistoryView.swift   # Payment history & management
│   ├── ExchangeRatesView.swift    # Exchange rates & calculator
│   ├── TaxModels.swift           # Data models
│   ├── ExchangeRateService.swift # Banking API service
│   └── Assets.xcassets           # App icons & assets
├── tax_manager.entitlements      # Security entitlements
└── README.md                     # This file
```

### Architecture
- **MVVM Pattern**: Model-View-ViewModel architecture
- **SwiftUI Views**: Declarative UI components
- **Combine Framework**: Reactive programming for data flow
- **Async/Await**: Modern concurrency for API calls

### Key Components
- **Data Layer**: SwiftData models with relationships
- **Service Layer**: Banking API integration service
- **UI Layer**: SwiftUI views with bindings
- **Navigation**: Tab-based navigation system

## Contributing

### Development Setup
1. Install Xcode 15.0 or later
2. Clone the repository
3. Open project in Xcode
4. Build and run on macOS 14.0+

### Code Style
- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Maintain consistent naming conventions
- Add documentation for public APIs

### Testing
- Unit tests for business logic
- UI tests for critical user flows
- Performance tests for data operations
- Network mocking for API tests

## Roadmap

### Planned Features
- [ ] **Payment Editing**: Modify existing payment records
- [ ] **Export Functionality**: Export data to PDF/Excel
- [ ] **Tax Calculations**: Automatic tax computation
- [ ] **Backup/Restore**: Manual backup options
- [ ] **Multiple Users**: Support for multiple tax profiles

### Known Issues
- Exchange rate fetching requires internet connectivity
- Large datasets may impact performance
- Date picker styling needs refinement

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Banking Partners**: For providing exchange rate API
- **Apple**: For SwiftUI and development tools
- **Tax Professionals**: For inspiration and requirements

## Support

### Getting Help
- **Issues**: Report bugs via GitHub Issues
- **Documentation**: Refer to inline code documentation
- **Community**: Join discussions in project discussions

### Contact
- **Developer**: Murat AKMAMEDAU
- **Created**: August 29, 2025
- **Version**: 1.0.0

---

*Built with ❤️ in Swift for professional tax management*
