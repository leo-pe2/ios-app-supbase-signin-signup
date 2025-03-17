import SwiftUI
import Lottie

struct WelcomeView: View {
    @State private var buttonOpacity: Double = 0
    @State private var navigateToLogin = false
    @State private var navigateToSignUp = false
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            // Centered Lottie animation
            LottieView(animationName: "welcome_lottie")
                .frame(width: 300, height: 300)
                .padding(.vertical, 40)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    navigateToLogin = true
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                
                Button(action: {
                    navigateToSignUp = true
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.black)
                        .cornerRadius(15)
                }
            }
            .padding(.bottom, 50)
            .opacity(buttonOpacity)
            .onAppear {
                withAnimation(.easeIn(duration: 2.0).delay(0.5)) {
                    buttonOpacity = 1.0
                }
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView(isLoggedIn: $isLoggedIn)
            }
            .navigationDestination(isPresented: $navigateToSignUp) {
                SignUpView(isLoggedIn: $isLoggedIn)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

struct LottieView: UIViewRepresentable {
    var animationName: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        
        // Try to load the animation from different locations
        var animation: LottieAnimation?
        
        // Method 1: Try to load directly by name
        animation = LottieAnimation.named(animationName)
        
        // Method 2: Try to load from Resources directory
        if animation == nil, 
           let resourcesPath = Bundle.main.path(forResource: animationName, ofType: "json", inDirectory: "Resources") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: resourcesPath))
                animation = try LottieAnimation.from(data: data)
            } catch {
                print("Failed to load animation from Resources: \(error)")
            }
        }
        
        // Method 3: Try to find the file anywhere in the bundle
        if animation == nil, 
           let filePath = Bundle.main.path(forResource: animationName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                animation = try LottieAnimation.from(data: data)
            } catch {
                print("Failed to load animation from path: \(error)")
            }
        }
        
        // If we have an animation, set it up
        if let animation = animation {
            animationView.animation = animation
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            animationView.play()
            
            // Add the animation view as a subview
            animationView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(animationView)
            
            // Set up constraints
            NSLayoutConstraint.activate([
                animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
                animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
            ])
        } else {
            print("Failed to load animation: \(animationName)")
            
            // Add a placeholder view with a label
            let label = UILabel()
            label.text = "Animation not found"
            label.textAlignment = .center
            label.textColor = .red
            
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
    }
}

#Preview {
    WelcomeView(isLoggedIn: .constant(false))
} 