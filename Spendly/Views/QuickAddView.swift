import SwiftUI

/// Quick Add screen for fast expense/income capture
struct QuickAddView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State private var viewModel: QuickAddViewModel?
    @State private var step: QuickAddStep = .amount
    @State private var isProcessing = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let viewModel = viewModel {
                    VStack(spacing: 20) {
                        // Progress indicator
                        ProgressView(value: Double(step.rawValue) / Double(QuickAddStep.complete.rawValue))
                            .padding()
                        
                        // Step content
                        Group {
                            switch step {
                            case .amount:
                                AmountStepView(viewModel: viewModel, step: $step)
                                
                            case .paymentMethod:
                                PaymentMethodStepView(viewModel: viewModel, step: $step)
                                
                            case .category:
                                CategoryStepView(viewModel: viewModel, step: $step)
                                
                            case .details:
                                DetailsStepView(viewModel: viewModel, step: $step)
                                
                            case .review:
                                ReviewStepView(viewModel: viewModel, step: $step)
                                
                            case .complete:
                                CompletionView()
                            }
                        }
                        
                        Spacer()
                    }
                    .animation(.easeInOut, value: step)
                }
            }
            .navigationTitle("Quick Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if step != .complete {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                let service = TransactionService(modelContext: modelContext)
                viewModel = QuickAddViewModel(transactionService: service)
            }
        }
        .onChange(of: viewModel?.showSuccess) { _, newValue in
            if newValue {
                step = .complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }
}

enum QuickAddStep: Int, CaseIterable {
    case amount = 1
    case paymentMethod = 2
    case category = 3
    case details = 4
    case review = 5
    case complete = 6
}

/// Amount entry step
struct AmountStepView: View {
    @ObservedObject var viewModel: QuickAddViewModel
    @Binding var step: QuickAddStep
    @FocusState private var isAmountFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("How much did you spend?")
                    .font(.headline)
                
                HStack {
                    Text("₹")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    TextField("0", text: $viewModel.amountText)
                        .font(.system(size: 32, weight: .semibold))
                        .keyboardType(.decimalPad)
                        .focused($isAmountFocused)
                        .frame(height: 44)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            HStack(spacing: 12) {
                ForEach([100, 500, 1000, 5000], id: \.self) { amount in
                    Button(action: {
                        viewModel.amountText = String(amount)
                    }) {
                        Text("₹\(amount)")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button("Back") {
                    // Can't go back on first step
                }
                .disabled(true)
                .opacity(0)
                
                Button(action: {
                    if viewModel.parseAmount > 0 {
                        step = .paymentMethod
                    } else {
                        viewModel.errorMessage = "Please enter a valid amount"
                        viewModel.showError = true
                    }
                }) {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onAppear {
            isAmountFocused = true
        }
    }
}

/// Payment method selection step
struct PaymentMethodStepView: View {
    @ObservedObject var viewModel: QuickAddViewModel
    @Binding var step: QuickAddStep
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("How did you pay?")
                    .font(.headline)
                
                Text("₹\(String(format: "%.0f", viewModel.parseAmount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                ForEach(defaultPaymentMethods, id: \.self) { method in
                    Button(action: {
                        viewModel.selectedPaymentMethod = method
                        step = .category
                    }) {
                        HStack {
                            Text(method)
                                .font(.body)
                            Spacer()
                            if viewModel.selectedPaymentMethod == method {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(viewModel.selectedPaymentMethod == method ? Color(.systemBlue).opacity(0.1) : Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button("Back") {
                    step = .amount
                }
                
                Button(action: {
                    step = .category
                }) {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

/// Category selection step
struct CategoryStepView: View {
    @ObservedObject var viewModel: QuickAddViewModel
    @Binding var step: QuickAddStep
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("What was it for?")
                    .font(.headline)
                
                Text("₹\(String(format: "%.0f", viewModel.parseAmount)) • \(viewModel.selectedPaymentMethod)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Button(action: {
                        viewModel.selectedCategory = category
                        step = .details
                    }) {
                        HStack {
                            Text(category)
                                .font(.body)
                            Spacer()
                            if viewModel.selectedCategory == category {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(viewModel.selectedCategory == category ? Color(.systemBlue).opacity(0.1) : Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button("Back") {
                    step = .paymentMethod
                }
                
                Button(action: {
                    step = .details
                }) {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

/// Details entry step (merchant and note)
struct DetailsStepView: View {
    @ObservedObject var viewModel: QuickAddViewModel
    @Binding var step: QuickAddStep
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Any details?")
                    .font(.headline)
                
                Text("₹\(String(format: "%.0f", viewModel.parseAmount)) • \(viewModel.selectedCategory)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                TextField("Merchant (optional)", text: $viewModel.merchant)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                TextField("Note (optional)", text: $viewModel.note)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                Picker("Type", selection: $viewModel.transactionType) {
                    Text("Expense").tag(TransactionType.expense)
                    Text("Income").tag(TransactionType.income)
                }
                .pickerStyle(.segmented)
                .padding()
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button("Back") {
                    step = .category
                }
                
                Button(action: {
                    step = .review
                }) {
                    Text("Review")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

/// Review step before saving
struct ReviewStepView: View {
    @ObservedObject var viewModel: QuickAddViewModel
    @Binding var step: QuickAddStep
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Ready to save?")
                .font(.headline)
            
            VStack(spacing: 12) {
                ReviewRow(label: "Amount", value: "₹\(String(format: "%.2f", viewModel.parseAmount))")
                ReviewRow(label: "Type", value: viewModel.transactionType.rawValue.capitalized)
                ReviewRow(label: "Category", value: viewModel.selectedCategory)
                ReviewRow(label: "Payment", value: viewModel.selectedPaymentMethod)
                if !viewModel.merchant.isEmpty {
                    ReviewRow(label: "Merchant", value: viewModel.merchant)
                }
                if !viewModel.note.isEmpty {
                    ReviewRow(label: "Note", value: viewModel.note)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button("Back") {
                    step = .details
                }
                
                Button(action: {
                    Task {
                        await viewModel.saveTransaction()
                    }
                }) {
                    if viewModel.isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isSaving)
            }
        }
        .padding()
    }
}

/// Completion confirmation view
struct CompletionView: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Saved!")
                    .font(.headline)
                
                Text("Transaction recorded successfully")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

/// Review row component
struct ReviewRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .font(.caption)
            Spacer()
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    QuickAddView()
}
