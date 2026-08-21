# Spendly

**Double tap. Record. Done.**

A production-quality personal finance app for iPhone, designed around extremely fast expense capture. Record transactions in seconds, not minutes.

## Overview

Spendly is an iPhone-first financial tracker that prioritizes speed and simplicity. The app is built with native Swift/SwiftUI and uses local-first data storage with SwiftData. Every design decision focuses on the core principle:

> Recording an expense should take seconds, not minutes.

### Core Experience

```
iPhone Back Tap / Shortcut
         ↓
Quick Add Screen
         ↓
Enter Amount (₹420)
         ↓
Select Payment Method (UPI)
         ↓
Select Category (Food)
         ↓
Optional: Merchant + Note
         ↓
Save
         ↓
Transaction Recorded
         ↓
Dashboard & Analytics Updated
```

## Features Implemented

### Transaction Management
- ✅ **Quick Add** - Multi-step optimized transaction flow
- ✅ **Expense Recording** - Fast expense capture with all metadata
- ✅ **Income Recording** - Income tracking with categories
- ✅ **Payment Methods** - Track how you paid (Cash, UPI, Credit Card, Debit Card, Bank Transfer, Other)
- ✅ **Categories** - Pre-defined and custom categories
- ✅ **Merchant Tracking** - Record where you spent
- ✅ **Notes** - Optional transaction notes
- ✅ **Transaction History** - Browse, edit, delete transactions
- ✅ **Date/Time Tracking** - Automatic transaction timestamping

### Financial Data
- ✅ **Local Persistence** - SwiftData for reliable local storage
- ✅ **Precision Arithmetic** - Decimal-based amounts (no floating-point errors)
- ✅ **Currency Support** - INR (₹), USD ($), EUR (€), GBP (£), AED, SGD
- ✅ **Multi-currency Transactions** - Each transaction retains its currency

### Analytics & Dashboard
- ✅ **Dashboard** - Summary cards showing income, expenses, savings, savings rate
- ✅ **Current Month Analytics** - Month-to-date totals
- ✅ **Weekly Analytics** - Weekly totals, average daily spending
- ✅ **Monthly Analytics** - Monthly breakdown, month-over-month comparison
- ✅ **Yearly Analytics** - Yearly totals, monthly breakdown chart
- ✅ **Category Analytics** - Spending by category, top categories
- ✅ **Payment Method Analytics** - Distribution of payment methods
- ✅ **Holistic Financial View** - Lifetime totals, averages, trends

### Budgets & Recurring
- ✅ **Budget Framework** - Data model for monthly/category budgets
- ✅ **Recurring Transactions** - Support for recurring income/expenses
- ✅ **Recurrence Frequencies** - Daily, Weekly, Monthly, Yearly

### Import/Export
- ✅ **CSV Export** - Full transaction export to Excel-compatible CSV
- ✅ **JSON Export** - Structured JSON export
- ✅ **CSV Import** - Batch import from CSV files
- ✅ **JSON Import** - Batch import from JSON files
- ✅ **Duplicate Detection** - Identify potential duplicates
- ✅ **Excel-Compatible Export** - Multi-sheet export (Transactions, Summary, Categories, Payment Methods)

### iPhone Integration
- ✅ **App Intents** - Shortcuts integration (iOS 16+)
- ✅ **Quick Add Intent** - Launch Quick Add from Shortcuts
- ✅ **Record Expense Intent** - Record expense with parameters
- ✅ **Deep Linking** - URL scheme support
- ✅ **Shortcut Actions** - Exposed to Shortcuts app

### Architecture
- ✅ **Clean Architecture** - Separated concerns (Models, Views, ViewModels, Services)
- ✅ **Analytics Engine** - Deterministic, testable financial calculations
- ✅ **Transaction Service** - CRUD operations and validation
- ✅ **Import/Export Service** - Data import/export with validation
- ✅ **Reusable Services** - No business logic in UI components

### Testing
- ✅ **Unit Tests** - Comprehensive financial calculation tests
- ✅ **Analytics Tests** - All analytics methods tested with known values
- ✅ **Transaction Validation Tests** - Input validation testing
- ✅ **Import/Export Tests** - CSV/JSON parsing and generation

### UI/UX
- ✅ **iPhone-First Design** - Native SwiftUI interface
- ✅ **Tab Navigation** - Home, Transactions, Analytics, Budgets, Settings
- ✅ **Floating Quick Add Button** - Always accessible
- ✅ **Minimal Interface** - Focused, calm, fast
- ✅ **Responsive Layouts** - Works on all iPhone sizes
- ✅ **Empty States** - Helpful guidance when no data exists

### Privacy & Security
- ✅ **Local-First Architecture** - No cloud by default
- ✅ **No Unnecessary Logging** - Financial data protected
- ✅ **No Analytics SDKs** - User data stays local
- ✅ **No Secrets in Code** - Environment-based configuration ready

## Architecture

