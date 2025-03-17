

import SwiftUI

struct ManageAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Email section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Address")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    if isLoading {
                        HStack {
                            ProgressView()
                                .padding(.trailing, 8)
                            Text("Loading...")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text(email)
                            .font(.body)
                            .fontWeight(.medium)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Account Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                loadUserData()
            }
        }
    }
    
    private func loadUserData() {
        isLoading = true
        
        Task {
            if let user = await AuthService.shared.getCurrentUser() {
                if let userEmail = user.email {
                    await MainActor.run {
                        email = userEmail
                        isLoading = false
                    }
                } else {
                    await MainActor.run {
                        email = "No email found"
                        isLoading = false
                    }
                }
            } else {
                await MainActor.run {
                    email = "Not logged in"
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    ManageAccountView()
}

