import Foundation
import Testing

/// Comprehensive unit tests for analytics calculations
@Suite("Analytics Service Tests")
struct AnalyticsServiceTests {
    
    // MARK: - Test Data
    
    let testTransactions: [Transaction] = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var transactions: [Transaction] = []
        
        // Create test data matching the specified amounts
        // Income: ₹150,000
        transactions.append(Transaction(
            type: .income,
            amountInSmallestUnit: 15000000, // ₹150,000
            category: "Salary",
            paymentMethod: "Bank Transfer",
            date: formatter.date(from: "2024-08-15") ?? Date()
        ))
        
        // Expenses totaling ₹60,000
        // Food: ₹10,000
        transactions.append(Transaction(
            type: .expense,
            amountInSmallestUnit: 1000000,
            category: "Food",
            paymentMethod: "UPI",
            date: formatter.date(from: "2024-08-01") ?? Date()
        ))
        
        // Shopping: ₹15,000
        transactions.append(Transaction(
            type: .expense,
            amountInSmallestUnit: 1500000,
            category: "Shopping",
            paymentMethod: "Credit Card",
            date: formatter.date(from: "2024-08-05") ?? Date()
        ))
        
        // Travel: ₹20,000
        transactions.append(Transaction(
            type: .expense,
            amountInSmallestUnit: 2000000,
            category: "Travel",
            paymentMethod: "Debit Card",
            date: formatter.date(from: "2024-08-10") ?? Date()
        ))
        
        // Bills: ₹8,000
        transactions.append(Transaction(
            type: .expense,
            amountInSmallestUnit: 800000,
            category: "Bills",
            paymentMethod: "Bank Transfer",
            date: formatter.date(from: "2024-08-12") ?? Date()
        ))
        
        // Other: ₹7,000
        transactions.append(Transaction(
            type: .expense,
            amountInSmallestUnit: 700000,
            category: "Other",
            paymentMethod: "Cash",
            date: formatter.date(from: "2024-08-20") ?? Date()
        ))
        
