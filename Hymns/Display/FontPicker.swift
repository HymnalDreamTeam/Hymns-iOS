import SwiftEventBus
import SwiftUI

struct FontPicker: View {

    @ObservedObject private var viewModel: FontPickerViewModel

    init(viewModel: FontPickerViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack {
            Image(systemName: "textformat.size.smaller")
            Slider(
                value: $viewModel.fontSize,
                in: 13...24,
                step: 1)
            Image(systemName: "textformat.size.larger")
        }.onAppear {
            // Font picker is up, so disable song swiping
            SwiftEventBus.post(DisplayHymnContainerViewModel.songSwipableEvent, sender: false)
        }.onDisappear {
            // Font picker is gone, so disable song swiping
            SwiftEventBus.post(DisplayHymnContainerViewModel.songSwipableEvent, sender: true)
        }.padding(.horizontal)
    }
}

#if DEBUG
struct FontPicker_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = FontPickerViewModel()
        viewModel.fontSize = 18.0
        return FontPicker(viewModel: viewModel)
    }
}
#endif