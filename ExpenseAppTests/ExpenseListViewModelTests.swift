import XCTest
import SwiftData
@testable import ExpenseApp

@MainActor
final class ExpenseListViewModelTests: XCTestCase {
    func testLoadFetchesExpenses() throws {
        let repository = try TestStore.makeRepository()
        try repository.add(title: "Coffee", amount: 120, category: "Food", date: .now, note: "")
        let sut = ExpenseListViewModel(repository: repository, api: TestAPI())

        sut.load()

        XCTAssertEqual(sut.expenses.count, 1)
        XCTAssertEqual(sut.expenses.first?.title, "Coffee")
    }

    func testLoadSetsErrorWhenRepositoryFails() {
        let sut = ExpenseListViewModel(repository: FailingExpenseRepository(), api: TestAPI())
        sut.load()
        XCTAssertEqual(sut.errorMessage, TestFailure.expected.localizedDescription)
    }

    func testAddExpensePersistsAndUpdatesList() throws {
        let repository = try TestStore.makeRepository()
        let sut = ExpenseListViewModel(repository: repository, api: TestAPI())
        sut.add(title: "Coffee", amount: 120, category: "Food", date: .now, note: "Morning")
        XCTAssertEqual(sut.expenses.count, 1)
        XCTAssertEqual(sut.expenses.first?.title, "Coffee")
        XCTAssertEqual(sut.expenses.first?.amount, 120)
        XCTAssertEqual(sut.expenses.first?.note, "Morning")
    }

    func testAddSetsErrorWhenRepositoryFails() {
        let sut = ExpenseListViewModel(repository: FailingExpenseRepository(), api: TestAPI())
        sut.add(title: "Coffee", amount: 10, category: "Food", date: .now, note: "")
        XCTAssertEqual(sut.errorMessage, TestFailure.expected.localizedDescription)
    }

    func testUpdateExpenseChangesPersistedValues() throws {
        let repository = try TestStore.makeRepository()
        try repository.add(title: "Coffee", amount: 100, category: "Food", date: .now, note: "Old")
        let sut = ExpenseListViewModel(repository: repository, api: TestAPI())
        sut.load()
        let expense = try XCTUnwrap(sut.expenses.first)

        sut.update(expense, title: "Tea", amount: 80, category: "Food", date: .now, note: "New")

        XCTAssertEqual(sut.expenses.first?.title, "Tea")
        XCTAssertEqual(sut.expenses.first?.amount, 80)
        XCTAssertEqual(sut.expenses.first?.note, "New")
    }

    func testUpdateSetsErrorWhenRepositoryFails() {
        let expense = Expense(title: "Coffee", amount: 10, category: "Food")
        let sut = ExpenseListViewModel(repository: FailingExpenseRepository(), api: TestAPI())
        sut.update(expense, title: "Tea", amount: 20, category: "Food", date: .now, note: "")
        XCTAssertEqual(sut.errorMessage, TestFailure.expected.localizedDescription)
    }

    func testDeleteRemovesExpense() throws {
        let repository = try TestStore.makeRepository()
        try repository.add(title: "Coffee", amount: 100, category: "Food", date: .now, note: "")
        let sut = ExpenseListViewModel(repository: repository, api: TestAPI())
        sut.load()
        let expense = try XCTUnwrap(sut.expenses.first)

        sut.delete(expense)

        XCTAssertTrue(sut.expenses.isEmpty)
    }

    func testDeleteSetsErrorWhenRepositoryFails() {
        let expense = Expense(title: "Coffee", amount: 10, category: "Food")
        let sut = ExpenseListViewModel(repository: FailingExpenseRepository(), api: TestAPI())
        sut.delete(expense)
        XCTAssertEqual(sut.errorMessage, TestFailure.expected.localizedDescription)
    }

    func testSearchFiltersTransactionsCaseInsensitively() throws {
        let repository = try TestStore.makeRepository()
        try repository.add(title: "Coffee", amount: 100, category: "Food", date: .now, note: "")
        try repository.add(title: "Taxi", amount: 250, category: "Transport", date: .now, note: "")
        let sut = ExpenseListViewModel(repository: repository, api: TestAPI())
        sut.load()
        sut.searchText = "COF"
        XCTAssertEqual(sut.filteredExpenses.map(\.title), ["Coffee"])
    }

