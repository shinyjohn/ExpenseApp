//
//  AppearanceSettingsView.swift
//  ExpenseApp
//
//  Created by Santhana Shiny on 12/11/26.
//

import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage("appearance.themeMode") private var themeMode = ThemeMode.system.rawValue
    @AppStorage("appearance.accentColor") private var accentColor = ThemeAccent.indigo.rawValue

    private var selectedAccent: ThemeAccent {
        ThemeAccent(rawValue: accentColor) ?? .indigo
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Appearance", selection: $themeMode) {
                        ForEach(ThemeMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("App appearance")
                } header: {
                    Text("Theme")
                } footer: {
                    Text("System follows your iPhone appearance setting. Light and Dark force the selected appearance throughout the app.")
                }

            }
            .navigationTitle("Appearance")
        }
    }
}


#Preview {
    AppearanceSettingsView()
}
