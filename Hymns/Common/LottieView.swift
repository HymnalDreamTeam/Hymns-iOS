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
        let animation = Animation.named(fileName)
        let animationView = AnimationView()
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

#if DEBUG
struct LottieView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LottieView(fileName: "firstLaunchAnimation", shouldLoop: true)
            LottieView(fileName: "soundCloudPlayingAnimation", shouldLoop: true)
        }
    }
}
#endif
