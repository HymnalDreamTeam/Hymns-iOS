import AVFoundation
import SwiftUI

/**
 * Sliider/scrubber for the audio player.
 */
struct AudioSlider: View {

    @ObservedObject var viewModel: AudioPlayerViewModel

    var body: some View {
        Slider(value: Binding(
            get: {
                self.viewModel.currentTime
        }, set: {
            self.viewModel.currentTime = $0
        }), in: 0...(viewModel.songDuration ?? 0),
            onEditingChanged: sliderEditingChanged,
            minimumValueLabel: Text("\(formatSecondsToHMS(viewModel.currentTime))").foregroundColor(.accentColor),
            maximumValueLabel: Text("\(formatSecondsToHMS(viewModel.songDuration ?? 0))"),
            label: {Text("Song progress slider")})
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
struct AudioPlayerControlsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AudioPlayerViewModel(url: URL(string: "https://www.hymnal.net/Hymns/NewSongs/mp3/ns0767.mp3")!, searchTitle: "Many weary years I vainly sought a spring")
        viewModel.currentTime = 12
        viewModel.songDuration = 100
        return AudioSlider(viewModel: viewModel)
    }
}
#endif
