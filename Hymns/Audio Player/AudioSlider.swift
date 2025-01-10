import AVFoundation
import Prefire
import SwiftUI

/**
 * Sliider/scrubber for the audio player.
 */
struct AudioSlider: View {

    @ObservedObject var viewModel: AudioPlayerViewModel

    var body: some View {
        VStack(spacing: 0) {
            Slider(
                value: Binding(
                    get: {
                        self.viewModel.currentTime
                    }, set: {
                        self.viewModel.currentTime = $0
                    }),
                in: 0...(viewModel.songDuration ?? 0),
                onEditingChanged: sliderEditingChanged,
                label: {Text("Song progress slider", comment: "A11y label for the song progress slider.")})
            HStack {
                Text("\(formatSecondsToHMS(viewModel.currentTime))").font(.subheadline).foregroundColor(.accentColor)
                Spacer()
                Text("\(formatSecondsToHMS(viewModel.songDuration ?? 0))").font(.subheadline)
            }
        }
    }

    private func sliderEditingChanged(editingStarted: Bool) {
        if editingStarted {
            // Stop the timers from publishing updates while the user is interacting with the slider (otherwise it would
            // keep jumping from where they've moved it to, back  to where the player is currently at)
            viewModel.stopTimer()
        } else {
            // Editing finished, start the seek
            viewModel.seek(to: viewModel.currentTime)
            viewModel.startTimer()
        }
    }

    private func formatSecondsToHMS(_ seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter.string(from: seconds) ?? "00:00"
    }
}

#if DEBUG
struct AudioSlider_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        let startViewModel = AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!)
        startViewModel.currentTime = 0
        startViewModel.songDuration = 100
        let start = AudioSlider(viewModel: startViewModel)

        let middleViewModel = AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!)
        middleViewModel.currentTime = 12
        middleViewModel.songDuration = 100
        let middle = AudioSlider(viewModel: middleViewModel)

        let endViewModel = AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!)
        endViewModel.currentTime = 100
        endViewModel.songDuration = 100
        let end = AudioSlider(viewModel: endViewModel)

        return Group {
            start.previewDisplayName("start")
            middle.previewDisplayName("middle")
            end.previewDisplayName("end")
        }.padding().previewLayout(.sizeThatFits)
    }
}
#endif
