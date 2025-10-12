import SwiftUI
import UniformTypeIdentifiers

// Yapılacaklar listesi öğesini temsil eden yapı
struct ToDoItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    var tags: [String] = []
    var status: KanbanStatus = .todo
}

struct ToDoListView: View {
    @State private var items = [ToDoItem]()
    @State private var newItemTitle: String = ""
    @State private var searchText: String = ""
    @State private var columns = [
        KanbanColumn(status: .todo),
        KanbanColumn(status: .inProgress),
        KanbanColumn(status: .done)
    ]
    @State private var draggedItem: ToDoItem?

    var filteredItems: [ToDoItem] {
        if searchText.isEmpty {
            return items
        } else {
            let lowercasedSearchText = searchText.lowercased()
            return items.filter { item in
                let titleMatches = item.title.lowercased().contains(lowercasedSearchText)
                let tagsMatch = item.tags.joined(separator: " ").lowercased().contains(lowercasedSearchText)
                return titleMatches || tagsMatch
            }
        }
    }

    var body: some View {
        VStack {
            HStack(spacing: 15) {
                TextField("Yeni yapılacak...", text: $newItemTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: addItem) {
                    Image(systemName: "plus.circle.fill")
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal)
            .padding(.top)

            Divider()

            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach(columns) { column in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(column.status.rawValue)
                                .font(.headline)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.controlAccentColor).opacity(0.2))
                                .cornerRadius(8)
                            
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(filteredItems.filter { $0.status == column.status }) { item in
                                        VStack(alignment: .leading) {
                                            Text(item.title)
                                                .font(.body)
                                                .strikethrough(item.isCompleted)
                                            
                                            if !item.tags.isEmpty {
                                                Text(item.tags.joined(separator: ", "))
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.textBackgroundColor))
                                        .cornerRadius(8)
                                        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
                                        .onDrag {
                                            self.draggedItem = item
                                            return NSItemProvider(object: item.title as NSString)
                                        }
                                        .onTapGesture(count: 2) {
                                            // Göreve çift tıklayarak tamamlandı olarak işaretle
                                            if let index = items.firstIndex(where: { $0.id == item.id }) {
                                                items[index].isCompleted.toggle()
                                                saveItems()
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(width: 300)
                            .onDrop(of: [UTType.text], delegate: ToDoListDropDelegate(items: $items, currentStatus: column.status, draggedItem: $draggedItem, saveAction: saveItems))
                            .background(Color(.windowBackgroundColor))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                TextField("Ara...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
            }
        }
        .navigationTitle("Yapılacaklar")
        .onAppear(perform: loadItems)
    }

    private func addItem() {
        if !newItemTitle.isEmpty {
            let tags = newItemTitle
                .lowercased()
                .split(separator: " ")
                .map { String($0) }
                .filter { !$0.isEmpty }
                
            let newItem = ToDoItem(title: newItemTitle, tags: tags, status: .todo)
            items.append(newItem)
            newItemTitle = ""
            saveItems()
        }
    }
    
    private func loadItems() {
        if let savedItems = UserDefaults.standard.data(forKey: "toDoListItems") {
            if let decodedItems = try? JSONDecoder().decode([ToDoItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }
        items = []
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "toDoListItems")
        }
    }
}

// Sürükle-bırak için DropDelegate
struct ToDoListDropDelegate: DropDelegate {
    @Binding var items: [ToDoItem]
    let currentStatus: KanbanStatus
    @Binding var draggedItem: ToDoItem?
    var saveAction: () -> Void // Kaydetme fonksiyonu eklendi
    
    func performDrop(info: DropInfo) -> Bool {
        if let draggedItem = draggedItem {
            if let index = items.firstIndex(where: { $0.id == draggedItem.id }) {
                items[index].status = currentStatus
                // Görev "Tamamlandı" sütununa taşındığında isCompleted değerini true yap
                if currentStatus == .done {
                    items[index].isCompleted = true
                } else {
                    items[index].isCompleted = false
                }
                saveAction() // Kaydetme fonksiyonu çağrıldı
                return true
            }
        }
        return false
    }
}
