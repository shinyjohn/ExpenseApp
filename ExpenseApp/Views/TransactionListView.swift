//
//  TransactionListView.swift
//  ExpenseApp
//
//  Created by Santhana Shiny on 12/11/26.
//

import SwiftUI

struct TransactionListView: View {
    @Bindable var viewModel: ExpenseListViewModel
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        Text("All categories").tag("All")
                        ForEach(ExpenseCategory.allCases) { category in
                            Text(category.rawValue).tag(category.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }
                Section("Transactions") {
                    if viewModel.filteredExpenses.isEmpty {
                        ContentUnavailableView("No transactions", systemImage: "tray", description: Text("Try another filter or add an expense."))
                    } else {
                        ForEach(viewModel.filteredExpenses) { expense in
                            NavigationLink {
                                ExpenseDetailView(expense: expense, viewModel: viewModel)
                            } label: { ExpenseRow(expense: expense) }
                        }
                        .onDelete { offsets in
                            for index in offsets { viewModel.delete(viewModel.filteredExpenses[index]) }
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search expenses")
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task { await viewModel.sync() }
                    } label: {
                        if viewModel.isLoading { ProgressView() } else { Image(systemName: "arrow.triangle.2.circlepath") }
                    }
                    .disabled(viewModel.isLoading)
                    .accessibilityLabel("Sync transactions")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Add expense")
                }
            }
            .sheet(isPresented: $showingAdd) { ExpenseFormView(viewModel: viewModel) }
            .refreshable { await viewModel.sync() }
        }
    }
}

