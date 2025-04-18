import Prefire
import Resolver
import SwiftUI

struct DisplayHymnPdfView: View {

    @State private var showPdfSheet = false
    @ObservedObject private var viewModel: DisplayHymnPdfViewModel

    init(viewModel: DisplayHymnPdfViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        buildView().preference(key: DisplayHymnView.DisplayTypeKey.self, value: .sheetMusic)
    }

    private func buildView() -> AnyView {
        if viewModel.isLoading {
            return ActivityIndicator().onAppear {
                viewModel.loadPdf()
            }.preference(key: DisplayHymnView.DisplayTypeKey.self, value: .sheetMusic).eraseToAnyView()
        }

        guard let pdfDocument = viewModel.pdfDocument else {
            return ErrorView().preference(key: DisplayHymnView.DisplayTypeKey.self, value: .sheetMusic).eraseToAnyView()
        }

        return ZStack(alignment: .topTrailing) {
            Button(action: {
                self.showPdfSheet = true
            }, label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .rotationEffect(.degrees(90))
                    .accessibility(label: Text("Maximize sheet music", comment: "A11y label for maximizing the sheet music."))
                    .padding().padding(.top, 15)
            }).zIndex(1)
            PdfViewer(pdfDocument)
        }.fullScreenCover(isPresented: $showPdfSheet) {
            ZStack(alignment: .topLeading) {
                Button(action: {
                    self.showPdfSheet = false
                }, label: {
                    Text("Close", comment: "Close the full screen PDF view.").padding()
                }).zIndex(1)
                PdfViewer(pdfDocument)
            }
        }.eraseToAnyView()
    }
}

#if DEBUG
struct DisplayHymnPdfView_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        let loadingViewModel = DisplayHymnPdfViewModel(url: URL(string: "http://www.dummylink.com")!)
        let loading = DisplayHymnPdfView(viewModel: loadingViewModel)

        let errorViewModel = DisplayHymnPdfViewModel(url: URL(string: "http://www.dummylink.com")!)
        errorViewModel.isLoading = false
        let error = DisplayHymnPdfView(viewModel: errorViewModel)

        // Seed the preloader with a dummy pdf so the initial state should be the pdf, since no loading is required.
        let loadedViewModel = DisplayHymnPdfViewModel(preloader: PdfLoaderTestImpl(), url: URL(string: "http://www.dummypdf.com")!)
        loadedViewModel.pdfDocument = PdfLoaderTestImpl.createPdf()
        loadedViewModel.isLoading = false
        let loaded = DisplayHymnPdfView(viewModel: loadedViewModel)
        return Group {
            loading.previewDisplayName("loading")
            error.previewDisplayName("error")
            loaded.previewDisplayName("loaded")
        }
    }
}
#endif
