import XCTest
import SwiftUI
@testable import ExpenseApp

final class ExpenseModelAndThemeTests: XCTestCase {
    func testExpenseInitializerUsesProvidedValues() {
        let id = UUID()
        let date = Date(timeIntervalSince1970: 123)
        let expense = Expense(id: id, title: "Rent", amount: 12_000, category: "Bills", date: date, note: "Monthly", remoteID: 42)
        XCTAssertEqual(expense.id, id)
        XCTAssertEqual(expense.title, "Rent")
        XCTAssertEqual(expense.amount, 12_000)
        XCTAssertEqual(expense.category, "Bills")
        XCTAssertEqual(expense.date, date)
        XCTAssertEqual(expense.note, "Monthly")
        XCTAssertEqual(expense.remoteID, 42)
    }

    func testExpenseInitializerDefaultsOptionalValues() {
        let expense = Expense(title: "Snacks", amount: 50, category: "Food")
        XCTAssertEqual(expense.note, "")
        XCTAssertNil(expense.remoteID)
    }

    func testEveryExpenseCategoryHasSymbol() {
        XCTAssertEqual(ExpenseCategory.allCases.count, 7)
        for category in ExpenseCategory.allCases {
            XCTAssertFalse(category.symbol.isEmpty)
            XCTAssertEqual(category.id, category.rawValue)
        }
    }

    func testThemeModeColorSchemeMapping() {
        XCTAssertNil(ThemeMode.system.preferredColorScheme)
        XCTAssertEqual(ThemeMode.light.preferredColorScheme, .light)
        XCTAssertEqual(ThemeMode.dark.preferredColorScheme, .dark)
    }

    func testThemeModeIdentityAndCases() {
        XCTAssertEqual(ThemeMode.allCases.map(\.rawValue), ["System", "Light", "Dark"])
        XCTAssertEqual(ThemeMode.system.id, "System")
        XCTAssertEqual(ThemeMode.light.id, "Light")
        XCTAssertEqual(ThemeMode.dark.id, "Dark")
    }
}
