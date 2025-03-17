import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var isCheckingAuth = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Show welcome view if not logged in
                if !isLoggedIn {
                    WelcomeView(isLoggedIn: $isLoggedIn)
                } else {
                    // Show home view if logged in
                    HomeView(isLoggedIn: $isLoggedIn)
                }
                
                // Show loading indicator while checking auth
                if isCheckingAuth {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
        .onAppear {
            checkAuthStatus()
        }
        .onChange(of: isLoggedIn) { oldValue, newValue in
            // Needed to refresh UI when login state changes
        }
    }
    
    private func checkAuthStatus() {
        Task {
            let isAuthenticated = await AuthService.shared.isAuthenticated()
            await MainActor.run {
                isLoggedIn = isAuthenticated
                isCheckingAuth = false
            }
        }
    }
}

#Preview {
    ContentView()
} 
