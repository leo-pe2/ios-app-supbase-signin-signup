import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    Text("Welcome Back")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 50)
                    
                    Text("Login to your account")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 20) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        Button(action: login) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .tint(.white)
                            } else {
                                Text("Login")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .opacity((isLoading || email.isEmpty || password.isEmpty) ? 0.6 : 1)
                    }
                    .padding(.horizontal)
                    .padding(.top, 30)
                    
                    Spacer()
                }
                .padding()
                .alert("Error", isPresented: $showError) {
                    Button("OK") { showError = false }
                } message: {
                    Text(errorMessage)
                }
            }
            
        }
    }
    
    private func login() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                _ = try await AuthService.shared.login(email: email, password: password)
                
                await MainActor.run {
                    isLoading = false
                    isLoggedIn = true
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
