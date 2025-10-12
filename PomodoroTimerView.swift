import SwiftUI

struct PomodoroTimerView: View {
    @State private var focusTime: Int = 25
    @State private var breakTime: Int = 5
    @State private var timeRemaining: Int = 25 * 60
    @State private var isRunning: Bool = false
    @State private var isFocusing: Bool = true
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            Text(isFocusing ? "Odaklanma Zamanı" : "Mola Zamanı")
                .font(.title)
                .fontWeight(.bold)

            Text(timeString(time: timeRemaining))
                .font(.system(size: 72, weight: .bold, design: .monospaced))
                .padding()
                .background(Color(.textBackgroundColor))
                .cornerRadius(15)

            HStack(spacing: 20) {
                Button(isRunning ? "Durdur" : "Başlat") {
                    if isRunning {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Sıfırla") {
                    resetTimer()
                }
                .buttonStyle(.bordered)
            }
        }
        .onReceive(timer) { _ in
            if isRunning && timeRemaining > 0 {
                timeRemaining -= 1
            } else if isRunning && timeRemaining == 0 {
                toggleTimer()
            }
        }
        .onAppear {
            stopTimer()
        }
        .padding()
    }

    private func startTimer() {
        isRunning = true
    }

    private func stopTimer() {
        isRunning = false
    }

    private func resetTimer() {
        stopTimer()
        isFocusing = true
        timeRemaining = focusTime * 60
    }

    private func toggleTimer() {
        isFocusing.toggle()
        if isFocusing {
            timeRemaining = focusTime * 60
        } else {
            timeRemaining = breakTime * 60
        }
    }

    private func timeString(time: Int) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}
