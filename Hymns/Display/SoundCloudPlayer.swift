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

#if DEBUG
struct SoundCloudPlayer_Previews: PreviewProvider {
    static var previews: some View {
        var published = Published<String?>(initialValue: nil)

        let emptyViewModel = SoundCloudPlayerViewModel(dialogModel: .constant(nil), title: published.projectedValue)
        emptyViewModel.showPlayer = false
        let empty = SoundCloudPlayer(viewModel: emptyViewModel)

        let playerViewModel = SoundCloudPlayerViewModel(dialogModel: .constant(nil), title: published.projectedValue)
        playerViewModel.showPlayer = true
        let player = SoundCloudPlayer(viewModel: playerViewModel)

        return Group {
            empty.previewDisplayName("empty")
            player.previewDisplayName("player")
        }
    }
}
#endif
