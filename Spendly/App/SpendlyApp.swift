import SwiftUI
import SwiftData

/// Main Spendly application
@main
struct SpendlyApp: App {
    @StateObject private var navigationManager = NavigationManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
            Budget.self,
            RecurringTransaction.self,
            AppSettings.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .environmentObject(navigationManager)
                .onAppear {
                    handlePendingIntents()
                }
        }
    }
    
    private func handlePendingIntents() {
        if let _ = UserDefaults.standard.dictionary(forKey: "pendingQuickAddIntent") {
            navigationManager.selectedTab = .quickAdd
            UserDefaults.standard.removeObject(forKey: "pendingQuickAddIntent")
        }
        
        if UserDefaults.standard.bool(forKey: "launchQuickAdd") {
            navigationManager.selectedTab = .quickAdd
            UserDefaults.standard.set(false, forKey: "launchQuickAdd")
        }
    }
}

/// Navigation manager for app-level routing
class NavigationManager: ObservableObject {
    @Published var selectedTab: Tab = .home
    @Published var showQuickAdd: Bool = false
    
    enum Tab {
        case home
        case transactions
        case analytics
        case budgets
        case settings
        case quickAdd
    }
}

/// Main content view with tab navigation
struct ContentView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        TabView(selection: $navigationManager.selectedTab) {
            // Home
            HomeView()
                .tag(NavigationManager.Tab.home)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Transactions
            TransactionsView()
                .tag(NavigationManager.Tab.transactions)
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }
            
            // Analytics
            AnalyticsView()
                .tag(NavigationManager.Tab.analytics)
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
            
            // Budgets
            BudgetsView()
                .tag(NavigationManager.Tab.budgets)
                .tabItem {
                    Label("Budgets", systemImage: "target")
                }
            
            // Settings
            SettingsView()
                .tag(NavigationManager.Tab.settings)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .overlay(alignment: .bottom) {
            FloatingQuickAddButton()
                .environmentObject(navigationManager)
        }
    }
}

/// Home dashboard view
struct HomeView: View {
    @Environment(\.modelContext) var modelContext
    @State private var viewModel: DashboardViewModel?
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView()
                } else if let viewModel = viewModel {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Summary Cards
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Income")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("₹\(String(format: "%.0f", viewModel.totalIncome))")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Expenses")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("₹\(String(format: "%.0f", viewModel.totalExpenses))")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Savings")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("₹\(String(format: "%.0f", viewModel.netSavings))")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Rate")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(String(format: "%.0f", viewModel.savingsRate))%")
                                        .font(.headline)
                                        .foregroundColor(.purple)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            // Current Month
                            VStack(alignment: .leading, spacing: 12) {
                                Text("This Month")
                                    .font(.headline)
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Income: ₹\(String(format: "%.0f", viewModel.currentMonthIncome))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("Expenses: ₹\(String(format: "%.0f", viewModel.currentMonthExpenses))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("Savings: ₹\(String(format: "%.0f", viewModel.currentMonthSavings))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                            }
                            
                            // Recent Transactions
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent")
                                    .font(.headline)
                                
                                if viewModel.recentTransactions.isEmpty {
                                    Text("No transactions yet")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                } else {
                                    ForEach(viewModel.recentTransactions, id: \.id) { transaction in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(transaction.category)
                                                    .font(.caption)
                                                Text(transaction.merchant ?? "-")
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Text("₹\(String(format: "%.0f", transaction.amount))")
                                                .font(.caption)
                                                .foregroundColor(transaction.type == .income ? .green : .red)
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Spendly")
        }
        .onAppear {
            if viewModel == nil {
                let service = TransactionService(modelContext: modelContext)
                viewModel = DashboardViewModel(transactionService: service)
                Task {
                    await viewModel?.loadData()
                    isLoading = false
                }
            }
        }
    }
}

