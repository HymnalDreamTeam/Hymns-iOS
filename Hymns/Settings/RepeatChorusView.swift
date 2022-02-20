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
                Text("For songs with only one chorus, repeat the chorus after every verse.", comment: "Subtitle for settings item to repeat the chorus.")
                    // Text keeps ellipsizing at one line, so need to do something like this to allow it to wrap. Error only happened
                    // in iOS 14.4 and 14.5, so likely we can remove this when we stop supporting iOS 14.
                    // https://stackoverflow.com/questions/56505929/the-text-doesnt-get-wrapped-in-swift-ui/59277022#59277022
                    .fixedSize(horizontal: false, vertical: true)
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
