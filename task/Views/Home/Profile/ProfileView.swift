

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isLoggedIn: Bool
    @State private var isLoggingOut = false
    @State private var displayName: String = "User"  // Default value
    @State private var showManageAccount = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Profile image in HStack for left alignment
                HStack(alignment: .center) {
                    Image("profile")  // Using profile.png from assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .padding(.leading, 20)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(displayName)
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Button {
                            showManageAccount = true
                        } label: {
                            Text("Manage Account")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                    .padding(.trailing, 20)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Sign out button
                Button(action: logout) {
                    if isLoggingOut {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .tint(.white)
                    } else {
                        Text("Sign Out")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(width: 200)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image("close")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(size: 23))  // Custom point size
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadUserData()
            }
            .navigationDestination(isPresented: $showManageAccount) {
                ManageAccountView()
            }
        }
    }
    
    private func loadUserData() {
        Task {
            do {
                if let user = await AuthService.shared.getCurrentUser() {
                    print("User found: \(user)")
                    
                    // Access userMetadata directly since it's not optional
                    let metadata = user.userMetadata
                    print("User metadata: \(metadata)")
                    
                    // Try to get first_name from metadata
                    if let firstName = metadata["first_name"]?.stringValue {
                        print("First name found: \(firstName)")
                        await MainActor.run {
                            displayName = firstName
                        }
                    } else {
                        print("No first_name found in metadata")
                        // Try to get email as fallback
                        if let email = user.email {
                            print("Using email as fallback: \(email)")
                            await MainActor.run {
                                displayName = email
                            }
                        }
                    }
                } else {
                    print("No user found")
                }
            } catch {
                print("Error loading user data: \(error)")
            }
        }
    }
    
    private func logout() {
        isLoggingOut = true
        
        Task {
            let success = await AuthService.shared.signOut()
            
            await MainActor.run {
                isLoggingOut = false
                if success {
                    isLoggedIn = false
                }
            }
        }
    }
}

#Preview {
    ProfileView(isLoggedIn: .constant(true))
}

