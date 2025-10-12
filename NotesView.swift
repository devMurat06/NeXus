import SwiftUI

// Not bloğunu temsil eden yapı
struct NoteItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String = "Başlıksız Not"
    var content: String
    var isBold: Bool = false
    var isItalic: Bool = false
    var isUnderlined: Bool = false
    var tags: [String] = []

    static func == (lhs: NoteItem, rhs: NoteItem) -> Bool {
        return lhs.id == rhs.id
    }
}

struct NotesView: View {
    @State private var notes = [NoteItem]()
    @State private var showingNoteSheet = false
    @State private var selectedNote: NoteItem? = nil
    @State private var searchText: String = ""

    private let columns = [
        GridItem(.adaptive(minimum: 250), spacing: 20)
    ]

    var filteredNotes: [NoteItem] {
        if searchText.isEmpty {
            return notes
        } else {
            let lowercasedSearchText = searchText.lowercased()
            return notes.filter { note in
                let titleMatches = note.title.lowercased().contains(lowercasedSearchText)
                let contentMatches = note.content.lowercased().contains(lowercasedSearchText)
                let tagsString = note.tags.joined(separator: " ").lowercased()
                let tagsMatch = tagsString.contains(lowercasedSearchText)
                return titleMatches || contentMatches || tagsMatch
            }
        }
    }

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredNotes) { note in
                        NoteCard(note: note)
                            .onTapGesture {
                                selectedNote = note
                                showingNoteSheet = true
                            }
                            .contextMenu {
                                Button("Sil", role: .destructive) {
                                    deleteNote(note)
                                }
                            }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Notlarım")
        .background(Color(.windowBackgroundColor))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    selectedNote = nil
                    showingNoteSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                }
            }
            ToolbarItem(placement: .automatic) {
                TextField("Ara...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
            }
        }
        .onAppear(perform: loadNotes)
        .sheet(isPresented: $showingNoteSheet) {
            NoteEditorView(notes: $notes, selectedNote: $selectedNote)
        }
    }

    private func loadNotes() {
        if let savedNotes = UserDefaults.standard.data(forKey: "notes") {
            if let decodedNotes = try? JSONDecoder().decode([NoteItem].self, from: savedNotes) {
                notes = decodedNotes
                return
            }
        }
    }
    
    private func deleteNote(_ note: NoteItem) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes.remove(at: index)
            saveNotesToDefaults()
        }
    }
    
    private func saveNotesToDefaults() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: "notes")
        }
    }
}

// Notu düzenleme sayfası
struct NoteEditorView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var notes: [NoteItem]
    @Binding var selectedNote: NoteItem?
    
    @State private var noteTitle: String = ""
    @State private var noteContent: String = ""
    @State private var tagsText: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text(selectedNote == nil ? "Yeni Not Oluştur" : "Notu Düzenle")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("Başlık", text: $noteTitle)
                .font(.title3)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            HStack(spacing: 15) {
                // Not düzenleme alanını Markdown önizleme ile ikiye böldük
                VStack(alignment: .leading) {
                    Text("Markdown İçeriği")
                        .font(.headline)
                    TextEditor(text: $noteContent)
                        .frame(minHeight: 300, maxHeight: .infinity)
                        .padding(10)
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                }

                VStack(alignment: .leading) {
                    Text("Önizleme")
                        .font(.headline)
                    // Markdown içeriğini düz metin olarak gösteriyoruz
                    ScrollView {
                        Text(noteContent)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: 300, maxHeight: .infinity)
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                }
            }
            .padding(.horizontal)

            TextField("Etiketler (virgülle ayırın)", text: $tagsText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                Button("İptal") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Kaydet") {
                    saveNote()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(minWidth: 800, minHeight: 800)
        .onAppear {
            if let selected = selectedNote {
                noteTitle = selected.title
                noteContent = selected.content
                tagsText = selected.tags.joined(separator: ", ")
            }
        }
    }

    private func saveNote() {
        let newTags = tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        if let selected = selectedNote {
            if let index = notes.firstIndex(where: { $0.id == selected.id }) {
                notes[index].title = noteTitle
                notes[index].content = noteContent
                notes[index].tags = newTags
            }
        } else {
            if !noteContent.isEmpty {
                let newNote = NoteItem(title: noteTitle, content: noteContent, tags: newTags)
                notes.append(newNote)
            }
        }
        saveNotesToDefaults()
        dismiss()
    }

    private func saveNotesToDefaults() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: "notes")
        }
    }
}

// Ana sayfada gösterilecek not kartı
struct NoteCard: View {
    let note: NoteItem

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(note.title)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
            
            // Markdown önizlemesi için özel bir fonksiyon kullanabilir veya
            // basitçe düz metni gösterebiliriz
            Text(note.content)
                .font(.body)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            if !note.tags.isEmpty {
                Text(note.tags.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding()
        .frame(minHeight: 150)
        .background(Color(.textBackgroundColor))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}