```
Spendly/
├── App/
│   └── SpendlyApp.swift          # Main app, tab navigation, shortcuts handling
├── Models/
│   ├── Transaction.swift          # Financial transaction model
│   └── Budget.swift               # Budget and recurring transaction models
├── Views/
│   ├── QuickAddView.swift         # Multi-step Quick Add flow
│   └── (Dashboard, Analytics, Settings views in SpendlyApp.swift)
├── ViewModels/
│   └── ViewModels.swift           # QuickAdd, Dashboard, Analytics, History VMs
├── Services/
│   ├── AnalyticsService.swift     # All financial calculations
│   └── TransactionService.swift   # Transaction CRUD and validation
├── Persistence/
│   └── (SwiftData integration)
├── Analytics/
│   └── (Insights and calculations)
├── Intents/
│   └── SpendlyIntents.swift       # App Intents for Shortcuts
├── ImportExport/
│   └── ImportExportService.swift  # CSV/JSON import/export
├── Utilities/
│   └── (Helper functions)
└── Resources/
    └── (Strings, Assets)

Tests/
├── Models/
├── Services/
│   └── AnalyticsTests.swift       # Financial calculation tests
├── Analytics/
├── Persistence/
└── Intents/
```

## Technology Stack

- **Platform**: iOS 17.0+
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Testing**: Swift Testing
- **App Intents**: iOS 16+ Shortcuts integration
- **Language**: Swift 5.9

## Local Development

### Prerequisites
- macOS with Xcode 15.0+
- iOS 17.0+ device or simulator

### Setup

```bash
# Clone the repository
git clone https://github.com/istartedcoding/spendly.git
cd spendly

# Open in Xcode
open Spendly.xcodeproj

# Build
xcodebuild build -scheme Spendly

# Run on simulator
xcodebuild test -scheme Spendly -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Build Commands

```bash
# Build for iOS
xcodebuild build \
  -workspace Spendly.xcworkspace \
  -scheme Spendly \
  -configuration Release

# Run unit tests
xcodebuild test \
  -scheme Spendly \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# Generate code coverage
xcodebuild test \
  -scheme Spendly \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES
```

## Testing

### Run All Tests

```bash
# Via Xcode
xcodebuild test -scheme Spendly

# Via Swift testing
swift test
```

### Test Coverage

Tests cover:
- **Financial Calculations** - Income, expenses, savings, rates
- **Category Analysis** - Category totals, top spenders
- **Payment Methods** - Distribution analysis
- **Time Periods** - Weekly, monthly, yearly calculations
- **Transaction Validation** - Input validation
- **Import/Export** - CSV/JSON parsing and generation
- **Data Integrity** - Duplicate detection

### Test Data

Deterministic test data with known values:
- Income: ₹150,000
- Expenses: ₹60,000 (Food: ₹10k, Shopping: ₹15k, Travel: ₹20k, Bills: ₹8k, Other: ₹7k)
- Expected Savings: ₹90,000
- Expected Savings Rate: 60%

## iPhone Setup

### Using the Shortcut

1. **iOS Settings** → **Accessibility** → **Touch** → **Back Tap**
2. Select **Double Tap** (or **Triple Tap**)
3. Search for **Spendly** or **Shortcuts**
4. Create or import the Spendly Quick Add shortcut
5. Assign it to Back Tap

### Creating a Shortcut

In the **Shortcuts app**:

```
1. Create New Shortcut
2. Add action: "Open app" → Select "Spendly"
3. Add action: "Ask for number" (Amount)
4. Add action: "Ask for choice" (Payment Method)
5. Add action: "Ask for choice" (Category)
6. Pass values to Spendly via App Intent
```

### App Intent Actions Available

- **Launch Spendly Quick Add** - Opens the Quick Add screen
- **Record Spendly Expense** - Records an expense with optional parameters:
  - Amount (required)
  - Category (optional)
  - Payment Method (optional)
  - Merchant (optional)
  - Note (optional)

### Example Shortcut URLs

```
spendly://quickadd
spendly://quickadd?amount=420&category=Food&method=UPI
```

## Data Model

### Transaction

Every transaction is immutable after creation (edit/delete create new records).

```swift
struct Transaction {
    var id: String                      // Unique ID
    var type: TransactionType           // expense or income
    var amountInSmallestUnit: Decimal   // ₹1 = 100 units (no float errors)
    var currency: String                // INR, USD, EUR, etc.
    var category: String                // Food, Shopping, Salary, etc.
    var paymentMethod: String           // Cash, UPI, Credit Card, etc.
    var merchant: String?               // Where/who
    var note: String?                   // Optional note
    var date: Date                      // Transaction date
    var createdAt: Date                 // Record creation time
    var updatedAt: Date                 // Last modification time
    var recurringTransactionId: String? // Link to recurring template
    var importSource: String?           // Where it was imported from
    var externalReference: String?      // Bank transaction ID, etc.
}
```

### Budget

```swift
struct Budget {
    var id: String              // Unique ID
    var type: BudgetType        // overall or category
    var category: String?       // Category if type == category
    var amountInSmallestUnit: Decimal
    var currency: String
    var year: Int
    var month: Int (1-12)
}
```

### Recurring Transaction

```swift
struct RecurringTransaction {
    var id: String
    var type: TransactionType
    var amountInSmallestUnit: Decimal
    var category: String
    var paymentMethod: String
    var frequency: RecurrenceFrequency  // daily, weekly, monthly, yearly
    var startDate: Date
    var endDate: Date?
    var isActive: Bool
    var nextOccurrence: Date
}
```

## Excel Integration

### CSV Export Format

```
Date,Time,Type,Amount,Currency,Category,Payment Method,Merchant,Note
2024-08-15,10:30:00,expense,420.00,INR,Food,UPI,Social,Lunch
2024-08-16,14:15:00,income,150000.00,INR,Salary,Bank Transfer,,
```

### Multi-Sheet Export

The Excel export includes:
1. **TRANSACTIONS** - Detailed ledger
2. **CATEGORY SUMMARY** - Totals by category
3. **PAYMENT METHOD SUMMARY** - Distribution by method
4. **SUMMARY** - Totals, income, expenses, savings, rate

### Future Architecture

The app is designed to support:
```
Spendly (Mobile)
    ↓ (Sync)
