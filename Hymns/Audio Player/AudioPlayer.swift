import AVFoundation
import Combine
import Prefire
import SwiftEventBus
import SwiftUI

// https://github.com/ChrisMash/AVPlayer-SwiftUI
// https://medium.com/flawless-app-stories/avplayer-swiftui-part-2-player-controls-c28b721e7e27
struct AudioPlayer: View {

    @ObservedObject private var viewModel: AudioPlayerViewModel
    @State private var showSpeedPicker: Bool = false

    init(viewModel: AudioPlayerViewModel) {
        self.viewModel = viewModel
    }

    fileprivate init(viewModel: AudioPlayerViewModel, showSpeedPicker: Bool) {
        self.viewModel = viewModel
        self._showSpeedPicker = State(initialValue: showSpeedPicker)
    }

    var body: some View {
        VStack {
            AudioSlider(viewModel: viewModel)
            HStack(spacing: 40) {
                if viewModel.showSpeedAdjuster {
                    // Toggle speed selection
                    Button(action: {
                        self.showSpeedPicker.toggle()
                    }, label: {
                        Image(systemName: "timer").font(.system(size: smallButtonSize)).foregroundColor(self.showSpeedPicker ? .accentColor : .primary)
                    })
                }

                // Reset button
                Button(action: {
                    self.viewModel.reset()
                }, label: {
                    Image(systemName: "backward.end.fill").font(.system(size: smallButtonSize)).foregroundColor(.primary)
                })

                // Rewind button
                Button(action: {
                    self.viewModel.rewind()
                }, label: {
                    Image(systemName: "backward.fill").font(.system(size: smallButtonSize)).foregroundColor(.primary)
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
                        Image(systemName: "pause.circle").font(.system(size: largeButtonSize)).foregroundColor(.primary)
                    } else {
                        // viewModel.playbackState == .stopped
                        Image(systemName: "play.circle").font(.system(size: largeButtonSize)).foregroundColor(.primary)
                    }
                })

                // Fast-forward button
                Button(action: {
                    self.viewModel.fastForward()
                }, label: {
                    Image(systemName: "forward.fill").font(.system(size: smallButtonSize)).foregroundColor(.primary)
                })

                // Repeat button
                Button(action: {
                    self.viewModel.toggleRepeat()
                }, label: {
                    Image(systemName: "repeat").font(.system(size: smallButtonSize)).foregroundColor(viewModel.shouldRepeat ? .accentColor : .primary)
                })
            }
            if showSpeedPicker {
                HStack(spacing: 30) {
                    Button(action: {
                        self.viewModel.decreaseSpeed()
                    }, label: {
                        Image(systemName: "minus").font(.system(size: smallButtonSize)).foregroundColor(.accentColor)
                    })
                    Text("Speed: \(self.viewModel.currentSpeed, specifier: "%.1f")x", comment: "Label for speed of currently playing song.")
                    Button(action: {
                        self.viewModel.increaseSpeed()
                    }, label: {
                        Image(systemName: "plus").font(.system(size: smallButtonSize)).foregroundColor(.accentColor)
                    })
                }.padding()
            }
        }.onAppear {
            // Player is up, so disable song swiping
            SwiftEventBus.post(DisplayHymnContainerViewModel.songSwipableEvent, sender: false)
            self.viewModel.load()
        }.onDisappear {
            // Player is gone, so disable song swiping
            SwiftEventBus.post(DisplayHymnContainerViewModel.songSwipableEvent, sender: true)
            // when this view isn't being shown anymore stop the player
            self.viewModel.pause()
        }
    }
}

#if DEBUG
struct AudioPlayer_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {

        let playingViewModel = AudioPlayerViewModel(url: URL(string: "url")!)
        playingViewModel.playbackState = .playing
        playingViewModel.songDuration = 100
        playingViewModel.currentTime = 50
        let currentlyPlaying = AudioPlayer(viewModel: playingViewModel)

        let stoppedViewModel = AudioPlayerViewModel(url: URL(string: "url")!)
        stoppedViewModel.playbackState = .stopped
        stoppedViewModel.songDuration = 500
        stoppedViewModel.shouldRepeat = true
        let stopped = AudioPlayer(viewModel: stoppedViewModel)

        let bufferingViewModel = AudioPlayerViewModel(url: URL(string: "url")!)
        bufferingViewModel.playbackState = .buffering
        bufferingViewModel.songDuration = 20
        let buffering = AudioPlayer(viewModel: bufferingViewModel)

        let noSpeedAdjusterViewModel = AudioPlayerViewModel(url: URL(string: "url")!)
        noSpeedAdjusterViewModel.showSpeedAdjuster = false
        let noSpeedAdjuster = AudioPlayer(viewModel: noSpeedAdjusterViewModel)

        let adjustingSpeedViewModel = AudioPlayerViewModel(url: URL(string: "url")!)
        adjustingSpeedViewModel.currentSpeed = 0.5
        let adjustingSpeed = AudioPlayer(viewModel: adjustingSpeedViewModel, showSpeedPicker: true)

        return Group {
            currentlyPlaying.previewDisplayName("currently playing")
            stopped.previewDisplayName("stopped")
            buffering.previewDisplayName("buffering")
            noSpeedAdjuster.previewDisplayName("no speed adjuster")
            adjustingSpeed.previewDisplayName("adjusting speed")
        }.padding().previewLayout(.sizeThatFits)
    }
}
#endif