        return transactions
    }()
    
    // MARK: - Total Calculations Tests
    
    @Test("Calculate total income correctly")
    func testTotalIncome() {
        let income = AnalyticsService.totalIncome(from: testTransactions)
        #expect(income == 15000000) // ₹150,000
    }
    
    @Test("Calculate total expenses correctly")
    func testTotalExpenses() {
        let expenses = AnalyticsService.totalExpenses(from: testTransactions)
        #expect(expenses == 6000000) // ₹60,000
    }
    
    @Test("Calculate net savings correctly")
    func testNetSavings() {
        let savings = AnalyticsService.netSavings(from: testTransactions)
        #expect(savings == 9000000) // ₹90,000 (150,000 - 60,000)
    }
    
    @Test("Calculate savings rate correctly")
    func testSavingsRate() {
        let rate = AnalyticsService.savingsRate(from: testTransactions)
        #expect(rate == 60.0) // 90,000 / 150,000 * 100 = 60%
    }
    
    // MARK: - Category Totals Tests
    
    @Test("Calculate category totals correctly")
    func testCategoryTotals() {
        let totals = AnalyticsService.categoryTotals(from: testTransactions)
        
        #expect(totals["Food"] == 1000000) // ₹10,000
        #expect(totals["Shopping"] == 1500000) // ₹15,000
        #expect(totals["Travel"] == 2000000) // ₹20,000
        #expect(totals["Bills"] == 800000) // ₹8,000
        #expect(totals["Other"] == 700000) // ₹7,000
        #expect(totals["Salary"] == -15000000) // Income as negative
    }
    
    @Test("Calculate expense category totals correctly")
    func testExpenseCategoryTotals() {
        let totals = AnalyticsService.expenseCategoryTotals(from: testTransactions)
        
        #expect(totals["Food"] == 1000000)
        #expect(totals["Shopping"] == 1500000)
        #expect(totals["Travel"] == 2000000)
        #expect(totals["Bills"] == 800000)
        #expect(totals["Other"] == 700000)
        #expect(totals["Salary"] == nil) // Income excluded
    }
    
    @Test("Calculate income category totals correctly")
    func testIncomeCategoryTotals() {
        let totals = AnalyticsService.incomeCategoryTotals(from: testTransactions)
        
        #expect(totals["Salary"] == 15000000)
        #expect(totals["Food"] == nil) // Expenses excluded
    }
    
    // MARK: - Payment Method Tests
    
    @Test("Calculate payment method totals correctly")
    func testPaymentMethodTotals() {
        let totals = AnalyticsService.paymentMethodTotals(from: testTransactions)
        
        #expect(totals["UPI"] == 1000000) // Food
        #expect(totals["Credit Card"] == 1500000) // Shopping
        #expect(totals["Debit Card"] == 2000000) // Travel
        #expect(totals["Bank Transfer"] == 800000) // Bills only (income excluded)
        #expect(totals["Cash"] == 700000) // Other
    }
    
    // MARK: - Merchant Tests
    
    @Test("Calculate merchant totals correctly")
    func testMerchantTotals() {
        var transactionsWithMerchants = testTransactions
        transactionsWithMerchants[1].merchant = "Starbucks"
        transactionsWithMerchants[2].merchant = "Amazon"
        transactionsWithMerchants[3].merchant = "Uber"
        
        let totals = AnalyticsService.merchantTotals(from: transactionsWithMerchants)
        
        #expect(totals["Starbucks"] == 1000000)
        #expect(totals["Amazon"] == 1500000)
        #expect(totals["Uber"] == 2000000)
    }
    
    // MARK: - Top Spenders Tests
    
    @Test("Identify top spending categories")
    func testTopSpendingCategories() {
        let top = AnalyticsService.topSpendingCategories(from: testTransactions, limit: 3)
        
        #expect(top.count == 3)
        #expect(top[0].category == "Travel")
        #expect(top[1].category == "Shopping")
        #expect(top[2].category == "Food")
    }
    
    @Test("Identify top payment methods")
    func testTopPaymentMethods() {
        let top = AnalyticsService.topPaymentMethods(from: testTransactions, limit: 2)
        
        #expect(top.count == 2)
        #expect(top[0].method == "Debit Card")
        #expect(top[1].method == "Credit Card")
    }
    
    // MARK: - Statistics Tests
    
    @Test("Find largest transaction")
    func testLargestTransaction() {
        let largest = AnalyticsService.largestTransaction(from: testTransactions)
        
        #expect(largest?.amountInSmallestUnit == 15000000)
        #expect(largest?.category == "Salary")
    }
    
    @Test("Find most frequent category")
    func testMostFrequentCategory() {
        var transactions = testTransactions
        transactions.append(Transaction(
            type: .expense,
            amountInSmallestUnit: 500000,
            category: "Food",
            paymentMethod: "Cash"
        ))
        transactions.append(Transaction(
            type: .expense,
            amountInSmallestUnit: 300000,
            category: "Food",
            paymentMethod: "UPI"
        ))
        
        let mostFrequent = AnalyticsService.mostFrequentCategory(from: transactions)
        #expect(mostFrequent == "Food")
    }
    
    // MARK: - Edge Cases
    
    @Test("Handle empty transaction list")
    func testEmptyTransactionList() {
        let empty: [Transaction] = []
        
        #expect(AnalyticsService.totalIncome(from: empty) == 0)
        #expect(AnalyticsService.totalExpenses(from: empty) == 0)
        #expect(AnalyticsService.netSavings(from: empty) == 0)
        #expect(AnalyticsService.savingsRate(from: empty) == 0)
    }
    
    @Test("Handle savings rate with zero income")
    func testSavingsRateWithZeroIncome() {
        let expenseOnly = testTransactions.filter { $0.type == .expense }
        let rate = AnalyticsService.savingsRate(from: expenseOnly)
        
        #expect(rate == 0)
    }
}

/// Tests for Transaction Service
@Suite("Transaction Service Tests")
struct TransactionServiceTests {
    
    @Test("Validate correct transaction data")
    func testValidateCorrectData() {
        let service = TransactionService(modelContext: MockModelContext())
        let errors = service.validateTransaction(
            amount: 100.0,
            category: "Food",
            paymentMethod: "UPI"
        )
        
        #expect(errors.isEmpty)
    }
    
