import SwiftUI
import AVFoundation
import Combine

// https://github.com/ChrisMash/AVPlayer-SwiftUI
// https://medium.com/flawless-app-stories/avplayer-swiftui-part-2-player-controls-c28b721e7e27
// TODO For some reason the combine stuff isn't working with our URLS that aren't straight up mp3 urls for example http://www.hymnal.net/en/hymn/h/894/f=mp3 that is coming from musicJson. However, the combine works when the url is a direct mp3 url such as https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3
struct AudioPlayer: View {

    @ObservedObject private var viewModel: AudioPlayerViewModel

    init(viewModel: AudioPlayerViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack(spacing: 40) {
            // Reset button
            Button(action: {
                guard let url = self.viewModel.url else {
                    return
                }
                let playerItem = AVPlayerItem(url: url)
                self.viewModel.player.replaceCurrentItem(with: playerItem)
                self.viewModel.play()
            }, label: {
                Image(systemName: "backward.end.fill").font(.subheadline).foregroundColor(.primary)
            })

            // Rewind button
            Button(action: {
                let rewoundTime = self.viewModel.convertFloatToCMTime(self.viewModel.playerCurrentTime - self.viewModel.seekDuration)
                self.viewModel.player.seek(to: rewoundTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            }, label: {
                Image(systemName: "backward.fill").font(.subheadline).foregroundColor(.primary)
            })

            // Play/Pause button
            Button(action: {
                switch self.viewModel.playbackState {
                case .buffering:
                    break
                case .playing:
                    self.viewModel.pause()
                case .stopped:
                    self.viewModel.play()
                }
            }, label: {
                if viewModel.playbackState == .buffering {
                    ActivityIndicator().font(.largeTitle).foregroundColor(.primary)
                } else if viewModel.playbackState == .playing {
                    Image(systemName: "pause.circle").font(.largeTitle).foregroundColor(.primary)
                } else {
                    // viewModel.playbackState == .stopped
                    Image(systemName: "play.circle").font(.largeTitle).foregroundColor(.primary)
                }
            })

            // Fast-forward button
            Button(action: {
                let fastForwardedTime = self.viewModel.convertFloatToCMTime(self.viewModel.playerCurrentTime + self.viewModel.seekDuration)
                self.viewModel.player.seek(to: fastForwardedTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            }, label: {
                Image(systemName: "forward.fill").font(.subheadline).foregroundColor(.primary)
            })

            // Repeat button
            Button(action: {
                self.viewModel.shouldRepeat.toggle()
            }, label: {
                Image(systemName: "repeat").font(.subheadline).foregroundColor(viewModel.shouldRepeat ? .accentColor : .primary)
            })
        }.onReceive(viewModel.timeObserver.publisher) { time in
                if time > 0 {
                    self.viewModel.playbackState = .playing
                }
        }.onAppear {
            guard let url = self.viewModel.url else {
                return
            }
            let playerItem = AVPlayerItem(url: url)
            self.viewModel.player.replaceCurrentItem(with: playerItem)
        }.onDisappear {
            // When this View isn't being shown anymore stop the player
            self.viewModel.player.replaceCurrentItem(with: nil)
        }
    }
}

#if DEBUG
struct AudioView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!)
        return Group {
            AudioPlayer(viewModel: viewModel).previewLayout(.sizeThatFits)
        }
    }
}
#endif
