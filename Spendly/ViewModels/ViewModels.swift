import Foundation
import SwiftData

/// ViewModel for QuickAdd screen
@MainActor
class QuickAddViewModel: NSObject, ObservableObject {
    @Published var amountText: String = ""
    @Published var selectedCategory: String = defaultExpenseCategories[0]
    @Published var selectedPaymentMethod: String = defaultPaymentMethods[0]
    @Published var merchant: String = ""
    @Published var note: String = ""
    @Published var transactionType: TransactionType = .expense
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isSaving: Bool = false
    @Published var showSuccess: Bool = false
    
    private let transactionService: TransactionService
    
    init(transactionService: TransactionService) {
        self.transactionService = transactionService
    }
    
    var categories: [String] {
        transactionType == .expense ? defaultExpenseCategories : defaultIncomeCategories
    }
    
    var parseAmount: Double {
        Double(amountText) ?? 0.0
    }
    
    func saveTransaction() async {
        isSaving = true
        
        let errors = transactionService.validateTransaction(
            amount: parseAmount,
            category: selectedCategory,
            paymentMethod: selectedPaymentMethod
        )
        
        guard errors.isEmpty else {
            errorMessage = errors.joined(separator: "\n")
            showError = true
            isSaving = false
            return
        }
        
        do {
            if transactionType == .expense {
                _ = try transactionService.createExpense(
                    amount: parseAmount,
                    category: selectedCategory,
                    paymentMethod: selectedPaymentMethod,
                    merchant: merchant.isEmpty ? nil : merchant,
                    note: note.isEmpty ? nil : note
                )
            } else {
                _ = try transactionService.createIncome(
                    amount: parseAmount,
                    category: selectedCategory,
                    paymentMethod: selectedPaymentMethod,
                    merchant: merchant.isEmpty ? nil : merchant,
                    note: note.isEmpty ? nil : note
                )
            }
            
            showSuccess = true
            resetForm()
            isSaving = false
        } catch {
            errorMessage = "Failed to save transaction: \(error.localizedDescription)"
            showError = true
            isSaving = false
        }
    }
    
    private func resetForm() {
        amountText = ""
        selectedCategory = transactionType == .expense ? defaultExpenseCategories[0] : defaultIncomeCategories[0]
        selectedPaymentMethod = defaultPaymentMethods[0]
        merchant = ""
        note = ""
    }
}

