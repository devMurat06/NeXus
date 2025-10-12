import SwiftUI

struct ContentView: View {
    @Binding var isDarkMode: Bool
    @AppStorage("selectedTheme") private var selectedThemeString: String = "light"
    
    var selectedTheme: Theme {
        Theme(rawValue: selectedThemeString) ?? .light
    }

    var body: some View {
        TabView {
            ToDoListView()
                .tabItem {
                    Label("Yapılacaklar", systemImage: "list.bullet")
                }
            
            NotesView()
                .tabItem {
                    Label("Notlar", systemImage: "note.text")
                }
            
            HabitTrackerView()
                .tabItem {
                    Label("Alışkanlıklar", systemImage: "calendar")
                }

            PomodoroTimerView()
                .tabItem {
                    Label("Zamanlayıcı", systemImage: "timer")
                }
            
            AnalyticsView()
                .tabItem {
                    Label("İstatistikler", systemImage: "chart.bar.fill")
                }

            BookRecommendationView()
                .tabItem {
                    Label("Kitap Önerisi", systemImage: "book")
                }
                
            ProfileView(isDarkMode: $isDarkMode)
                .tabItem {
                    Label("Profil", systemImage: "person.crop.circle")
                }
        }
        .accentColor(selectedTheme.accentColor) // Aksan rengi ayarlandı
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
    }
}
