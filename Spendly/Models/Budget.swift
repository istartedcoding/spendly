import Foundation
import SwiftData

/// Represents a monthly budget
@Model
final class Budget {
    /// Unique identifier
    @Attribute(.unique) var id: String
    
    /// Budget type: overall or category-specific
    var type: BudgetType
    
    /// Category name if type is categoryBudget
    var category: String?
    
    /// Budget amount in smallest currency unit
    var amountInSmallestUnit: Decimal
    
    /// Currency code
    var currency: String
    
    /// Year of the budget
    var year: Int
    
    /// Month of the budget (1-12)
    var month: Int
    
    /// Creation timestamp
    var createdAt: Date
    
    /// Last update timestamp
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        type: BudgetType,
        category: String? = nil,
        amountInSmallestUnit: Decimal,
        currency: String = "INR",
        year: Int,
        month: Int,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.category = category
        self.amountInSmallestUnit = amountInSmallestUnit
        self.currency = currency
        self.year = year
        self.month = month
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Convenience getter for amount as Double
    var amount: Double {
        Double(truncating: amountInSmallestUnit as NSDecimalNumber) / 100.0
    }
}

enum BudgetType: String, Codable {
    case overall = "overall"
    case categoryBudget = "category"
}

/// Represents a recurring transaction
@Model
final class RecurringTransaction {
    /// Unique identifier
    @Attribute(.unique) var id: String
    
    /// Type of transaction
    var type: TransactionType
    
    /// Amount in smallest currency unit
    var amountInSmallestUnit: Decimal
    
    /// Currency code
    var currency: String
    
    /// Category
    var category: String
    
    /// Payment method
    var paymentMethod: String
    
    /// Optional merchant
    var merchant: String?
    
    /// Optional note
    var note: String?
    
    /// Recurrence frequency
    var frequency: RecurrenceFrequency
    
    /// When the recurring transaction starts
    var startDate: Date
    
    /// When the recurring transaction ends (if applicable)
    var endDate: Date?
    
    /// Whether this recurring transaction is active
    var isActive: Bool
    
    /// Date of next occurrence
    var nextOccurrence: Date
    
    /// Creation timestamp
    var createdAt: Date
    
    /// Last update timestamp
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        type: TransactionType,
        amountInSmallestUnit: Decimal,
        currency: String = "INR",
        category: String,
        paymentMethod: String,
        merchant: String? = nil,
        note: String? = nil,
        frequency: RecurrenceFrequency,
        startDate: Date = Date(),
        endDate: Date? = nil,
        isActive: Bool = true,
        nextOccurrence: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.amountInSmallestUnit = amountInSmallestUnit
        self.currency = currency
        self.category = category
        self.paymentMethod = paymentMethod
        self.merchant = merchant
        self.note = note
        self.frequency = frequency
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.nextOccurrence = nextOccurrence ?? Self.calculateNextOccurrence(startDate: startDate, frequency: frequency)
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Calculate next occurrence based on frequency
    static func calculateNextOccurrence(startDate: Date, frequency: RecurrenceFrequency) -> Date {
        let calendar = Calendar.current
        let nextDate: Date
        
        switch frequency {
        case .daily:
            nextDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
        case .weekly:
            nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: startDate) ?? startDate
        case .monthly:
            nextDate = calendar.date(byAdding: .month, value: 1, to: startDate) ?? startDate
        case .yearly:
            nextDate = calendar.date(byAdding: .year, value: 1, to: startDate) ?? startDate
        }
        
        return nextDate
    }
    
    /// Convenience getter for amount as Double
    var amount: Double {
        Double(truncating: amountInSmallestUnit as NSDecimalNumber) / 100.0
    }
}

enum RecurrenceFrequency: String, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }
}

/// Represents application settings
@Model
final class AppSettings {
    @Attribute(.unique) var id: String = "app_settings"
    
    /// Default currency for the user
    var defaultCurrency: String = "INR"
    
    /// Whether to show balance in dashboard
    var showBalance: Bool = true
    
    /// Last sync timestamp
    var lastSyncAt: Date?
    
    /// App version
    var appVersion: String = "1.0.0"
    
    /// Creation timestamp
    var createdAt: Date = Date()
    
    /// Last update timestamp
    var updatedAt: Date = Date()
    
    init() {}
}
