import SwiftUI

enum Theme: String, CaseIterable, Identifiable {
    case light, dark, neon, forest

    var id: String { self.rawValue }
    
    var themeName: String {
        switch self {
        case .light: return "Açık"
        case .dark: return "Koyu"
        case .neon: return "Neon"
        case .forest: return "Orman"
        }
    }

    var primaryColor: Color {
        switch self {
        case .light: return .black
        case .dark: return .white
        case .neon: return .cyan
        case .forest: return Color(red: 0.1, green: 0.5, blue: 0.2)
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .light: return .gray
        case .dark: return .gray
        case .neon: return .purple
        case .forest: return Color(red: 0.4, green: 0.7, blue: 0.3)
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .light: return Color(white: 0.95)
        case .dark: return Color(white: 0.1)
        case .neon: return Color(white: 0.1)
        case .forest: return Color(red: 0.05, green: 0.2, blue: 0.1)
        }
    }
    
    var accentColor: Color {
        switch self {
        case .light: return .blue
        case .dark: return .blue
        case .neon: return .pink
        case .forest: return Color(red: 0.2, green: 0.6, blue: 0.3)
        }
    }
}
