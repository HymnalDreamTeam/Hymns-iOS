import SwiftUI

struct DisplayHymnToolbar: View {

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var viewModel: DisplayHymnViewModel
 //   @State private var showSoundCloud = false
    @Binding var showSoundCloud: Bool
    @Binding var initiatedSoundCloud: Bool

    init(viewModel: DisplayHymnViewModel, showSoundCloud: Binding<Bool>, initiatedSoundCloud: Binding<Bool>) {
        self.viewModel = viewModel
        self._showSoundCloud = showSoundCloud
        self._initiatedSoundCloud = initiatedSoundCloud
    }

    var body: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "chevron.left").accentColor(.primary).padding()
            })
            Spacer()
            Text(viewModel.title).fontWeight(.bold)
            Spacer()
            if initiatedSoundCloud {
                Button(action: {
                    self.initiatedSoundCloud = false
                }, label: {
                    Image(systemName: "stop.circle").accentColor(.primary)
                })
            }
            Button(action: {
                self.showSoundCloud.toggle()
                self.initiatedSoundCloud = true
            }, label: {
                initiatedSoundCloud ?
                Image(systemName: "cloud.fill").accentColor(.accentColor) :
                Image(systemName: "cloud").accentColor(.primary)
            })

            viewModel.isFavorited.map { isFavorited in
                Button(action: {
                    self.viewModel.toggleFavorited()
                }, label: {
                    isFavorited ?
                        Image(systemName: "heart.fill").accentColor(.accentColor).padding() :
                        Image(systemName: "heart").accentColor(.primary).padding()
                })
            }
        }
    }
}
/*
#if DEBUG
struct DisplayHymnToolbar_Previews: PreviewProvider {
    static var previews: some View {
        let loading = DisplayHymnToolbar(viewModel: DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151))

        let classic40ViewModel = DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn40)
        classic40ViewModel.title = "Hymn 40"
        classic40ViewModel.isFavorited = true
        let classic40 = DisplayHymnToolbar(viewModel: classic40ViewModel)

        let classic1151ViewModel = DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151)
        classic1151ViewModel.title = "Hymn 1151"
        classic1151ViewModel.isFavorited = false
        let classic1151 = DisplayHymnToolbar(viewModel: classic1151ViewModel)

        let cupOfChristViewModel = DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.cupOfChrist)
        cupOfChristViewModel.title = "Cup of Christ"
        cupOfChristViewModel.isFavorited = true
        let cupOfChrist = DisplayHymnToolbar(viewModel: cupOfChristViewModel)
        return Group {
            loading.previewDisplayName("loading")
            classic40.previewDisplayName("classic 40")
            classic1151.previewDisplayName("classic 1151")
            cupOfChrist.toPreviews("cup of christ")
        }.previewLayout(.sizeThatFits)
    }
}
#endif
*/
