import Foundation

/// Core analytics engine for financial calculations
struct AnalyticsService {
    
    // MARK: - Total Calculations
    
    /// Calculate total income for transactions
    static func totalIncome(from transactions: [Transaction]) -> Decimal {
        transactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amountInSmallestUnit }
    }
    
    /// Calculate total expenses for transactions
    static func totalExpenses(from transactions: [Transaction]) -> Decimal {
        transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amountInSmallestUnit }
    }
    
    /// Calculate net savings (income - expenses)
    static func netSavings(from transactions: [Transaction]) -> Decimal {
        totalIncome(from: transactions) - totalExpenses(from: transactions)
    }
    
    /// Calculate savings rate (savings / income * 100)
    static func savingsRate(from transactions: [Transaction]) -> Double {
        let income = totalIncome(from: transactions)
        guard income > 0 else { return 0 }
        let savings = netSavings(from: transactions)
        return Double(truncating: (savings / income * 100) as NSDecimalNumber)
    }
    
    // MARK: - Category Totals
    
    /// Get spending totals grouped by category
    static func categoryTotals(from transactions: [Transaction]) -> [String: Decimal] {
        var totals: [String: Decimal] = [:]
        
        for transaction in transactions {
            let amount = transaction.type == .expense ? transaction.amountInSmallestUnit : -transaction.amountInSmallestUnit
            totals[transaction.category, default: 0] += amount
        }
        
        return totals
    }
    
    /// Get spending by expense category only
    static func expenseCategoryTotals(from transactions: [Transaction]) -> [String: Decimal] {
        transactions
            .filter { $0.type == .expense }
            .reduce(into: [String: Decimal]()) { totals, transaction in
                totals[transaction.category, default: 0] += transaction.amountInSmallestUnit
            }
    }
    
    /// Get income by category
    static func incomeCategoryTotals(from transactions: [Transaction]) -> [String: Decimal] {
        transactions
            .filter { $0.type == .income }
            .reduce(into: [String: Decimal]()) { totals, transaction in
                totals[transaction.category, default: 0] += transaction.amountInSmallestUnit
            }
    }
    
    // MARK: - Payment Method Totals
    
    /// Get spending totals grouped by payment method
    static func paymentMethodTotals(from transactions: [Transaction]) -> [String: Decimal] {
        transactions
            .filter { $0.type == .expense }
            .reduce(into: [String: Decimal]()) { totals, transaction in
                totals[transaction.paymentMethod, default: 0] += transaction.amountInSmallestUnit
            }
    }
    
    /// Get totals for a specific payment method
    static func totalByPaymentMethod(
        _ method: String,
        from transactions: [Transaction]
    ) -> Decimal {
        transactions
            .filter { $0.paymentMethod == method }
            .reduce(0) { $0 + $1.amountInSmallestUnit }
    }
    
    // MARK: - Merchant Analysis
    
    /// Get spending totals grouped by merchant
    static func merchantTotals(from transactions: [Transaction]) -> [String: Decimal] {
        transactions
            .filter { $0.type == .expense && $0.merchant != nil }
            .reduce(into: [String: Decimal]()) { totals, transaction in
                if let merchant = transaction.merchant {
                    totals[merchant, default: 0] += transaction.amountInSmallestUnit
                }
            }
    }
    
    // MARK: - Time-Based Calculations
    
    /// Filter transactions for a specific date
    static func transactionsForDate(
        _ date: Date,
        from transactions: [Transaction]
    ) -> [Transaction] {
        let calendar = Calendar.current
        return transactions.filter { transaction in
            calendar.isDate(transaction.date, inSameDayAs: date)
        }
    }
    
    /// Filter transactions for a specific week
    static func transactionsForWeek(
        _ date: Date,
        from transactions: [Transaction]
    ) -> [Transaction] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return []
        }
        
        return transactions.filter { transaction in
            weekInterval.contains(transaction.date)
        }
    }
    
    /// Filter transactions for a specific month
    static func transactionsForMonth(
        _ date: Date,
        from transactions: [Transaction]
    ) -> [Transaction] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
            return []
        }
        
        return transactions.filter { transaction in
            monthInterval.contains(transaction.date)
        }
    }
    
    /// Filter transactions for a specific year
    static func transactionsForYear(
        _ date: Date,
        from transactions: [Transaction]
    ) -> [Transaction] {
        let calendar = Calendar.current
        guard let yearInterval = calendar.dateInterval(of: .year, for: date) else {
            return []
        }
        
        return transactions.filter { transaction in
            yearInterval.contains(transaction.date)
        }
    }
    
    /// Get daily totals for a date range
    static func dailyTotals(
        for transactions: [Transaction],
        in dateRange: (start: Date, end: Date)
    ) -> [(date: Date, income: Decimal, expenses: Decimal)] {
        let calendar = Calendar.current
        var dailyData: [Date: (income: Decimal, expenses: Decimal)] = [:]
        
        var currentDate = calendar.startOfDay(for: dateRange.start)
        while currentDate <= dateRange.end {
            let dayTransactions = transactionsForDate(currentDate, from: transactions)
            
            let income = totalIncome(from: dayTransactions)
            let expenses = totalExpenses(from: dayTransactions)
            
            if income > 0 || expenses > 0 {
                dailyData[currentDate] = (income, expenses)
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return dailyData
            .sorted { $0.key < $1.key }
            .map { ($0.key, $0.value.income, $0.value.expenses) }
    }
    
    // MARK: - Weekly Analytics
    
    /// Get weekly income
    static func weeklyIncome(for date: Date, from transactions: [Transaction]) -> Decimal {
        let weekTransactions = transactionsForWeek(date, from: transactions)
        return totalIncome(from: weekTransactions)
    }
    
    /// Get weekly expenses
    static func weeklyExpenses(for date: Date, from transactions: [Transaction]) -> Decimal {
        let weekTransactions = transactionsForWeek(date, from: transactions)
        return totalExpenses(from: weekTransactions)
    }
    
    /// Get weekly savings
    static func weeklySavings(for date: Date, from transactions: [Transaction]) -> Decimal {
        weeklyIncome(for: date, from: transactions) - weeklyExpenses(for: date, from: transactions)
    }
    
    /// Get average daily spending for a week
    static func weeklyAverageDailySpending(for date: Date, from transactions: [Transaction]) -> Decimal {
        let weekExpenses = weeklyExpenses(for: date, from: transactions)
        return weekExpenses / 7
    }
    
    // MARK: - Monthly Analytics
    
    /// Get monthly income
    static func monthlyIncome(for date: Date, from transactions: [Transaction]) -> Decimal {
        let monthTransactions = transactionsForMonth(date, from: transactions)
        return totalIncome(from: monthTransactions)
    }
    
    /// Get monthly expenses
    static func monthlyExpenses(for date: Date, from transactions: [Transaction]) -> Decimal {
        let monthTransactions = transactionsForMonth(date, from: transactions)
        return totalExpenses(from: monthTransactions)
    }
    
    /// Get monthly savings
    static func monthlySavings(for date: Date, from transactions: [Transaction]) -> Decimal {
        monthlyIncome(for: date, from: transactions) - monthlyExpenses(for: date, from: transactions)
    }
    
    /// Get monthly savings rate
    static func monthlySavingsRate(for date: Date, from transactions: [Transaction]) -> Double {
        let income = monthlyIncome(for: date, from: transactions)
        guard income > 0 else { return 0 }
        let savings = monthlySavings(for: date, from: transactions)
        return Double(truncating: (savings / income * 100) as NSDecimalNumber)
    }
    
    // MARK: - Yearly Analytics
    
    /// Get yearly income
    static func yearlyIncome(for date: Date, from transactions: [Transaction]) -> Decimal {
        let yearTransactions = transactionsForYear(date, from: transactions)
        return totalIncome(from: yearTransactions)
    }
    
    /// Get yearly expenses
    static func yearlyExpenses(for date: Date, from transactions: [Transaction]) -> Decimal {
        let yearTransactions = transactionsForYear(date, from: transactions)
        return totalExpenses(from: yearTransactions)
    }
    
    /// Get yearly savings
    static func yearlySavings(for date: Date, from transactions: [Transaction]) -> Decimal {
        yearlyIncome(for: date, from: transactions) - yearlyExpenses(for: date, from: transactions)
    }
    
    /// Get monthly breakdown for a year
    static func monthlyBreakdown(
        for year: Int,
        from transactions: [Transaction]
    ) -> [Int: (income: Decimal, expenses: Decimal, savings: Decimal)] {
        var breakdown: [Int: (income: Decimal, expenses: Decimal, savings: Decimal)] = [:]
        
        for month in 1...12 {
            let dateComponents = DateComponents(year: year, month: month, day: 1)
            guard let date = Calendar.current.date(from: dateComponents) else { continue }
            
            let income = monthlyIncome(for: date, from: transactions)
            let expenses = monthlyExpenses(for: date, from: transactions)
            let savings = income - expenses
            
            breakdown[month] = (income, expenses, savings)
        }
        
        return breakdown
    }
    
    // MARK: - Budget Analysis
    
    /// Calculate budget utilization
    static func budgetUtilization(
        budgetAmount: Decimal,
        spentAmount: Decimal
    ) -> Double {
        guard budgetAmount > 0 else { return 0 }
        return Double(truncating: (spentAmount / budgetAmount * 100) as NSDecimalNumber)
    }
    
    /// Check if spending exceeds budget
    static func isBudgetExceeded(
        budgetAmount: Decimal,
        spentAmount: Decimal
    ) -> Bool {
        spentAmount > budgetAmount
    }
    
    /// Calculate remaining budget
    static func budgetRemaining(
        budgetAmount: Decimal,
        spentAmount: Decimal
    ) -> Decimal {
        max(0, budgetAmount - spentAmount)
    }
    
    // MARK: - Period Comparison
    
    /// Compare two periods
    static func periodComparison(
        currentPeriodTransactions: [Transaction],
        previousPeriodTransactions: [Transaction]
    ) -> (
        currentExpenses: Decimal,
        previousExpenses: Decimal,
        percentageChange: Double
    ) {
        let currentExpenses = totalExpenses(from: currentPeriodTransactions)
        let previousExpenses = totalExpenses(from: previousPeriodTransactions)
        
        let percentageChange: Double
        if previousExpenses == 0 {
            percentageChange = currentExpenses > 0 ? 100 : 0
        } else {
            let change = (currentExpenses - previousExpenses) / previousExpenses * 100
            percentageChange = Double(truncating: change as NSDecimalNumber)
        }
        
        return (currentExpenses, previousExpenses, percentageChange)
    }
    
    // MARK: - Top Spenders
    
    /// Get top spending categories
    static func topSpendingCategories(
        from transactions: [Transaction],
        limit: Int = 5
    ) -> [(category: String, amount: Decimal)] {
        let totals = expenseCategoryTotals(from: transactions)
        return totals
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { ($0.key, $0.value) }
    }
    
    /// Get top payment methods
    static func topPaymentMethods(
        from transactions: [Transaction],
        limit: Int = 5
    ) -> [(method: String, amount: Decimal)] {
        let totals = paymentMethodTotals(from: transactions)
        return totals
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { ($0.key, $0.value) }
    }
    
    /// Get top merchants
    static func topMerchants(
        from transactions: [Transaction],
        limit: Int = 5
    ) -> [(merchant: String, amount: Decimal)] {
        let totals = merchantTotals(from: transactions)
        return totals
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { ($0.key, $0.value) }
    }
    
    // MARK: - Statistics
    
    /// Get largest transaction
    static func largestTransaction(from transactions: [Transaction]) -> Transaction? {
        transactions.max { $0.amountInSmallestUnit < $1.amountInSmallestUnit }
    }
    
    /// Get most frequent category
    static func mostFrequentCategory(from transactions: [Transaction]) -> String? {
        let categories = transactions.map { $0.category }
        let counts = categories.reduce(into: [String: Int]()) { counts, category in
            counts[category, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }
}
