import Foundation
import Supabase
import Combine

class AuthService {
    static let shared = AuthService()
    
    private let supabase = SupabaseManager.shared.client
    
    private init() { }
    
    // Login with email and password
    func login(email: String, password: String) async throws -> User {
        do {
            let authResponse = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            return authResponse.user
        } catch {
            throw error
        }
    }
    
    // Sign up with email, password, and first name
    func signUp(email: String, password: String, firstName: String) async throws -> User {
        do {
            // Create user with email and password using proper AnyJSON format
            let userData: [String: AnyJSON] = ["first_name": try AnyJSON(firstName)]
            
            let authResponse = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: userData
            )
            
            return authResponse.user
        } catch {
            throw error
        }
    }
    
    // Check if user is authenticated
    func isAuthenticated() async -> Bool {
        do {
            // Access session without optional chaining since it's non-optional
            let session = try await supabase.auth.session
            return session.accessToken != nil
        } catch {
            return false
        }
    }
    
    // Sign out the current user
    func signOut() async -> Bool {
        do {
            try await supabase.auth.signOut()
            return true
        } catch {
            return false
        }
    }
    
    // Get current user
    func getCurrentUser() async -> User? {
        do {
            // Access session without optional chaining
            let session = try await supabase.auth.session
            return session.user
        } catch {
            return nil
        }
    }
}
