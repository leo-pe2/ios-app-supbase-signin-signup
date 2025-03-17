import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    private let supabaseURL = ""
    private let supabaseKey = ""
    
    lazy var client: SupabaseClient = {
        return SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseKey
        )
    }()
    
    private init() { }
}
