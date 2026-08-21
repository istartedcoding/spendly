import Foundation
import SwiftData

/// Service for managing transactions
@MainActor
class TransactionService {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Create
    
    /// Create a new expense transaction
    func createExpense(
        amount: Double,
        currency: String = "INR",
        category: String,
        paymentMethod: String,
        merchant: String? = nil,
        note: String? = nil,
        date: Date = Date()
    ) throws -> Transaction {
        let transaction = Transaction(
            type: .expense,
            amountInSmallestUnit: Decimal(amount * 100.0),
            currency: currency,
            category: category,
            paymentMethod: paymentMethod,
            merchant: merchant,
            note: note,
            date: date
        )
        
        modelContext.insert(transaction)
        try modelContext.save()
        return transaction
    }
    
    /// Create a new income transaction
    func createIncome(
        amount: Double,
        currency: String = "INR",
        category: String,
        paymentMethod: String,
        merchant: String? = nil,
        note: String? = nil,
        date: Date = Date()
    ) throws -> Transaction {
        let transaction = Transaction(
            type: .income,
            amountInSmallestUnit: Decimal(amount * 100.0),
            currency: currency,
            category: category,
            paymentMethod: paymentMethod,
            merchant: merchant,
            note: note,
            date: date
        )
        
        modelContext.insert(transaction)
        try modelContext.save()
        return transaction
    }
    
    // MARK: - Read
    
    /// Fetch all transactions
    func fetchAllTransactions() throws -> [Transaction] {
        let descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetch transactions by type
    func fetchTransactions(type: TransactionType) throws -> [Transaction] {
        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.type == type },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetch transactions by category
    func fetchTransactions(category: String) throws -> [Transaction] {
        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.category == category },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetch transactions by payment method
    func fetchTransactions(paymentMethod: String) throws -> [Transaction] {
        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.paymentMethod == paymentMethod },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetch transactions in date range
    func fetchTransactions(
        startDate: Date,
        endDate: Date
    ) throws -> [Transaction] {
        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { transaction in
                transaction.date >= startDate && transaction.date <= endDate
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetch transaction by ID
    func fetchTransaction(id: String) throws -> Transaction? {
        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    // MARK: - Update
    
    /// Update an existing transaction
    func updateTransaction(
        _ transaction: Transaction,
        amount: Double? = nil,
        category: String? = nil,
        paymentMethod: String? = nil,
        merchant: String? = nil,
        note: String? = nil,
        date: Date? = nil
    ) throws {
        if let amount = amount {
            transaction.amountInSmallestUnit = Decimal(amount * 100.0)
        }
        if let category = category {
            transaction.category = category
        }
        if let paymentMethod = paymentMethod {
            transaction.paymentMethod = paymentMethod
        }
        if let merchant = merchant {
            transaction.merchant = merchant
        }
        if let note = note {
            transaction.note = note
        }
        if let date = date {
            transaction.date = date
        }
        
        transaction.updatedAt = Date()
        try modelContext.save()
    }
    
    // MARK: - Delete
    
    /// Delete a transaction
    func deleteTransaction(_ transaction: Transaction) throws {
        modelContext.delete(transaction)
        try modelContext.save()
    }
    
    /// Delete multiple transactions
    func deleteTransactions(_ transactions: [Transaction]) throws {
        for transaction in transactions {
            modelContext.delete(transaction)
        }
        try modelContext.save()
    }
    
    // MARK: - Validation
    
    /// Validate transaction data
    func validateTransaction(
        amount: Double,
        category: String,
        paymentMethod: String
    ) -> [String] {
        var errors: [String] = []
        
        if amount <= 0 {
            errors.append("Amount must be greater than zero")
        }
        
        if category.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append("Category is required")
        }
        
        if paymentMethod.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append("Payment method is required")
        }
        
        return errors
    }
}
