import SwiftUI

struct HabitTrackerView: View {
    @State private var habits: [HabitItem] = []
    @State private var newHabitTitle: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Alışkanlık Takibi")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            HStack(spacing: 15) {
                TextField("Yeni alışkanlık ekle...", text: $newHabitTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: addHabit) {
                    Image(systemName: "plus.circle.fill")
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal)
            
            Divider()
            
            VStack {
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.borderless)
                    
                    Text(monthYearString(from: selectedDate))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.vertical, 10)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 5) {
                    ForEach(daysOfWeek(), id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 5) {
                    ForEach(datesInMonth(from: selectedDate), id: \.self) { date in
                        if Calendar.current.component(.month, from: date) == Calendar.current.component(.month, from: selectedDate) {
                            DayView(date: date, habits: $habits)
                        } else {
                            Text("")
                        }
                    }
                }
            }
            .padding()
            .background(Color(.textBackgroundColor))
            .cornerRadius(10)
            
            List {
                ForEach(habits) { habit in
                    HStack {
                        Text(habit.title)
                        Spacer()
                    }
                }
                .onDelete(perform: deleteHabit)
            }
        }
        .onAppear(perform: loadHabits)
    }
    
    private func addHabit() {
        if !newHabitTitle.isEmpty {
            let newHabit = HabitItem(title: newHabitTitle, startDate: Date())
            habits.append(newHabit)
            newHabitTitle = ""
            saveHabits()
        }
    }
    
    private func deleteHabit(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
        saveHabits()
    }
    
    private func loadHabits() {
        if let savedHabits = UserDefaults.standard.data(forKey: "habitItems") {
            if let decodedHabits = try? JSONDecoder().decode([HabitItem].self, from: savedHabits) {
                habits = decodedHabits
            }
        }
    }
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: "habitItems")
        }
    }
    
    private func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    private func daysOfWeek() -> [String] {
        return ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]
    }
    
    private func datesInMonth(from date: Date) -> [Date] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        guard let startOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return []
        }
        
        var dates: [Date] = []
        var currentDate = startOfMonth
        
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let offset = firstWeekday == 1 ? 6 : firstWeekday - 2
        
        if offset > 0 {
            for i in 0..<offset {
                if let date = calendar.date(byAdding: .day, value: -offset + i, to: startOfMonth) {
                    dates.append(date)
                }
            }
        }
        
        while currentDate <= endOfMonth {
            dates.append(currentDate)
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDay
        }
        
        let remainingDays = 42 - dates.count
        if remainingDays > 0 {
            for i in 1...remainingDays {
                if let date = calendar.date(byAdding: .day, value: i, to: endOfMonth) {
                    dates.append(date)
                }
            }
        }
        
        return dates
    }
}

struct DayView: View {
    let date: Date
    @Binding var habits: [HabitItem]
    
    var body: some View {
        VStack {
            Text(String(Calendar.current.component(.day, from: date)))
                .font(.body)
                .padding(5)
                .frame(maxWidth: .infinity)
                .background(habitStatusColor)
                .cornerRadius(5)
        }
        .onTapGesture {
            toggleHabitsForDate()
        }
    }
    
    private var habitStatusColor: Color {
        let allHabitsCompleted = habits.allSatisfy { $0.isCompleted(on: date) }
        let anyHabitCompleted = habits.contains { $0.isCompleted(on: date) }
        
        if allHabitsCompleted && !habits.isEmpty {
            return .green.opacity(0.8)
        } else if anyHabitCompleted {
            return .yellow.opacity(0.8)
        } else {
            return .secondary.opacity(0.2)
        }
    }
    
    private func toggleHabitsForDate() {
        for i in 0..<habits.count {
            if habits[i].isCompleted(on: date) {
                habits[i].completionDates.removeAll { Calendar.current.isDate($0, inSameDayAs: date) }
            } else {
                habits[i].completionDates.append(date)
            }
        }
    }
}
