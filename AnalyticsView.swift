import SwiftUI

struct AnalyticsView: View {
    @State private var completedTasksCount: Int = 0
    @State private var totalTasksCount: Int = 0
    @State private var pomodoroSessionsCount: Int = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("İstatistikler")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "checklist.checked")
                    Text("Tamamlanan Görevler:")
                    Spacer()
                    Text("\(completedTasksCount) / \(totalTasksCount)")
                }
                
                HStack {
                    Image(systemName: "timer")
                    Text("Pomodoro Seansları:")
                    Spacer()
                    Text("\(pomodoroSessionsCount)")
                }
            }
            .padding()
            .background(Color(.textBackgroundColor))
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)

            Spacer()
        }
        .padding()
        .onAppear(perform: loadAnalyticsData)
    }
    
    private func loadAnalyticsData() {
        if let savedItems = UserDefaults.standard.data(forKey: "toDoListItems"),
           let decodedItems = try? JSONDecoder().decode([ToDoItem].self, from: savedItems) {
            totalTasksCount = decodedItems.count
            completedTasksCount = decodedItems.filter { $0.isCompleted }.count
        }
        
        // Pomodoro seansları için veri toplama özelliği
        // Şimdilik varsayılan bir değer kullanıyoruz. Gerçek bir senaryoda, PomodoroTimerView içinde sayacı kaydetmeniz gerekir.
        pomodoroSessionsCount = UserDefaults.standard.integer(forKey: "pomodoroSessions")
    }
}
