//
//  ExpenseComponents.swift
//  ExpenseApp
//
//  Created by Santhana Shiny on 12/11/26.
//

import SwiftUI

struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: ExpenseCategory(rawValue: expense.category)?.symbol ?? "circle")
                .font(.headline).foregroundStyle(.tint)
                .frame(width: 42, height: 42)
                .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 13))
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title).font(.subheadline.weight(.semibold))
                Text("\(expense.category) · \(expense.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(expense.amount, format: .currency(code: Locale.current.currency?.identifier ?? "INR"))
                .font(.subheadline.weight(.semibold))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(expense.title), \(expense.category), \(expense.amount.formatted(.number.precision(.fractionLength(2))))")
    }
}

struct ExpenseDetailView: View {
    let expense: Expense
    @Bindable var viewModel: ExpenseListViewModel
    @State private var editing = false

    var body: some View {
        Form {
            Section("Expense") {
                LabeledContent("Title", value: expense.title)
                LabeledContent("Amount", value: expense.amount.formatted(.currency(code: Locale.current.currency?.identifier ?? "INR")))
                LabeledContent("Category", value: expense.category)
                LabeledContent("Date", value: expense.date.formatted(date: .long, time: .omitted))
                if !expense.note.isEmpty { LabeledContent("Note", value: expense.note) }
            }
        }
        .navigationTitle("Details")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { editing = true }
            }
        }
        .sheet(isPresented: $editing) { ExpenseFormView(viewModel: viewModel, expense: expense) }
    }
}

