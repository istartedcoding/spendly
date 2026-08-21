import Foundation

/// Service for importing and exporting financial data
struct ImportExportService {
    
    // MARK: - Export to CSV
    
    /// Export transactions to CSV format
    static func exportToCSV(_ transactions: [Transaction]) -> String {
        var csv = "Date,Time,Type,Amount,Currency,Category,Payment Method,Merchant,Note\n"
        
        for transaction in transactions.sorted(by: { $0.date > $1.date }) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: transaction.date)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            let timeString = timeFormatter.string(from: transaction.date)
            
            let amount = String(format: "%.2f", Double(truncating: transaction.amountInSmallestUnit as NSDecimalNumber) / 100.0)
            let merchant = transaction.merchant ?? ""
            let note = transaction.note ?? ""
            
            let csvLine = "\(dateString),\(timeString),\(transaction.type.rawValue),\(amount),\(transaction.currency),\(transaction.category),\(transaction.paymentMethod),\(merchant),\(note)\n"
            csv.append(csvLine)
        }
        
        return csv
    }
    
    // MARK: - Export to JSON
    
    /// Export transactions to JSON format
    static func exportToJSON(_ transactions: [Transaction]) -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let transactionDicts = transactions.map { transaction -> [String: Any] in
            [
                "id": transaction.id,
                "type": transaction.type.rawValue,
                "amount": Double(truncating: transaction.amountInSmallestUnit as NSDecimalNumber) / 100.0,
                "currency": transaction.currency,
                "category": transaction.category,
                "paymentMethod": transaction.paymentMethod,
                "merchant": transaction.merchant as Any,
                "note": transaction.note as Any,
                "date": ISO8601DateFormatter().string(from: transaction.date),
                "createdAt": ISO8601DateFormatter().string(from: transaction.createdAt),
                "updatedAt": ISO8601DateFormatter().string(from: transaction.updatedAt),
                "recurringTransactionId": transaction.recurringTransactionId as Any,
                "importSource": transaction.importSource as Any,
                "externalReference": transaction.externalReference as Any
            ]
        }
        
        do {
            return try JSONSerialization.data(withJSONObject: transactionDicts, options: .prettyPrinted)
        } catch {
            return nil
        }
    }
    
    // MARK: - Import from CSV
    
    /// Import transactions from CSV data
    static func importFromCSV(_ csvData: String) -> (transactions: [Transaction], errors: [String]) {
        var transactions: [Transaction] = []
        var errors: [String] = []
        
        let lines = csvData.components(separatedBy: .newlines)
        guard lines.count > 1 else {
            errors.append("CSV file is empty")
            return (transactions, errors)
        }
        
        // Skip header line
        for (index, line) in lines.dropFirst().enumerated() {
            let lineNumber = index + 2
            
            guard !line.trimmingCharacters(in: .whitespaces).isEmpty else {
                continue
            }
            
            let components = line.components(separatedBy: ",")
            guard components.count >= 6 else {
                errors.append("Line \(lineNumber): Invalid format, expected at least 6 columns")
                continue
            }
            
            let dateString = components[0].trimmingCharacters(in: .whitespaces)
            let typeString = components[2].trimmingCharacters(in: .whitespaces)
            let amountString = components[3].trimmingCharacters(in: .whitespaces)
            let currency = components[4].trimmingCharacters(in: .whitespaces)
            let category = components[5].trimmingCharacters(in: .whitespaces)
            let paymentMethod = components.count > 6 ? components[6].trimmingCharacters(in: .whitespaces) : "Other"
            let merchant = components.count > 7 ? components[7].trimmingCharacters(in: .whitespaces) : nil
            let note = components.count > 8 ? components[8].trimmingCharacters(in: .whitespaces) : nil
            
            // Validate date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard let date = dateFormatter.date(from: dateString) else {
                errors.append("Line \(lineNumber): Invalid date format (expected yyyy-MM-dd)")
                continue
            }
            
            // Validate type
            guard let type = TransactionType(rawValue: typeString.lowercased()) else {
                errors.append("Line \(lineNumber): Invalid transaction type (expected 'expense' or 'income')")
                continue
            }
            
            // Validate amount
            guard let amount = Double(amountString) else {
                errors.append("Line \(lineNumber): Invalid amount")
                continue
            }
            
            guard amount > 0 else {
                errors.append("Line \(lineNumber): Amount must be greater than zero")
                continue
            }
            
            let transaction = Transaction(
                type: type,
                amountInSmallestUnit: Decimal(amount * 100.0),
                currency: currency.isEmpty ? "INR" : currency,
                category: category.isEmpty ? "Other" : category,
                paymentMethod: paymentMethod.isEmpty ? "Other" : paymentMethod,
                merchant: merchant?.isEmpty ?? true ? nil : merchant,
                note: note?.isEmpty ?? true ? nil : note,
                date: date,
                importSource: "csv"
            )
            
            transactions.append(transaction)
        }
        
        return (transactions, errors)
    }
    
    // MARK: - Import from JSON
    
    /// Import transactions from JSON data
    static func importFromJSON(_ jsonData: Data) -> (transactions: [Transaction], errors: [String]) {
        var transactions: [Transaction] = []
        var errors: [String] = []
        
        do {
            guard let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
                errors.append("Invalid JSON format")
                return (transactions, errors)
            }
            
            for (index, item) in jsonArray.enumerated() {
                do {
                    guard let typeString = item["type"] as? String,
                          let type = TransactionType(rawValue: typeString),
                          let amount = item["amount"] as? Double,
                          let currency = item["currency"] as? String,
                          let category = item["category"] as? String,
                          let paymentMethod = item["paymentMethod"] as? String,
                          let dateString = item["date"] as? String else {
                        errors.append("Item \(index + 1): Missing required fields")
                        continue
                    }
                    
                    guard amount > 0 else {
                        errors.append("Item \(index + 1): Amount must be greater than zero")
                        continue
                    }
                    
                    let dateFormatter = ISO8601DateFormatter()
                    guard let date = dateFormatter.date(from: dateString) else {
                        errors.append("Item \(index + 1): Invalid date format")
                        continue
                    }
                    
                    let merchant = item["merchant"] as? String
                    let note = item["note"] as? String
                    
                    let transaction = Transaction(
                        type: type,
                        amountInSmallestUnit: Decimal(amount * 100.0),
                        currency: currency,
                        category: category,
                        paymentMethod: paymentMethod,
                        merchant: merchant?.isEmpty ?? true ? nil : merchant,
                        note: note?.isEmpty ?? true ? nil : note,
                        date: date,
                        importSource: "json"
                    )
                    
                    transactions.append(transaction)
                } catch {
                    errors.append("Item \(index + 1): \(error.localizedDescription)")
                    continue
                }
            }
        } catch {
            errors.append("Failed to parse JSON: \(error.localizedDescription)")
        }
        
        return (transactions, errors)
    }
    
    // MARK: - Duplicate Detection
    
    /// Detect potential duplicate transactions
    static func detectDuplicates(
        _ newTransactions: [Transaction],
        against existingTransactions: [Transaction]
    ) -> [Transaction] {
        var duplicates: [Transaction] = []
        
        for newTransaction in newTransactions {
            for existingTransaction in existingTransactions {
                if isSuspectedDuplicate(newTransaction, existingTransaction) {
                    duplicates.append(newTransaction)
                    break
                }
            }
        }
        
        return duplicates
    }
    
    /// Check if two transactions are suspected duplicates
    private static func isSuspectedDuplicate(
        _ transaction1: Transaction,
        _ transaction2: Transaction
    ) -> Bool {
        let calendar = Calendar.current
        
        // Same amount, category, and date
        let sameAmount = transaction1.amountInSmallestUnit == transaction2.amountInSmallestUnit
        let sameCategory = transaction1.category == transaction2.category
        let sameDate = calendar.isDate(transaction1.date, inSameDayAs: transaction2.date)
        let samePaymentMethod = transaction1.paymentMethod == transaction2.paymentMethod
        
        return sameAmount && sameCategory && sameDate && samePaymentMethod
    }
    
    // MARK: - Excel-Compatible Export
    
    /// Export to Excel-compatible CSV with summary sheets
    static func exportToExcelCSV(_ transactions: [Transaction]) -> String {
        var excel = ""
        
        // Transactions sheet
        excel += "--- TRANSACTIONS ---\n"
        excel += exportToCSV(transactions)
        excel += "\n\n"
        
        // Categories sheet
        excel += "--- CATEGORY SUMMARY ---\n"
        excel += "Category,Total Expenses\n"
        let categoryTotals = AnalyticsService.expenseCategoryTotals(from: transactions)
        for (category, amount) in categoryTotals.sorted(by: { $0.value > $1.value }) {
            let displayAmount = String(format: "%.2f", Double(truncating: amount as NSDecimalNumber) / 100.0)
            excel += "\(category),\(displayAmount)\n"
        }
        excel += "\n\n"
        
        // Payment Methods sheet
        excel += "--- PAYMENT METHOD SUMMARY ---\n"
        excel += "Payment Method,Total Expenses\n"
        let paymentMethodTotals = AnalyticsService.paymentMethodTotals(from: transactions)
        for (method, amount) in paymentMethodTotals.sorted(by: { $0.value > $1.value }) {
            let displayAmount = String(format: "%.2f", Double(truncating: amount as NSDecimalNumber) / 100.0)
            excel += "\(method),\(displayAmount)\n"
        }
        excel += "\n\n"
        
        // Summary sheet
        excel += "--- SUMMARY ---\n"
        let totalIncome = AnalyticsService.totalIncome(from: transactions)
        let totalExpenses = AnalyticsService.totalExpenses(from: transactions)
        let savings = AnalyticsService.netSavings(from: transactions)
        let savingsRate = AnalyticsService.savingsRate(from: transactions)
        
        excel += "Metric,Value\n"
        excel += "Total Income,\(String(format: "%.2f", Double(truncating: totalIncome as NSDecimalNumber) / 100.0))\n"
        excel += "Total Expenses,\(String(format: "%.2f", Double(truncating: totalExpenses as NSDecimalNumber) / 100.0))\n"
        excel += "Net Savings,\(String(format: "%.2f", Double(truncating: savings as NSDecimalNumber) / 100.0))\n"
        excel += "Savings Rate,\(String(format: "%.2f%%", savingsRate))\n"
        
        return excel
    }
}
