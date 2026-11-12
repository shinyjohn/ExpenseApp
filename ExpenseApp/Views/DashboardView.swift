//
//  DashboardView.swift
//  ExpenseApp
//
//  Created by Santhana Shiny on 12/11/26.
//

import SwiftUI

struct DashboardView: View {
    @Bindable var viewModel: ExpenseListViewModel
    @State private var showingAdd = false

    private var categoryTotals: [(String, Double)] {
        Dictionary(grouping: viewModel.expenses, by: \.category)
            .map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.1 > $1.1 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("THIS MONTH").font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.75))
                        Text(viewModel.monthTotal, format: .currency(code: Locale.current.currency?.identifier ?? "INR"))
                            .font(.system(size: 34, weight: .bold, design: .rounded)).foregroundStyle(.white)
                        Text("Total expenses recorded").font(.subheadline).foregroundStyle(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading).padding(22)
                    .background(LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                    HStack {
                        Text("Spending by category").font(.headline)
                        Spacer()
                        Text("\(categoryTotals.count) categories").font(.caption).foregroundStyle(.secondary)
                    }
                    if categoryTotals.isEmpty {
                        ContentUnavailableView("No spending yet", systemImage: "chart.pie", description: Text("Add an expense to see your breakdown."))
                    } else {
                        ForEach(categoryTotals, id: \.0) { item in
                            VStack(spacing: 7) {
                                HStack {
                                    Label(item.0, systemImage: ExpenseCategory(rawValue: item.0)?.symbol ?? "circle")
                                    Spacer()
                                    Text(item.1, format: .currency(code: Locale.current.currency?.identifier ?? "INR")).fontWeight(.semibold)
                                }
                                ProgressView(value: item.1, total: max(viewModel.monthTotal, 1))
                            }
                        }
                    }
                    HStack {
                        Text("Recent transactions").font(.headline)
                        Spacer()
                        Text("\(viewModel.expenses.prefix(4).count) latest").font(.caption).foregroundStyle(.secondary)
                    }
                    ForEach(viewModel.expenses.prefix(4)) { expense in
                        ExpenseRow(expense: expense)
                    }
                }.padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Overview")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: { Image(systemName: "plus.circle.fill") }
                        .accessibilityLabel("Add expense")
                }
            }
            .sheet(isPresented: $showingAdd) { ExpenseFormView(viewModel: viewModel) }
            .alert("Something went wrong", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: { Text(viewModel.errorMessage ?? "Please try again.") }
        }
    }
}


