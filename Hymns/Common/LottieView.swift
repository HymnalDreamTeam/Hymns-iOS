import Lottie
import SwiftUI

// Implemented using https://www.youtube.com/watch?v=fVehE3Jf7K0
struct LottieView: UIViewRepresentable {

    let fileName: String
    let loop: Bool

    init(fileName: String, shouldLoop: Bool = false) {
        self.fileName = fileName
        self.loop = shouldLoop
    }

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()
        let animation = LottieAnimation.named(fileName)
        let animationView = LottieAnimationView()
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loop ? .loop : .playOnce
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)])

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<LottieView>) {
    }
}

#Preview("firstLaunchAnimation") {
    LottieView(fileName: "firstLaunchAnimation", shouldLoop: true)
        .prefireIgnored()
}

#Preview("soundCloudPlayingAnimation") {
    LottieView(fileName: "soundCloudPlayingAnimation", shouldLoop: true)
        .prefireIgnored()
}
