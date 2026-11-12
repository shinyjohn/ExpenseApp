//
//  ExpenseListViewModel.swift
//  ExpenseApp
//
//  Created by Santhana Shiny on 12/11/26.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class ExpenseListViewModel {
    private let repository: ExpenseRepositoryProtocol
    private let api: ExpenseAPIProtocol

    private(set) var expenses: [Expense] = []
    private(set) var isLoading = false
    var errorMessage: String?
    var searchText = ""
    var selectedCategory: String = "All"

    init(repository: ExpenseRepositoryProtocol, api: ExpenseAPIProtocol) {
        self.repository = repository
        self.api = api
    }

    var filteredExpenses: [Expense] {
        expenses.filter { expense in
            let matchesCategory = selectedCategory == "All" || expense.category == selectedCategory
            let matchesSearch = searchText.isEmpty || expense.title.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    var monthTotal: Double {
        let calendar = Calendar.current
        return expenses.filter { calendar.isDate($0.date, equalTo: .now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    func load() {
        do {
            expenses = try repository.all()
        }
        catch {
            errorMessage = error.localizedDescription
        }
    }

    func add(title: String, amount: Double, category: String, date: Date, note: String) {
        do {
            try repository.add(title: title, amount: amount, category: category, date: date, note: note)
            load()
        } catch { errorMessage = error.localizedDescription }
    }

    func update(_ expense: Expense, title: String, amount: Double, category: String, date: Date, note: String) {
        do {
            try repository.update(expense, title: title, amount: amount, category: category, date: date, note: note)
            load()
        } catch { errorMessage = error.localizedDescription }
    }

    func delete(_ expense: Expense) {
        do { try repository.delete(expense); load() }
        catch { errorMessage = error.localizedDescription }
    }

    func sync() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let remote = try await api.fetchExpenses()
            try repository.importRemote(remote)
            load()
        } catch { errorMessage = error.localizedDescription }
    }
}

