import SwiftUI

@main
struct NeXusApp: App {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some Scene {
        WindowGroup {
            MainRouterView(isDarkMode: $isDarkMode)
                .frame(minWidth: 800, minHeight: 600)
        }
    }
}

struct MainRouterView: View {
    @State private var hasPasswordSet: Bool = UserDefaults.standard.string(forKey: "userPassword") != nil
    @State private var isLoggedIn: Bool = false
    @Binding var isDarkMode: Bool

    var body: some View {
        if isLoggedIn {
            ContentView(isDarkMode: $isDarkMode)
        } else if hasPasswordSet {
            PasswordView(isLoggedIn: $isLoggedIn, isDarkMode: $isDarkMode)
        } else {
            SetPasswordView(hasPasswordSet: $hasPasswordSet, isDarkMode: $isDarkMode)
        }
    }
}
