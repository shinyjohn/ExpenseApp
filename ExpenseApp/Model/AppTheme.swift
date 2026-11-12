//
//  AppTheme.swift
//  ExpenseApp
//
//  Created by Santhana Shiny on 12/11/26.
//

import SwiftUI

enum ThemeMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    var id: String { rawValue }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum ThemeAccent: String, CaseIterable, Identifiable {
    case indigo = "Indigo"
    case blue = "Blue"
    case green = "Green"
    case orange = "Orange"
    var id: String { rawValue }

    var color: Color {
        switch self {
        case .indigo: .indigo
        case .blue: .blue
        case .green: .green
        case .orange: .orange
        }
    }
}
