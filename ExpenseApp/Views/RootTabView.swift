//
//  RootTabView.swift
//  ExpenseApp
//
//  Created by Santhana Shiny on 12/11/26.
//

import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var context
    @AppStorage("appearance.themeMode") private var themeMode = ThemeMode.system.rawValue
    @AppStorage("appearance.accentColor") private var accentColor = ThemeAccent.indigo.rawValue
    @State private var viewModel: ExpenseListViewModel?

    private var selectedTheme: ThemeMode {
        ThemeMode(rawValue: themeMode) ?? .system
    }

    private var selectedAccent: ThemeAccent {
        ThemeAccent(rawValue: accentColor) ?? .indigo
    }

    var body: some View {
        Group {
            if let viewModel {
                TabView {
                    DashboardView(viewModel: viewModel)
                        .tabItem { Label("Overview", systemImage: "chart.pie.fill") }
                    TransactionListView(viewModel: viewModel)
                        .tabItem { Label("Transactions", systemImage: "list.bullet.rectangle") }
                    AppearanceSettingsView()
                        .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                }
                .tint(selectedAccent.color)
            } else {
                ProgressView()
            }
        }
        .preferredColorScheme(selectedTheme.preferredColorScheme)
        .task {
            if viewModel == nil {
                let repository = ExpenseRepository(context: context)
                let model = ExpenseListViewModel(repository: repository, api: ExpenseAPI())
                model.load()
                viewModel = model
            }
        }
    }
}


#Preview {
    RootTabView()
}
