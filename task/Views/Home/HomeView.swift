import SwiftUI

struct HomeView: View {
    @Binding var isLoggedIn: Bool
    @State private var userName: String = "User"
    @State private var showingProfile = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome, \(userName)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                Spacer()
                
                Text("You are now logged in!")
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingProfile = true
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView(isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
            loadUserData()
        }
    }
    
    private func loadUserData() {
        Task {
            if let user = await AuthService.shared.getCurrentUser() {
                if let firstName = user.userMetadata["first_name"]?.stringValue {
                    await MainActor.run {
                        userName = firstName
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView(isLoggedIn: .constant(true))
}

