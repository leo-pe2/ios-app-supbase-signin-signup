import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var navigateToSuccess = false
    @State private var passwordStrength: PasswordStrength = .empty
    @Binding var isLoggedIn: Bool
    
    enum PasswordStrength: Int {
        case empty = 0
        case veryWeak = 1
        case weak = 2
        case medium = 3
        case strong = 4
        case veryStrong = 5
        
        var color: Color {
            switch self {
            case .empty: return Color.gray.opacity(0.3)
            case .veryWeak: return Color.red
            case .weak: return Color.orange
            case .medium: return Color.yellow
            case .strong: return Color.green
            case .veryStrong: return Color.green
            }
        }
        
        var label: String {
            switch self {
            case .empty: return "Enter a password"
            case .veryWeak: return "Very weak"
            case .weak: return "Weak"
            case .medium: return "Medium"
            case .strong: return "Strong"
            case .veryStrong: return "Very strong"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 50)
                    
                    VStack(spacing: 20) {
                        TextField("First Name", text: $firstName)
                            .textContentType(.givenName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            SecureField("Password", text: $password)
                                .textContentType(.newPassword)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .onChange(of: password) { oldValue, newValue in
                                    passwordStrength = calculatePasswordStrength(newValue)
                                }
                            
                            // Password strength meter
                            VStack(alignment: .leading, spacing: 4) {
                                // Seamless strength meter without gaps
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        // Background bar
                                        Rectangle()
                                            .frame(width: geometry.size.width, height: 6)
                                            .foregroundColor(Color.gray.opacity(0.3))
                                            .cornerRadius(3)
                                        
                                        // Colored strength indicator
                                        Rectangle()
                                            .frame(width: geometry.size.width * CGFloat(passwordStrength.rawValue) / 5.0, height: 6)
                                            .foregroundColor(passwordStrength.color)
                                            .cornerRadius(3)
                                    }
                                }
                                .frame(height: 6)
                                
                                Text(passwordStrength.label)
                                    .font(.caption)
                                    .foregroundColor(passwordStrength.color)
                            }
                            .padding(.horizontal, 4)
                        }
                        
                        Button(action: signUp) {
                            Text("Sign Up")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(isLoading || email.isEmpty || password.isEmpty || firstName.isEmpty)
                        .opacity((isLoading || email.isEmpty || password.isEmpty || firstName.isEmpty) ? 0.6 : 1)
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
                .navigationDestination(isPresented: $navigateToSuccess) {
                    SuccessSignUp(onContinue: {
                        isLoggedIn = true
                        dismiss()
                    })
                }
            }
            
        }
    }
    
    private func calculatePasswordStrength(_ password: String) -> PasswordStrength {
        if password.isEmpty {
            return .empty
        }
        
        var score = 0
        
        // Length check
        if password.count >= 8 {
            score += 1
        }
        if password.count >= 12 {
            score += 1
        }
        
        // Complexity checks
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasNumbers = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSpecialChars = password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_-+=<>?/[]{}|\\~")) != nil
        
        if hasUppercase {
            score += 1
        }
        if hasLowercase {
            score += 1
        }
        if hasNumbers {
            score += 1
        }
        if hasSpecialChars {
            score += 1
        }
        
        // Convert score to strength
        switch score {
        case 0...1:
            return .veryWeak
        case 2:
            return .weak
        case 3:
            return .medium
        case 4:
            return .strong
        default:
            return .veryStrong
        }
    }
    
    private func signUp() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                _ = try await AuthService.shared.signUp(email: email, password: password, firstName: firstName)
                
                await MainActor.run {
                    isLoading = false
                    navigateToSuccess = true
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
    SignUpView(isLoggedIn: .constant(false))
}
