import SwiftUI

struct ScriptureView: View {

    @State fileprivate var isExpanded = false

    let viewModel: ScriptureViewModel

    var body: some View {
        Section {
            HStack {
                Text(viewModel.book.bookName)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down").font(.system(size: smallButtonSize))
            }.onTapGesture {
                self.isExpanded.toggle()
            }.foregroundColor(isExpanded ? .accentColor : .primary)
            if isExpanded {
                ForEach(viewModel.scriptureSongs, id: \.self) { scriptureSong in
                        NavigationLink(value: Route.display(DisplayHymnContainerViewModel(hymnToDisplay: scriptureSong.hymnIdentifier))) {
                            ScriptureSongView(viewModel: scriptureSong)
                        }
                }
            }
        }
    }
}

#if DEBUG
struct ScriptureView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ScriptureViewModel(book: .malachi,
                                           scriptureSongs: [ScriptureSongViewModel(reference: "4:2", title: "But unto you who fear My name", hymnIdentifier: HymnIdentifier(hymnType: .newSong, hymnNumber: "410")),
                                                            ScriptureSongViewModel(reference: "5:1", title: "totally made up song", hymnIdentifier: HymnIdentifier(hymnType: .cebuano, hymnNumber: "98"))])
        viewModel.scriptureSongs = [ScriptureSongViewModel(reference: "General", title: "here is the title", hymnIdentifier: PreviewHymnIdentifiers.cupOfChrist)]
        return ScriptureView(viewModel: viewModel).previewLayout(.sizeThatFits)
    }
}
#endif