/// ViewModel for Dashboard
@MainActor
class DashboardViewModel: NSObject, ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var totalIncome: Double = 0
    @Published var totalExpenses: Double = 0
    @Published var netSavings: Double = 0
    @Published var savingsRate: Double = 0
    @Published var currentMonthIncome: Double = 0
    @Published var currentMonthExpenses: Double = 0
    @Published var currentMonthSavings: Double = 0
    @Published var topCategories: [(String, Double)] = []
    @Published var paymentMethodsDistribution: [(String, Double)] = []
    @Published var recentTransactions: [Transaction] = []
    @Published var isLoading: Bool = false
    
    private let transactionService: TransactionService
    
    init(transactionService: TransactionService) {
        self.transactionService = transactionService
    }
    
    func loadData() async {
        isLoading = true
        
        do {
            transactions = try transactionService.fetchAllTransactions()
            
            // Overall totals
            let totalIncome = AnalyticsService.totalIncome(from: transactions)
            let totalExpenses = AnalyticsService.totalExpenses(from: transactions)
            
            self.totalIncome = Double(truncating: totalIncome as NSDecimalNumber) / 100.0
            self.totalExpenses = Double(truncating: totalExpenses as NSDecimalNumber) / 100.0
            self.netSavings = self.totalIncome - self.totalExpenses
            self.savingsRate = AnalyticsService.savingsRate(from: transactions)
            
            // Current month
            let now = Date()
            let monthTransactions = AnalyticsService.transactionsForMonth(now, from: transactions)
            let monthlyIncome = AnalyticsService.monthlyIncome(for: now, from: transactions)
            let monthlyExpenses = AnalyticsService.monthlyExpenses(for: now, from: transactions)
            
            self.currentMonthIncome = Double(truncating: monthlyIncome as NSDecimalNumber) / 100.0
            self.currentMonthExpenses = Double(truncating: monthlyExpenses as NSDecimalNumber) / 100.0
            self.currentMonthSavings = currentMonthIncome - currentMonthExpenses
            
            // Top categories
            let topCats = AnalyticsService.topSpendingCategories(from: transactions, limit: 5)
            self.topCategories = topCats.map { (category: $0.category, amount: Double(truncating: $0.amount as NSDecimalNumber) / 100.0) }
            
            // Payment methods
            let topMethods = AnalyticsService.topPaymentMethods(from: transactions, limit: 5)
            self.paymentMethodsDistribution = topMethods.map { (method: $0.method, amount: Double(truncating: $0.amount as NSDecimalNumber) / 100.0) }
            
            // Recent transactions
            self.recentTransactions = Array(transactions.prefix(10))
            
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}

/// ViewModel for Transaction History
@MainActor
class TransactionHistoryViewModel: NSObject, ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var filteredTransactions: [Transaction] = []
    @Published var selectedCategory: String?
    @Published var selectedPaymentMethod: String?
    @Published var selectedType: TransactionType?
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    
    private let transactionService: TransactionService
    
    init(transactionService: TransactionService) {
        self.transactionService = transactionService
    }
    
    func loadTransactions() async {
        isLoading = true
        
        do {
            transactions = try transactionService.fetchAllTransactions()
            applyFilters()
            isLoading = false
        } catch {
            isLoading = false
        }
    }
    
    func applyFilters() {
        filteredTransactions = transactions.filter { transaction in
            var matches = true
            
            if let category = selectedCategory, transaction.category != category {
                matches = false
            }
            
            if let method = selectedPaymentMethod, transaction.paymentMethod != method {
                matches = false
            }
            
            if let type = selectedType, transaction.type != type {
                matches = false
            }
            
            if !searchText.isEmpty {
                let searchLower = searchText.lowercased()
                let matchesMerchant = transaction.merchant?.lowercased().contains(searchLower) ?? false
                let matchesNote = transaction.note?.lowercased().contains(searchLower) ?? false
                let matchesAmount = String(format: "%.2f", transaction.amount).contains(searchText)
                
                matches = matches && (matchesMerchant || matchesNote || matchesAmount)
            }
            
            return matches
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) async {
        do {
            try transactionService.deleteTransaction(transaction)
            await loadTransactions()
        } catch {}
    }
    
    func updateTransaction(
        _ transaction: Transaction,
        amount: Double? = nil,
        category: String? = nil,
        paymentMethod: String? = nil,
        merchant: String? = nil,
        note: String? = nil
    ) async {
        do {
            try transactionService.updateTransaction(
                transaction,
                amount: amount,
                category: category,
                paymentMethod: paymentMethod,
                merchant: merchant,
                note: note
            )
            await loadTransactions()
        } catch {}
    }
}

/// ViewModel for Analytics
@MainActor
class AnalyticsViewModel: NSObject, ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var selectedPeriod: AnalyticsPeriod = .month
    @Published var selectedDate: Date = Date()
    
    // Weekly
    @Published var weeklyIncome: Double = 0
    @Published var weeklyExpenses: Double = 0
    @Published var weeklySavings: Double = 0
    @Published var weeklyAverageDailySpending: Double = 0
    
    // Monthly
    @Published var monthlyIncome: Double = 0
    @Published var monthlyExpenses: Double = 0
    @Published var monthlySavings: Double = 0
    @Published var monthlySavingsRate: Double = 0
    
    // Yearly
    @Published var yearlyIncome: Double = 0
    @Published var yearlyExpenses: Double = 0
    @Published var yearlySavings: Double = 0
    @Published var monthlyBreakdown: [(month: Int, income: Double, expenses: Double)] = []
    
    @Published var isLoading: Bool = false
    
    private let transactionService: TransactionService
    
    init(transactionService: TransactionService) {
        self.transactionService = transactionService
    }
    
    func loadData() async {
        isLoading = true
        
        do {
            transactions = try transactionService.fetchAllTransactions()
            updateAnalytics()
            isLoading = false
        } catch {
            isLoading = false
        }
    }
    
    private func updateAnalytics() {
        switch selectedPeriod {
        case .week:
            let income = AnalyticsService.weeklyIncome(for: selectedDate, from: transactions)
            let expenses = AnalyticsService.weeklyExpenses(for: selectedDate, from: transactions)
            
            weeklyIncome = Double(truncating: income as NSDecimalNumber) / 100.0
            weeklyExpenses = Double(truncating: expenses as NSDecimalNumber) / 100.0
            weeklySavings = weeklyIncome - weeklyExpenses
            
            let avgDaily = AnalyticsService.weeklyAverageDailySpending(for: selectedDate, from: transactions)
            weeklyAverageDailySpending = Double(truncating: avgDaily as NSDecimalNumber) / 100.0
            
        case .month:
            let income = AnalyticsService.monthlyIncome(for: selectedDate, from: transactions)
            let expenses = AnalyticsService.monthlyExpenses(for: selectedDate, from: transactions)
            
            monthlyIncome = Double(truncating: income as NSDecimalNumber) / 100.0
            monthlyExpenses = Double(truncating: expenses as NSDecimalNumber) / 100.0
            monthlySavings = monthlyIncome - monthlyExpenses
            monthlySavingsRate = AnalyticsService.monthlySavingsRate(for: selectedDate, from: transactions)
            
        case .year:
            let income = AnalyticsService.yearlyIncome(for: selectedDate, from: transactions)
            let expenses = AnalyticsService.yearlyExpenses(for: selectedDate, from: transactions)
            
            yearlyIncome = Double(truncating: income as NSDecimalNumber) / 100.0
            yearlyExpenses = Double(truncating: expenses as NSDecimalNumber) / 100.0
            yearlySavings = yearlyIncome - yearlyExpenses
            
            let year = Calendar.current.component(.year, from: selectedDate)
            let breakdown = AnalyticsService.monthlyBreakdown(for: year, from: transactions)
            
            monthlyBreakdown = breakdown.map { month, data in
                (month: month, income: Double(truncating: data.income as NSDecimalNumber) / 100.0, expenses: Double(truncating: data.expenses as NSDecimalNumber) / 100.0)
            }
        }
    }
}

enum AnalyticsPeriod {
    case week
    case month
    case year
}
