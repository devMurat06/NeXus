import Foundation

struct HabitItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var startDate: Date
    var completionDates: [Date] = []
    
    func isCompleted(on date: Date) -> Bool {
        return completionDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
    }
}
