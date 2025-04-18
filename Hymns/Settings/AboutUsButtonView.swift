import SwiftUI

struct AboutUsButtonView: View {

    @State var isShowingInfo = false

    var body: some View {
        Button(action: {
            self.isShowingInfo.toggle()
        }, label: {
            Text("About us", comment: "Title for settings item to see the 'About Us' dialog.").font(.callout)
        }).padding().foregroundColor(.primary)
            .sheet(isPresented: $isShowingInfo) {
                AboutUsDialogView()
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    AboutUsButtonView()
}
