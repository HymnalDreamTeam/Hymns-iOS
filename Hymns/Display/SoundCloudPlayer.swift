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
                    MarqueeText(self.viewModel.title ?? NSLocalizedString("Now playing from SoundCloud", comment: "Indicator that a song from SoundCloud is currently playing"))
                })
                Button(action: {
                    self.viewModel.dismissPlayer()
                }, label: {
                    Image(systemName: "xmark").accessibility(label: Text("Close", comment: "Close the SoundCloud mini player.")).foregroundColor(.primary).padding()
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
        let viewModel = SoundCloudPlayerViewModel(dialogModel: .constant(nil), title: published.projectedValue)
        viewModel.showPlayer = true
        return SoundCloudPlayer(viewModel: viewModel).toPreviews()
    }
}
#endif
