import SwiftUI

struct PasswordView: View {
    @State private var password = ""
    @State private var errorMessage: String?
    @Binding var isLoggedIn: Bool // Yeni eklenen değişken
    @Binding var isDarkMode: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .padding()

            Text("Şifrenizi Girin")
                .font(.title)

            SecureField("Şifre", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button("Giriş Yap") {
                if password == UserDefaults.standard.string(forKey: "userPassword") {
                    isLoggedIn = true // Şifre doğruysa girişi onayla
                } else {
                    errorMessage = "Şifre yanlış."
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
