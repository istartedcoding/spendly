import Foundation
import SwiftData

/// Represents a single financial transaction (income or expense)
@Model
final class Transaction {
    /// Unique identifier for the transaction
    @Attribute(.unique) var id: String
    
    /// Type of transaction: expense or income
    var type: TransactionType
    
    /// Amount in the smallest currency unit (e.g., paise for INR)
    /// Using Decimal to avoid floating-point precision issues
    var amountInSmallestUnit: Decimal
    
    /// Currency code (e.g., "INR", "USD")
    var currency: String
    
    /// Transaction category
    var category: String
    
    /// Payment method used
    var paymentMethod: String
    
    /// Optional merchant name
    var merchant: String?
    
    /// Optional transaction note
    var note: String?
    
    /// Date of the transaction
    var date: Date
    
    /// Creation timestamp
    var createdAt: Date
    
    /// Last update timestamp
    var updatedAt: Date
    
    /// Optional reference to parent recurring transaction
    var recurringTransactionId: String?
    
    /// Optional external import source (e.g., "bank_import", "csv")
    var importSource: String?
    
    /// Optional external reference (e.g., bank transaction ID)
    var externalReference: String?
    
    init(
        id: String = UUID().uuidString,
        type: TransactionType,
        amountInSmallestUnit: Decimal,
        currency: String = "INR",
        category: String,
        paymentMethod: String,
        merchant: String? = nil,
        note: String? = nil,
        date: Date = Date(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        recurringTransactionId: String? = nil,
        importSource: String? = nil,
        externalReference: String? = nil
    ) {
        self.id = id
        self.type = type
        self.amountInSmallestUnit = amountInSmallestUnit
        self.currency = currency
        self.category = category
        self.paymentMethod = paymentMethod
        self.merchant = merchant
        self.note = note
        self.date = date
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.recurringTransactionId = recurringTransactionId
        self.importSource = importSource
        self.externalReference = externalReference
    }
    
    /// Convenience getter for amount as Double (for display)
    var amount: Double {
        Double(truncating: amountInSmallestUnit as NSDecimalNumber) / 100.0
    }
    
    /// Convenience setter for amount as Double
    func setAmount(_ amount: Double) {
        amountInSmallestUnit = Decimal(amount * 100.0)
    }
}

/// Represents transaction type
enum TransactionType: String, Codable {
    case expense = "expense"
    case income = "income"
}

/// Supported currency codes
enum Currency: String, CaseIterable {
    case inr = "INR"
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case aed = "AED"
    case sgd = "SGD"
    
    var symbol: String {
        switch self {
        case .inr:
            return "₹"
        case .usd:
            return "$"
        case .eur:
            return "€"
        case .gbp:
            return "£"
        case .aed:
            return "د.إ"
        case .sgd:
            return "S$"
        }
    }
    
    var displayName: String {
        switch self {
        case .inr:
            return "Indian Rupee (₹)"
        case .usd:
            return "US Dollar ($)"
        case .eur:
            return "Euro (€)"
        case .gbp:
            return "British Pound (£)"
        case .aed:
            return "UAE Dirham (د.إ)"
        case .sgd:
            return "Singapore Dollar (S$)"
        }
    }
}

/// Represents expense categories
let defaultExpenseCategories = [
    "Food",
    "Groceries",
    "Transport",
    "Fuel",
    "Shopping",
    "Bills",
    "Home",
    "Entertainment",
    "Travel",
    "Health",
    "Fitness",
    "Subscriptions",
    "Education",
    "Personal",
    "Gifts",
    "Other"
]

/// Represents income categories
let defaultIncomeCategories = [
    "Salary",
    "Freelance",
    "Business",
    "Investment",
    "Bonus",
    "Refund",
    "Other"
]

/// Represents payment method types
let defaultPaymentMethods = [
    "Cash",
    "UPI",
    "Credit Card",
    "Debit Card",
    "Bank Transfer",
    "Other"
]
