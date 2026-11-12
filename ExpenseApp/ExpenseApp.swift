//
//  ExpenseAppApp.swift
//  ExpenseApp
//
//  Created by Santhana Shiny on 12/11/26.
//

import SwiftUI
import SwiftData

@main
struct ExpenseApp: App {
    private let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Expense.self)
        } catch {
            fatalError("Unable to create SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .modelContainer(container)
        }
    }
}