    @Test("Reject negative amount")
    func testRejectNegativeAmount() {
        let service = TransactionService(modelContext: MockModelContext())
        let errors = service.validateTransaction(
            amount: -50.0,
            category: "Food",
            paymentMethod: "UPI"
        )
        
        #expect(errors.contains { $0.contains("greater than zero") })
    }
    
    @Test("Reject zero amount")
    func testRejectZeroAmount() {
        let service = TransactionService(modelContext: MockModelContext())
        let errors = service.validateTransaction(
            amount: 0,
            category: "Food",
            paymentMethod: "UPI"
        )
        
        #expect(!errors.isEmpty)
    }
    
    @Test("Require category")
    func testRequireCategory() {
        let service = TransactionService(modelContext: MockModelContext())
        let errors = service.validateTransaction(
            amount: 100.0,
            category: "",
            paymentMethod: "UPI"
        )
        
        #expect(errors.contains { $0.contains("Category") })
    }
    
    @Test("Require payment method")
    func testRequirePaymentMethod() {
        let service = TransactionService(modelContext: MockModelContext())
        let errors = service.validateTransaction(
            amount: 100.0,
            category: "Food",
            paymentMethod: ""
        )
        
        #expect(errors.contains { $0.contains("Payment method") })
    }
}

/// Tests for Import/Export Service
@Suite("Import/Export Service Tests")
struct ImportExportServiceTests {
    
    let testTransactions: [Transaction] = {
        [
            Transaction(
                type: .expense,
                amountInSmallestUnit: 50000, // ₹500
                category: "Food",
                paymentMethod: "UPI",
                merchant: "Restaurant",
                note: "Lunch"
            ),
            Transaction(
                type: .income,
                amountInSmallestUnit: 100000, // ₹1000
                category: "Freelance",
                paymentMethod: "Bank Transfer"
            )
        ]
    }()
    
    @Test("Export to CSV format")
    func testExportToCSV() {
        let csv = ImportExportService.exportToCSV(testTransactions)
        
        #expect(csv.contains("Date"))
        #expect(csv.contains("Amount"))
        #expect(csv.contains("expense"))
        #expect(csv.contains("income"))
        #expect(csv.contains("Food"))
        #expect(csv.contains("Freelance"))
    }
    
    @Test("Export to JSON format")
    func testExportToJSON() {
        let jsonData = ImportExportService.exportToJSON(testTransactions)
        
        #expect(jsonData != nil)
        
        if let data = jsonData {
            let json = try! JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            #expect(json?.count == 2)
        }
    }
    
    @Test("Import from valid CSV")
    func testImportFromValidCSV() {
        let csv = """
Date,Time,Type,Amount,Currency,Category,Payment Method,Merchant,Note
2024-08-15,10:30:00,expense,500.00,INR,Food,UPI,Restaurant,Lunch
2024-08-16,14:15:00,income,1000.00,INR,Freelance,Bank Transfer,,
"""
        
        let (transactions, errors) = ImportExportService.importFromCSV(csv)
        
        #expect(transactions.count == 2)
        #expect(errors.isEmpty)
        #expect(transactions[0].category == "Food")
        #expect(transactions[1].type == .income)
    }
    
    @Test("Detect invalid CSV format")
    func testDetectInvalidCSV() {
        let csv = "Date,Type\n2024-08-15"
        
        let (transactions, errors) = ImportExportService.importFromCSV(csv)
        
        #expect(!errors.isEmpty)
        #expect(errors[0].contains("Invalid format"))
    }
    
    @Test("Detect duplicate transactions")
    func testDetectDuplicates() {
        let transaction1 = Transaction(
            type: .expense,
            amountInSmallestUnit: 50000,
            category: "Food",
            paymentMethod: "UPI",
            date: Date()
        )
        
        let transaction2 = Transaction(
            type: .expense,
            amountInSmallestUnit: 50000,
            category: "Food",
            paymentMethod: "UPI",
            date: Date()
        )
        
        let duplicates = ImportExportService.detectDuplicates([transaction2], against: [transaction1])
        
        #expect(duplicates.count == 1)
    }
}

/// Mock ModelContext for testing
class MockModelContext: ModelContext {
    init() {
        // Initialize with a temporary model container
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Transaction.self, configurations: config)
        super.init(container)
    }
}
