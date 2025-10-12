import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Şifre Değiştir")
                .font(.title)

            SecureField("Mevcut Şifre", text: $oldPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Yeni Şifre", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Yeni Şifreyi Onayla", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            if let successMessage = successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
            }
            
            HStack {
                Button("İptal") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Kaydet") {
                    changePassword()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
    
    private func changePassword() {
        guard let savedPassword = UserDefaults.standard.string(forKey: "userPassword") else {
            errorMessage = "Kayıtlı bir şifre bulunamadı."
            return
        }
        
        if oldPassword != savedPassword {
            errorMessage = "Mevcut şifre yanlış."
            return
        }
        
        if newPassword.isEmpty || confirmPassword.isEmpty {
            errorMessage = "Yeni şifre boş olamaz."
            return
        }
        
        if newPassword != confirmPassword {
            errorMessage = "Yeni şifreler eşleşmiyor."
            return
        }
        
        UserDefaults.standard.set(newPassword, forKey: "userPassword")
        successMessage = "Şifreniz başarıyla değiştirildi!"
        errorMessage = nil
        dismiss()
    }
}