/// Transactions list view
struct TransactionsView: View {
    @Environment(\.modelContext) var modelContext
    @State private var viewModel: TransactionHistoryViewModel?
    @State private var isLoading = true
    @State private var selectedCategory: String?
    @State private var selectedPaymentMethod: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView()
                } else if let viewModel = viewModel {
                    List {
                        if viewModel.filteredTransactions.isEmpty {
                            Text("No transactions found")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(viewModel.filteredTransactions, id: \.id) { transaction in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(transaction.category)
                                            .font(.body)
                                        Text(transaction.merchant ?? transaction.paymentMethod)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(transaction.date.formatted(.dateTime.month().day()))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text("₹\(String(format: "%.0f", transaction.amount))")
                                        .font(.body)
                                        .foregroundColor(transaction.type == .income ? .green : .red)
                                }
                                .contextMenu {
                                    Button("Delete", role: .destructive) {
                                        Task {
                                            await viewModel.deleteTransaction(transaction)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Transactions")
        }
        .onAppear {
            if viewModel == nil {
                let service = TransactionService(modelContext: modelContext)
                viewModel = TransactionHistoryViewModel(transactionService: service)
                Task {
                    await viewModel?.loadTransactions()
                    isLoading = false
                }
            }
        }
    }
}

/// Analytics view
struct AnalyticsView: View {
    @Environment(\.modelContext) var modelContext
    @State private var viewModel: AnalyticsViewModel?
    @State private var isLoading = true
    @State private var selectedPeriod: AnalyticsPeriod = .month
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Period", selection: $selectedPeriod) {
                    Text("Week").tag(AnalyticsPeriod.week)
                    Text("Month").tag(AnalyticsPeriod.month)
                    Text("Year").tag(AnalyticsPeriod.year)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if isLoading {
                    ProgressView()
                } else if let viewModel = viewModel {
                    ScrollView {
                        VStack(spacing: 16) {
                            switch selectedPeriod {
                            case .week:
                                WeeklyAnalyticsView(viewModel: viewModel)
                            case .month:
                                MonthlyAnalyticsView(viewModel: viewModel)
                            case .year:
                                YearlyAnalyticsView(viewModel: viewModel)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Analytics")
        }
        .onChange(of: selectedPeriod) { _, newValue in
            if let viewModel = viewModel {
                DispatchQueue.main.async {
                    viewModel.selectedPeriod = newValue
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                let service = TransactionService(modelContext: modelContext)
                viewModel = AnalyticsViewModel(transactionService: service)
                Task {
                    await viewModel?.loadData()
                    isLoading = false
                }
            }
        }
    }
}

struct WeeklyAnalyticsView: View {
    let viewModel: AnalyticsViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Income")
                            .font(.caption)
                        Text("₹\(String(format: "%.0f", viewModel.weeklyIncome))")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Expenses")
                            .font(.caption)
                        Text("₹\(String(format: "%.0f", viewModel.weeklyExpenses))")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Savings")
                            .font(.caption)
                        Text("₹\(String(format: "%.0f", viewModel.weeklySavings))")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Avg Daily")
                            .font(.caption)
                        Text("₹\(String(format: "%.0f", viewModel.weeklyAverageDailySpending))")
                            .font(.headline)
                            .foregroundColor(.purple)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
}

struct MonthlyAnalyticsView: View {
    let viewModel: AnalyticsViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Income")
                            .font(.caption)
                        Text("₹\(String(format: "%.0f", viewModel.monthlyIncome))")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Expenses")
                            .font(.caption)
                        Text("₹\(String(format: "%.0f", viewModel.monthlyExpenses))")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Savings")
                            .font(.caption)
                        Text("₹\(String(format: "%.0f", viewModel.monthlySavings))")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Rate")
                            .font(.caption)
                        Text("\(String(format: "%.0f", viewModel.monthlySavingsRate))%")
                            .font(.headline)
                            .foregroundColor(.purple)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
}

struct YearlyAnalyticsView: View {
    let viewModel: AnalyticsViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Income")
                            .font(.caption)
                        Text("₹\(String(format: "%.0f", viewModel.yearlyIncome))")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Expenses")
                            .font(.caption)
                        Text("₹\(String(format: "%.0f", viewModel.yearlyExpenses))")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Savings")
                            .font(.caption)
                        Text("₹\(String(format: "%.0f", viewModel.yearlySavings))")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
}

/// Budgets view
struct BudgetsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Budget management coming soon")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Budgets")
        }
    }
}

/// Settings view
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("App") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Data") {
                    NavigationLink("Export Data") {
                        ExportDataView()
                    }
                    NavigationLink("Import Data") {
                        ImportDataView()
                    }
                }
                
                Section("Help") {
                    Link("Documentation", destination: URL(string: "https://github.com/istartedcoding/spendly")!)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

/// Export data view
struct ExportDataView: View {
    @Environment(\.modelContext) var modelContext
    @State private var exportedData: String?
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Button {
                    Task {
                        let service = TransactionService(modelContext: modelContext)
                        let transactions = try? await service.fetchAllTransactions()
                        exportedData = ImportExportService.exportToCSV(transactions ?? [])
                        showShareSheet = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.doc")
                        Text("Export as CSV")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    Task {
                        let service = TransactionService(modelContext: modelContext)
                        let transactions = try? await service.fetchAllTransactions()
                        if let jsonData = ImportExportService.exportToJSON(transactions ?? []),
                           let jsonString = String(data: jsonData, encoding: .utf8) {
                            exportedData = jsonString
                            showShareSheet = true
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.doc")
                        Text("Export as JSON")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Export Data")
        .sheet(isPresented: $showShareSheet) {
            if let data = exportedData {
                ShareSheet(items: [data])
            }
        }
    }
}

/// Import data view
struct ImportDataView: View {
    var body: some View {
        VStack {
            Text("Import coming soon")
                .foregroundColor(.secondary)
        }
        .navigationTitle("Import Data")
    }
}

/// Share sheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

/// Floating Quick Add button
struct FloatingQuickAddButton: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    navigationManager.showQuickAdd = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .padding()
                .sheet(isPresented: $navigationManager.showQuickAdd) {
                    QuickAddView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
