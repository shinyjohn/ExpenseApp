import Foundation
import SwiftData
@testable import ExpenseApp

@MainActor
enum TestStore {

    static func makeRepository() throws -> ExpenseRepository {
        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: true
        )

        let container = try ModelContainer(
            for: Expense.self,
            configurations: configuration
        )

        let context = ModelContext(container)

        return ExpenseRepository(context: context)
    }
}

struct TestAPI: ExpenseAPIProtocol {
    var result: Result<[RemoteExpense], TestFailure> = .success([])

    func fetchExpenses() async throws -> [RemoteExpense] {
        try result.get()
    }
}

enum TestFailure: Error, LocalizedError, Equatable {
    case expected
    var errorDescription: String? { "Expected test failure" }
}

@MainActor
final class FailingExpenseRepository: ExpenseRepositoryProtocol {
    func all() throws -> [Expense] { throw TestFailure.expected }
    func add(title: String, amount: Double, category: String, date: Date, note: String) throws { throw TestFailure.expected }
    func update(_ expense: Expense, title: String, amount: Double, category: String, date: Date, note: String) throws { throw TestFailure.expected }
    func delete(_ expense: Expense) throws { throw TestFailure.expected }
    func importRemote(_ records: [RemoteExpense]) throws { throw TestFailure.expected }
}
