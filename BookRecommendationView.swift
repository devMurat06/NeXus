import SwiftUI

struct Book: Identifiable, Codable {
    // JSON'da id zorunlu değil; decode sırasında otomatik üretilecek
    let id: UUID
    var title: String
    var summary: String
    var moods: [String]
    var genres: [String]
    
    enum CodingKeys: String, CodingKey {
        case title, summary, moods, genres
    }
    
    init(id: UUID = UUID(), title: String, summary: String, moods: [String] = [], genres: [String] = []) {
        self.id = id
        self.title = title
        self.summary = summary
        self.moods = moods
        self.genres = genres
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.summary = try container.decode(String.self, forKey: .summary)
        self.moods = (try? container.decode([String].self, forKey: .moods)) ?? []
        self.genres = (try? container.decode([String].self, forKey: .genres)) ?? []
    }
}

final class BookRepository {
    static let shared = BookRepository()
    private(set) var allBooks: [Book] = []
    private var isLoaded = false
    
    private init() {}
    
    func loadIfNeeded() {
        guard !isLoaded else { return }
        guard let url = Bundle.main.url(forResource: "Books", withExtension: "json") else {
            // Books.json bulunamazsa, minimum bir fallback kitap verisi sunalım
            self.allBooks = [
                Book(title: "Dune", summary: "Çölde geçen güç ve kehanet mücadelesi.", moods: ["düşünceli"], genres: ["bilim kurgu"])
            ]
            isLoaded = true
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Book].self, from: data)
            self.allBooks = decoded
            self.isLoaded = true
        } catch {
            // Decode hatasında da küçük bir fallback sunalım
            self.allBooks = [
                Book(title: "Dune", summary: "Çölde geçen güç ve kehanet mücadelesi.", moods: ["düşünceli"], genres: ["bilim kurgu"])
            ]
            self.isLoaded = true
        }
    }
    
    func recommendations(mood: String, genre: String, limit: Int = 250) -> [Book] {
        loadIfNeeded()
        
        let normalizedMood = mood.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedGenre = genre.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Her iki seçim de boşsa ilk 250 kitabı döndür
        if normalizedMood.isEmpty && normalizedGenre.isEmpty {
            return Array(allBooks.prefix(limit))
        }
        
        // Sadece mood seçilmişse
        if !normalizedMood.isEmpty && normalizedGenre.isEmpty {
            let filtered = allBooks.filter { $0.moods.map { $0.lowercased() }.contains(normalizedMood) }
            return filtered.isEmpty ? Array(allBooks.prefix(limit)) : Array(filtered.prefix(limit))
        }
        
        // Sadece genre seçilmişse
        if normalizedMood.isEmpty && !normalizedGenre.isEmpty {
            let filtered = allBooks.filter { $0.genres.map { $0.lowercased() }.contains(normalizedGenre) }
            return filtered.isEmpty ? Array(allBooks.prefix(limit)) : Array(filtered.prefix(limit))
        }
        
        // İkisi de seçilmişse kesişimi al
        let filtered = allBooks.filter {
            $0.moods.map { $0.lowercased() }.contains(normalizedMood)
            && $0.genres.map { $0.lowercased() }.contains(normalizedGenre)
        }
        if !filtered.isEmpty {
            return Array(filtered.prefix(limit))
        }
        
        // Kesişim yoksa en yakın eşleşme (önce türe göre, sonra mood'a göre)
        let genreOnly = allBooks.filter { $0.genres.map { $0.lowercased() }.contains(normalizedGenre) }
        if !genreOnly.isEmpty { return Array(genreOnly.prefix(limit)) }
        
        let moodOnly = allBooks.filter { $0.moods.map { $0.lowercased() }.contains(normalizedMood) }
        if !moodOnly.isEmpty { return Array(moodOnly.prefix(limit)) }
        
        // Tamamen boşsa genel liste
        return Array(allBooks.prefix(limit))
    }
}

struct BookRecommendationView: View {
    // Genişletilmiş kategoriler (JSON'da geçen tüm etiketlerle uyumlu)
    private let availableMoods = [
        "mutlu", "düşünceli", "gergin", "hüzünlü",
        "enerjik", "romantik", "ilhamlı", "sakin",
        "meraklı"
    ]
    
    private let availableGenres = [
        "fantastik", "bilim kurgu", "macera", "klasik", "dram", "polisiye",
        "gerilim", "tarihi", "psikoloji", "kişisel gelişim",
        "korku", "öykü", "deneme",
        // JSON'da kullanılan ek etiketler:
        "distopya", "felsefe", "bilim", "absürd"
    ]
    
    @State private var selectedMood: String = ""
    @State private var selectedGenre: String = ""
    @State private var recommendedBooks: [Book] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Kitap Önerisi Alın")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Şu anki ruh haliniz:")
                        .font(.headline)
                    Picker("Ruh Hali", selection: $selectedMood) {
                        Text("Seçiniz").tag("")
                        ForEach(availableMoods, id: \.self) { mood in
                            Text(mood.capitalized).tag(mood)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Genellikle sevdiğiniz tür:")
                        .font(.headline)
                    Picker("Tür", selection: $selectedGenre) {
                        Text("Seçiniz").tag("")
                        ForEach(availableGenres, id: \.self) { genre in
                            Text(genre.capitalized).tag(genre)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Button("Kitap Önerisi Al") {
                    recommendedBooks = BookRepository.shared.recommendations(
                        mood: selectedMood,
                        genre: selectedGenre,
                        limit: 250
                    )
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 10)
            }
            .padding()
            .background(Color(.textBackgroundColor))
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
            
            if !recommendedBooks.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Önerilerimiz (\(recommendedBooks.count)):")
                            .font(.headline)
                        Spacer()
                        Button {
                            recommendedBooks.removeAll()
                        } label: {
                            Label("Temizle", systemImage: "xmark.circle")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            ForEach(recommendedBooks) { book in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(book.title)
                                        .font(.headline)
                                    Text(book.summary)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.textBackgroundColor))
                                .cornerRadius(8)
                                .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.textBackgroundColor))
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Kitap Önerisi")
    }
}
