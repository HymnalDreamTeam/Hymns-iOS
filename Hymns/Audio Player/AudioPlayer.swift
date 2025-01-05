import AVFoundation
import Combine
import PreviewSnapshots
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
struct AudioView_Previews: PreviewProvider {

    struct PreviewState: NamedPreviewState {
        let name: String
        let playbackState: PlaybackState
        let showSpeedAdjuster: Bool
        let shouldRepeat: Bool
        let currentSpeed: Float
        let currentTime: TimeInterval
        let songDuration: TimeInterval?

        init(name: String,
             playbackState: PlaybackState = .stopped,
             showSpeedAdjuster: Bool = true,
             shouldRepeat: Bool = false,
             currentSpeed: Float = 1.0,
             currentTime: TimeInterval = 0,
             songDuration: TimeInterval? = nil) {
            self.name = name
            self.playbackState = playbackState
            self.showSpeedAdjuster = showSpeedAdjuster
            self.shouldRepeat = shouldRepeat
            self.currentSpeed = currentSpeed
            self.currentTime = currentTime
            self.songDuration = songDuration
        }
    }

    static var previews: some View {
        snapshots.previews
    }

    static var snapshots: PreviewSnapshots<PreviewState> {
        PreviewSnapshots(
            states: [
                .init(name: "currently playing",
                      playbackState: .playing,
                      currentTime: 50,
                      songDuration: 100),
                .init(name: "stopped",
                      playbackState: .stopped,
                      shouldRepeat: true,
                      songDuration: 500),
                .init(name: "buffering",
                      playbackState: .buffering,
                      songDuration: 20),
                .init(name: "no speed adjuster",
                      showSpeedAdjuster: false)
            ],
            configure: { state in
                let viewModel = AudioPlayerViewModel(url: URL(string: "url")!)
                viewModel.playbackState = state.playbackState
                viewModel.showSpeedAdjuster = state.showSpeedAdjuster
                viewModel.shouldRepeat = state.shouldRepeat
                viewModel.currentSpeed = state.currentSpeed
                viewModel.currentTime = state.currentTime
                viewModel.songDuration = state.songDuration
                return AudioPlayer(viewModel: viewModel)
                    .padding()
                    .previewLayout(.sizeThatFits)
            }
        )
    }
}
#endif
