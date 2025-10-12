import SwiftUI

struct SetPasswordView: View {
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String? = nil
    @Binding var hasPasswordSet: Bool
    @Binding var isDarkMode: Bool // Dark/Light mod desteği

    var body: some View {
        VStack(spacing: 20) {
            Text("Yeni Şifrenizi Belirleyin")
                .font(.title)

            SecureField("Yeni Şifre", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)

            SecureField("Şifreyi Onayla", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button("Şifreyi Kaydet") {
                if newPassword.isEmpty || confirmPassword.isEmpty {
                    errorMessage = "Lütfen tüm alanları doldurun."
                } else if newPassword != confirmPassword {
                    errorMessage = "Şifreler eşleşmiyor."
                } else {
                    UserDefaults.standard.set(newPassword, forKey: "userPassword")
                    hasPasswordSet = true
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
