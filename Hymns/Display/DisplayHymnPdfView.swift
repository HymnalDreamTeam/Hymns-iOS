import Resolver
import SwiftUI

struct DisplayHymnPdfView: View {

    let url: URL
    let pdfPreloader: PDFLoader

    init(url: URL, pdfPreloader: PDFLoader = Resolver.resolve()) {
        self.url = url
        self.pdfPreloader = pdfPreloader
    }

    @State private var showPdfSheet = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                self.showPdfSheet = true
            }, label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right").rotationEffect(.degrees(90)).accessibility(label: Text("Maximize music")).padding().padding(.top, 15)
            }).zIndex(1)
            PDFViewer(preloader: pdfPreloader, url: url)
        }.fullScreenCover(isPresented: $showPdfSheet) {
            ZStack(alignment: .topLeading) {
                Button(action: {
                    self.showPdfSheet = false
                }, label: {
                    Text("Close").padding()
                }).zIndex(1)
                PDFViewer(url: self.url)
            }
        }
    }
}

#if DEBUG
struct DisplayHymnPdfView_Previews: PreviewProvider {
    static var previews: some View {
        let pdfView = DisplayHymnPdfView(url: URL(string: "http://www.hymnal.net/en/hymn/h/40/f=gtpdf")!)

        return Group {
            pdfView
            pdfView.background(Color(.systemBackground)).environment(\.colorScheme, .dark).previewDisplayName("Dark Mode")
            pdfView
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
                .previewDisplayName("a11y extra extra large")
        }
    }
}
#endif