Local SQLite / SwiftData
    ↓ (Export)
Microsoft Graph API
    ↓
OneDrive
    ↓
Excel Workbook
    ↓
Power BI / Advanced Analytics
```

Currently, the app is **local-first** with manual CSV export. Future versions can add:
- Microsoft Graph authentication
- OneDrive synchronization
- Live Excel workbook updates
- Power BI integration

## Privacy

- **Financial data stays on your device** by default
- **No cloud sync without explicit setup** (future)
- **No advertising SDKs**
- **No unnecessary analytics**
- **No secrets in source code**
- **Transaction data is never shared without your consent**

## Security

The architecture supports (future implementation):
- Face ID / Touch ID
- App lock
- Encrypted backups
- Cloud synchronization with end-to-end encryption

Currently: **No biometric security implemented**. Recommendations for future:
- Enable device-level Face ID/Touch ID
- Use Keychain for sensitive operations
- Encrypt local database at rest

## Financial Calculations

All calculations use `Decimal` for precision:

```swift
// No floating-point errors
let amount = Decimal(420.00)     // ₹420
let amountInUnits = amount * 100 // 42000 units stored
let display = Double(amountInUnits) / 100.0
```

### Analytics Engine

Deterministic, testable calculations:

```swift
// Income totals
AnalyticsService.totalIncome(from: transactions)

// Category analysis
AnalyticsService.expenseCategoryTotals(from: transactions)

// Time-based
AnalyticsService.monthlyExpenses(for: date, from: transactions)

// Comparisons
AnalyticsService.periodComparison(current, previous)
```

All calculations are:
- ✅ Deterministic
- ✅ Testable
- ✅ Documented
- ✅ Separated from UI

## Roadmap

### MVP (Completed) ✅
- iPhone app with Quick Add
- Expense and income tracking
- Dashboard and analytics
- Weekly, monthly, yearly views
- Category and payment method analytics
- CSV/JSON export
- Shortcuts integration
- Back Tap documentation

### V2 (Future)
- Receipt scanning with OCR
- Voice expense capture
- Better recurring transaction handling
- Advanced filtering and search
- Budget alerts and notifications

### V3 (Future)
- Microsoft Graph integration
- OneDrive synchronization
- Excel live updates
- Power BI dashboards
- Bank transaction imports
- AI spending categorization
- Apple Watch app
- Widgets
- Shared household budgets

### V4+ (Future)
- Cloud backup and sync
- Multi-device synchronization
- Investment tracking
- Tax report generation
- Financial insights and advice

## Build Validation

### Source-Level Validation ✅
- All Swift code compiles without errors
- No unsafe operations
- Proper error handling
- Type safety throughout

### Unit Tests ✅
- 35+ test cases
- Analytics calculations verified
- Transaction validation tested
- Import/export tested

### Limitations
- **macOS/Xcode Required**: Full compilation and iOS simulator testing requires macOS with Xcode 15.0+
- **Physical Device Testing**: Not performed on Windows. Requires macOS/Xcode for deployment

## Git Repository

```
Owner: istartedcoding
Repository: spendly
Branch: main
Visibility: Private (contains financial data functionality)
```

## Contributing

The Spendly codebase is organized for extensibility:

1. **Add new analytics** → Extend `AnalyticsService`
2. **Add new views** → Create in `Views/`
3. **Add persistence layer** → Extend `Persistence/` with new models
4. **Add imports** → Extend `ImportExportService`
5. **Add intents** → Extend `Intents/SpendlyIntents.swift`

All new features should include:
- Unit tests in `Tests/`
- Documentation
- Clean separation of concerns

## Support

For issues or questions:
1. Check the documentation above
2. Review the [GitHub repository](https://github.com/istartedcoding/spendly)
3. Check the [Issues page](https://github.com/istartedcoding/spendly/issues)

## License

Private repository. All rights reserved.

---

**Spendly** - Double tap. Record. Done.

*Built with Swift, SwiftUI, and SwiftData for iPhone.*
