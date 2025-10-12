import SwiftUI

enum KanbanStatus: String, Codable, CaseIterable {
    case todo = "Yapılacaklar"
    case inProgress = "Devam Ediyor"
    case done = "Tamamlandı"
}

struct KanbanColumn: Identifiable {
    let id = UUID()
    let status: KanbanStatus
}
