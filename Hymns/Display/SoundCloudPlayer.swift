import Lottie
import SwiftUI

struct SoundCloudPlayer: View {

    @ObservedObject private var viewModel: SoundCloudPlayerViewModel
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory

    init(viewModel: SoundCloudPlayerViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        if viewModel.showPlayer {
            return HStack(spacing: 0) {
                if !sizeCategory.isAccessibilityCategory() {
                    LottieView(fileName: "soundCloudPlayingAnimation", shouldLoop: true)
                        .frame(width: 30, height: 20, alignment: .center).padding()
                }
                Button(action: {
                    self.viewModel.openPlayer()
                }, label: {
                    MarqueeText(self.viewModel.title ?? NSLocalizedString("Now playing from SoundCloud", comment: "Indicator that a song from SoundCloud is currently playing."))
                })
                Button(action: {
                    self.viewModel.dismissPlayer()
                }, label: {
                    Image(systemName: "xmark")
                        .accessibility(label: Text("Stop music and close banner", comment: "A11y label for button dismissing the SoundCloud banner."))
                        .foregroundColor(.primary).padding()
                })
            }.transition(.opacity).animation(.easeOut).eraseToAnyView()
        } else {
            return EmptyView().eraseToAnyView()
        }
    }
}
