//
//  ExpenseRepository.swift
//  ExpenseApp
//
//  Created by Santhana Shiny on 12/11/26.
//

import Foundation
import SwiftData

@MainActor
protocol ExpenseRepositoryProtocol {
    func all() throws -> [Expense]
    func add(title: String, amount: Double, category: String, date: Date, note: String) throws
    func update(_ expense: Expense, title: String, amount: Double, category: String, date: Date, note: String) throws
    func delete(_ expense: Expense) throws
    func importRemote(_ records: [RemoteExpense]) throws
}

@MainActor
final class ExpenseRepository: ExpenseRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func all() throws -> [Expense] {
        let descriptor = FetchDescriptor<Expense>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return try context.fetch(descriptor)
    }

    func add(title: String, amount: Double, category: String, date: Date, note: String) throws {
        context.insert(Expense(title: title, amount: amount, category: category, date: date, note: note))
        try context.save()
    }

    func update(_ expense: Expense, title: String, amount: Double, category: String, date: Date, note: String) throws {
        expense.title = title
        expense.amount = amount
        expense.category = category
        expense.date = date
        expense.note = note
        try context.save()
    }

    func delete(_ expense: Expense) throws {
        context.delete(expense)
        try context.save()
    }

    func importRemote(_ records: [RemoteExpense]) throws {
        let existing = try all()
        let knownIDs = Set(existing.compactMap(\.remoteID))
        for record in records where !knownIDs.contains(record.id) {
            context.insert(Expense(title: record.title.capitalized,
                                   amount: Double((record.id * 137) % 4200 + 100),
                                   category: ExpenseCategory.allCases[record.id % ExpenseCategory.allCases.count].rawValue,
                                   date: Calendar.current.date(byAdding: .day, value: -(record.id % 30), to: .now) ?? .now,
                                   note: record.body, remoteID: record.id))
        }
        try context.save()
    }
}

