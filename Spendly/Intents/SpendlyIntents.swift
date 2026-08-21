import Foundation
import AppIntents

/// App Intent for recording expenses via Shortcuts
@available(iOS 16.0, *)
struct RecordSpendlyExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Record Spendly Expense"
    static var description: LocalizedStringResource = "Quickly record an expense in Spendly"
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Amount", description: "The expense amount")
    var amount: Double
    
    @Parameter(title: "Category", description: "Expense category")
    var category: String?
    
    @Parameter(title: "Payment Method", description: "How you paid")
    var paymentMethod: String?
    
    @Parameter(title: "Merchant", description: "Where you spent (optional)")
    var merchant: String?
    
    @Parameter(title: "Note", description: "Additional notes (optional)")
    var note: String?
    
    func perform() async throws -> some IntentResult {
        // Store the intent data in UserDefaults for the app to process
        // when it launches/comes to foreground
        let intentData: [String: Any] = [
            "amount": amount,
            "category": category ?? "",
            "paymentMethod": paymentMethod ?? "",
            "merchant": merchant ?? "",
            "note": note ?? "",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        UserDefaults.standard.set(intentData, forKey: "pendingQuickAddIntent")
        
        return .result(
            dialog: IntentDialog(stringLiteral: "Recording ₹\(String(format: "%.2f", amount))...")
        )
    }
}

/// App Intent for launching Quick Add
@available(iOS 16.0, *)
struct LaunchQuickAddIntent: AppIntent {
    static var title: LocalizedStringResource = "Launch Spendly Quick Add"
    static var description: LocalizedStringResource = "Open Spendly to quickly record a transaction"
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set(true, forKey: "launchQuickAdd")
        return .result(dialog: IntentDialog(stringLiteral: "Opening Spendly..."))
    }
}

/// Shortcuts app shortcut provider
@available(iOS 16.0, *)
struct SpendlyShortcuts: AppShortcutsProvider {
    static var allShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LaunchQuickAddIntent(),
            phrases: [
                "Open Spendly Quick Add",
                "Quick add expense",
                "Record expense in Spendly"
            ]
        )
        
        AppShortcut(
            intent: RecordSpendlyExpenseIntent(),
            phrases: [
                "Record a Spendly expense",
                "Add expense to Spendly"
            ]
        )
    }
}