    func testCategoryFilter() throws {
        let repository = try TestStore.makeRepository()
        try repository.add(title: "Coffee", amount: 100, category: "Food", date: .now, note: "")
        try repository.add(title: "Taxi", amount: 250, category: "Transport", date: .now, note: "")
        let sut = ExpenseListViewModel(repository: repository, api: TestAPI())
        sut.load()
        sut.selectedCategory = "Transport"
        XCTAssertEqual(sut.filteredExpenses.map(\.title), ["Taxi"])
    }

    func testAllCategoryDoesNotFilter() throws {
        let repository = try TestStore.makeRepository()
        try repository.add(title: "Coffee", amount: 100, category: "Food", date: .now, note: "")
        try repository.add(title: "Taxi", amount: 250, category: "Transport", date: .now, note: "")
        let sut = ExpenseListViewModel(repository: repository, api: TestAPI())
        sut.load()
        XCTAssertEqual(sut.filteredExpenses.count, 2)
    }

    func testSearchAndCategoryFiltersAreAppliedTogether() throws {
        let repository = try TestStore.makeRepository()
        try repository.add(title: "Coffee Shop", amount: 100, category: "Food", date: .now, note: "")
        try repository.add(title: "Coffee Taxi", amount: 250, category: "Transport", date: .now, note: "")
        let sut = ExpenseListViewModel(repository: repository, api: TestAPI())
        sut.load()
        sut.searchText = "coffee"
        sut.selectedCategory = "Food"
        XCTAssertEqual(sut.filteredExpenses.map(\.title), ["Coffee Shop"])
    }

    func testSearchWithNoMatchesReturnsEmptyArray() throws {
        let repository = try TestStore.makeRepository()
        try repository.add(title: "Coffee", amount: 100, category: "Food", date: .now, note: "")
        let sut = ExpenseListViewModel(repository: repository, api: TestAPI())
        sut.load()
        sut.searchText = "missing"
        XCTAssertTrue(sut.filteredExpenses.isEmpty)
    }

    func testMonthTotalIncludesCurrentMonthExpenses() throws {
        let repository = try TestStore.makeRepository()
        try repository.add(title: "Coffee", amount: 100, category: "Food", date: .now, note: "")
        try repository.add(title: "Taxi", amount: 250, category: "Transport", date: .now, note: "")
        let sut = ExpenseListViewModel(repository: repository, api: TestAPI())
        sut.load()
        XCTAssertEqual(sut.monthTotal, 350, accuracy: 0.001)
    }

    func testMonthTotalExcludesPreviousMonthExpenses() throws {
        let repository = try TestStore.makeRepository()
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: .now)!
        try repository.add(title: "Old", amount: 500, category: "Bills", date: previousMonth, note: "")
        try repository.add(title: "Current", amount: 200, category: "Food", date: .now, note: "")
        let sut = ExpenseListViewModel(repository: repository, api: TestAPI())
        sut.load()
        XCTAssertEqual(sut.monthTotal, 200, accuracy: 0.001)
    }

    func testSyncImportsRemoteRecords() async throws {
        let repository = try TestStore.makeRepository()
        let remote = [RemoteExpense(userId: 1, id: 7, title: "groceries", body: "Weekly shopping")]
        let sut = ExpenseListViewModel(repository: repository, api: TestAPI(result: .success(remote)))

        await sut.sync()

        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.expenses.count, 1)
        XCTAssertEqual(sut.expenses.first?.remoteID, 7)
    }

    func testSyncSetsErrorAndResetsLoadingWhenAPIThrows() async throws {
        let repository = try TestStore.makeRepository()

        let sut = ExpenseListViewModel(
            repository: repository,
            api: TestAPI(result: .failure(.expected))
        )

        await sut.sync()

        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(
            sut.errorMessage,
            TestFailure.expected.localizedDescription
        )
    }

    func testSyncSetsErrorWhenImportFails() async {
        let remote = [RemoteExpense(userId: 1, id: 1, title: "test", body: "body")]
        let sut = ExpenseListViewModel(repository: FailingExpenseRepository(), api: TestAPI(result: .success(remote)))

        await sut.sync()

        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.errorMessage, TestFailure.expected.localizedDescription)
    }
}
