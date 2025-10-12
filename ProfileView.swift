import SwiftUI
import AppKit

struct ProfileView: View {
    @AppStorage("firstName") private var firstName: String = ""
    @AppStorage("lastName") private var lastName: String = ""
    @AppStorage("age") private var age: String = ""
    @AppStorage("userPassword") private var userPassword: String = ""
    @Binding var isDarkMode: Bool
    @State private var showingChangePasswordAlert = false
    @State private var newPassword = ""
    @AppStorage("selectedTheme") private var selectedThemeString: String = "light"
    
    @State private var profileImage: NSImage? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Profilim")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            VStack {
                if let image = profileImage {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
            }
            .onTapGesture {
                selectImage()
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Kullanıcı Bilgileri")
                    .font(.headline)
                
                TextField("Adınız", text: $firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Soyadınız", text: $lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Yaşınız", text: $age)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                // .keyboardType(.numberPad) satırı kaldırıldı

                VStack(alignment: .leading) {
                    Text("Tema Seçimi")
                    Picker("Tema", selection: $selectedThemeString) {
                        ForEach(Theme.allCases) { theme in
                            Text(theme.themeName).tag(theme.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Toggle("Koyu Mod", isOn: $isDarkMode)
                    .padding(.top)
            }
            .padding()
            .background(Color(.textBackgroundColor))
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
            
            Button("Şifre Değiştir") {
                showingChangePasswordAlert = true
            }
            .alert("Şifrenizi Değiştirin", isPresented: $showingChangePasswordAlert) {
                SecureField("Yeni Şifre", text: $newPassword)
                Button("Tamam", action: changePassword)
                Button("İptal", role: .cancel) { }
            } message: {
                Text("Yeni şifrenizi girin.")
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
        .onAppear {
            loadImage()
        }
    }
    
    func selectImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK {
            if let url = panel.url, let image = NSImage(contentsOf: url) {
                profileImage = image
                saveImage(image: image)
            }
        }
    }
    
    func saveImage(image: NSImage) {
        if let tiffData = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            UserDefaults.standard.set(pngData, forKey: "profileImage")
        }
    }
    
    func loadImage() {
        if let savedImageData = UserDefaults.standard.data(forKey: "profileImage") {
            profileImage = NSImage(data: savedImageData)
        }
    }
    
    func changePassword() {
        if !newPassword.isEmpty {
            userPassword = newPassword
            newPassword = ""
        }
    }
}
