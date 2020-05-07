import SwiftUI

struct DisplayHymnToolbarView: View {
    @State var toolbarTab = "lyrics"
    @ObservedObject private var viewModel: DisplayHymnViewModel

    init(viewModel: DisplayHymnViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("LYRICS").foregroundColor(self.toolbarTab == "lyrics" ? .blue : .gray).onTapGesture {
                    self.toolbarTab = "lyrics"
                }
                Spacer()
                Text("CHORDS").foregroundColor(self.toolbarTab == "chords" ? .blue : .gray).onTapGesture {
                    self.toolbarTab = "chords"
                }
                Spacer()
                Text("GUITAR").foregroundColor(self.toolbarTab == "guitar" ? .blue : .gray).onTapGesture {
                    self.toolbarTab = "guitar"
                }
                Spacer()
                Text("PIANO").foregroundColor(self.toolbarTab == "piano" ? .blue : .gray).onTapGesture {
                    self.toolbarTab = "piano"
                }
                Spacer()
            }
            if self.toolbarTab == "lyrics" {
                HymnLyricsView(viewModel: self.viewModel.hymnLyricsViewModel)
            } else if self.toolbarTab == "chords" {
                // Text("\(self.viewModel.identifier.hymnNumber)")
                // print("\(self.viewModel.identifier.hymnNumber)")
                WebView(request: URLRequest(url: URL(string: "https://www.hymnal.net/en/hymn/\(self.viewModel.identifier.hymnType.abbreviatedValue)/\(self.viewModel.identifier.hymnNumber)/f=gtpdf")!))
            } else if self.toolbarTab == "guitar" {
                WebView(request: URLRequest(url: URL(string: "https://www.hymnal.net/en/hymn/\(self.viewModel.identifier.hymnType.abbreviatedValue)/\(self.viewModel.identifier.hymnNumber)/f=pdf")!))
            } else {
                WebView(request: URLRequest(url: URL(string: "https://www.hymnal.net/en/hymn/\(self.viewModel.identifier.hymnType.abbreviatedValue)/\(self.viewModel.identifier.hymnNumber)/f=ppdf")!))
            }
        }
    }
}

struct DisplayHymnToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayHymnToolbarView(viewModel: DisplayHymnViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn40))
    }
}
