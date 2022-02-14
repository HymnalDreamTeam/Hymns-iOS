import SwiftUI

struct RepeatChorusView: View {

    @ObservedObject private var viewModel: RepeatChorusViewModel

    @Binding private var isToggleOn: Bool

    init(viewModel: RepeatChorusViewModel) {
        self.viewModel = viewModel
        self._isToggleOn = viewModel.shouldRepeatChorus
    }

    var body: some View {
        Toggle(isOn: $isToggleOn) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Repeat chorus", comment: "Title for settings item to repeat the chorus.")
                Text("For songs with only one chorus, repeat the chorus after every verse", comment: "Subtitle for settings item to repeat the chorus.")
                    .font(.caption)
            }
        }.padding()
    }
}

#if DEBUG
struct RepeatChorusView_Previews: PreviewProvider {
    static var previews: some View {
        let repeatOnViewModel = RepeatChorusViewModel()
        repeatOnViewModel.shouldRepeatChorus = .constant(true)
        let repeatOn = RepeatChorusView(viewModel: repeatOnViewModel)

        let repeatOffViewModel = RepeatChorusViewModel()
        repeatOnViewModel.shouldRepeatChorus = .constant(false)
        let repeatOff = RepeatChorusView(viewModel: repeatOffViewModel)

        return Group {
            repeatOn
            repeatOff.toPreviews()
        }
    }
}
#endif
