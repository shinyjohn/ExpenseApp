//
//  Expense.swift
//  ExpenseApp
//
//  Created by Santhana Shiny on 12/11/26.
//

import Foundation
import SwiftData

@Model
final class Expense {
    var id: UUID
    var title: String
    var amount: Double
    var category: String
    var date: Date
    var note: String
    var remoteID: Int?

    init(id: UUID = UUID(), title: String, amount: Double, category: String,
         date: Date = .now, note: String = "", remoteID: Int? = nil) {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
        self.remoteID = remoteID
    }
}

enum ExpenseCategory: String, CaseIterable, Identifiable {
    case food = "Food"
    case transport = "Transport"
    case shopping = "Shopping"
    case bills = "Bills"
    case health = "Health"
    case entertainment = "Entertainment"
    case other = "Other"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .food: "fork.knife"
        case .transport: "car.fill"
        case .shopping: "bag.fill"
        case .bills: "doc.text.fill"
        case .health: "cross.case.fill"
        case .entertainment: "ticket.fill"
        case .other: "ellipsis.circle.fill"
        }
    }
}

