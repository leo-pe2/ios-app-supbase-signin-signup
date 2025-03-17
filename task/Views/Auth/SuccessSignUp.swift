

import SwiftUI
import Lottie

struct SuccessSignUp: View {
    var onContinue: () -> Void
    @State private var hasRedirected = false
    
    init(onContinue: @escaping () -> Void = {}) {
        self.onContinue = onContinue
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Success!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Your account has been created.")
                .font(.system(size: 18))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            CheckmarkAnimationView(animationName: "check", onComplete: {
                // Only redirect once
                if !hasRedirected {
                    hasRedirected = true
                    // Add a small delay before redirecting
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onContinue()
                    }
                }
            })
            .frame(width: 200, height: 200)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

struct CheckmarkAnimationView: UIViewRepresentable {
    var animationName: String
    var loopMode: LottieLoopMode = .playOnce
    var onComplete: () -> Void
    
    init(animationName: String, loopMode: LottieLoopMode = .playOnce, onComplete: @escaping () -> Void = {}) {
        self.animationName = animationName
        self.loopMode = loopMode
        self.onComplete = onComplete
    }
    
    func makeUIView(context: UIViewRepresentableContext<CheckmarkAnimationView>) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(animation: LottieAnimation.named(animationName))
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        
        // Play animation only up to 85% progress
        animationView.play(fromProgress: 0, toProgress: 0.81, completion: { finished in
            if finished {
                DispatchQueue.main.async {
                    self.onComplete()
                }
            }
        })
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<CheckmarkAnimationView>) {
        // Update view if needed
    }
}

struct SuccessSignUp_Previews: PreviewProvider {
    static var previews: some View {
        SuccessSignUp()
    }
}

