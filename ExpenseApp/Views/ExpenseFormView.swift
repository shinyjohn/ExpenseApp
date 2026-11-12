//
//  ExpenseFormView.swift
//  ExpenseApp
//
//  Created by Santhana Shiny on 12/11/26.
//

import SwiftUI

struct ExpenseFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: ExpenseListViewModel
    var expense: Expense?

    @State private var title = ""
    @State private var amount = ""
    @State private var category = ExpenseCategory.food.rawValue
    @State private var date = Date.now
    @State private var note = ""
    @State private var validationMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Expense details") {
                    TextField("Description", text: $title)
                        .accessibilityIdentifier("expenseTitleField")
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("expenseAmountField")
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases) { item in
                            Label(item.rawValue, systemImage: item.symbol).tag(item.rawValue)
                        }
                    }
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Note (optional)", text: $note, axis: .vertical)
                }
            }
            .navigationTitle(expense == nil ? "Add Expense" : "Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.fontWeight(.semibold)
                        .accessibilityIdentifier("saveExpenseButton")
                }
            }
            .onAppear {
                guard let expense else { return }
                title = expense.title
                amount = String(expense.amount)
                category = expense.category
                date = expense.date
                note = expense.note
            }
            .alert("Check your expense", isPresented: Binding(get: { validationMessage != nil }, set: { if !$0 { validationMessage = nil } })) {
                Button("OK", role: .cancel) { validationMessage = nil }
            } message: { Text(validationMessage ?? "") }
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { validationMessage = "Enter a description."; return }
        guard let parsedAmount = Double(amount), parsedAmount > 0, parsedAmount.isFinite else {
            validationMessage = "Enter an amount greater than zero."; return
        }
        if let expense {
            viewModel.update(expense, title: trimmedTitle, amount: parsedAmount, category: category, date: date, note: note)
        } else {
            viewModel.add(title: trimmedTitle, amount: parsedAmount, category: category, date: date, note: note)
        }
        dismiss()
    }
}



