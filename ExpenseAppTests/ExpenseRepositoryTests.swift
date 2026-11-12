import XCTest
import SwiftData
@testable import ExpenseApp

@MainActor
final class ExpenseRepositoryTests: XCTestCase {
    func testAddAndFetchExpense() throws {
        let repository = try TestStore.makeRepository()
        try repository.add(title: "Lunch", amount: 240, category: "Food", date: .now, note: "Office")
        let records = try repository.all()
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.title, "Lunch")
        XCTAssertEqual(records.first?.note, "Office")
    }

    func testFetchSortsNewestFirst() throws {
        let repository = try TestStore.makeRepository()
        let older = Date(timeIntervalSince1970: 1_000)
        let newer = Date(timeIntervalSince1970: 2_000)
        try repository.add(title: "Old", amount: 10, category: "Other", date: older, note: "")
        try repository.add(title: "New", amount: 20, category: "Other", date: newer, note: "")
        XCTAssertEqual(try repository.all().map(\.title), ["New", "Old"])
    }

    func testUpdateChangesAllFields() throws {
        let repository = try TestStore.makeRepository()
        try repository.add(title: "Old", amount: 10, category: "Food", date: .now, note: "Old note")
        let expense = try XCTUnwrap(repository.all().first)
        let newDate = Date(timeIntervalSince1970: 100)
        try repository.update(expense, title: "New", amount: 99, category: "Shopping", date: newDate, note: "New note")
        let updated = try XCTUnwrap(repository.all().first)
        XCTAssertEqual(updated.title, "New")
        XCTAssertEqual(updated.amount, 99)
        XCTAssertEqual(updated.category, "Shopping")
        XCTAssertEqual(updated.date, newDate)
        XCTAssertEqual(updated.note, "New note")
    }

    func testDeleteRemovesExpense() throws {
        let repository = try TestStore.makeRepository()
        try repository.add(title: "Delete me", amount: 10, category: "Other", date: .now, note: "")
        let expense = try XCTUnwrap(repository.all().first)
        try repository.delete(expense)
        XCTAssertTrue(try repository.all().isEmpty)
    }

    func testImportRemoteCreatesExpenseWithMappedValues() throws {
        let repository = try TestStore.makeRepository()
        let remote = RemoteExpense(userId: 2, id: 3, title: "weekly groceries", body: "Imported note")
        try repository.importRemote([remote])
        let imported = try XCTUnwrap(repository.all().first)
        XCTAssertEqual(imported.title, "Weekly Groceries")
        XCTAssertEqual(imported.remoteID, 3)
        XCTAssertEqual(imported.note, "Imported note")
        XCTAssertEqual(imported.amount, Double((3 * 137) % 4200 + 100))
        XCTAssertEqual(imported.category, ExpenseCategory.allCases[3 % ExpenseCategory.allCases.count].rawValue)
    }

    func testImportRemoteDoesNotDuplicateExistingRemoteID() throws {
        let repository = try TestStore.makeRepository()
        let remote = RemoteExpense(userId: 1, id: 10, title: "first", body: "body")
        try repository.importRemote([remote])
        try repository.importRemote([remote])
        XCTAssertEqual(try repository.all().filter { $0.remoteID == 10 }.count, 1)
    }

    func testImportRemoteHandlesEmptyArray() throws {
        let repository = try TestStore.makeRepository()
        try repository.importRemote([])
        XCTAssertTrue(try repository.all().isEmpty)
    }
}
