import SwiftUI
import MessageUI

struct FeedbackView: View {

    @Binding var result: SettingsResult<SettingsToastItem, Error>?
    @State var isShowingMailView = false

    var body: some View {
        Button(action: {
            self.isShowingMailView.toggle()
        }, label: {
            Text("Send feedback", comment: "Settings item to send feedback about the app.").font(.callout)
        }).sheet(isPresented: $isShowingMailView) {
                MailFeedbackView(result: self.$result)
        }.padding().foregroundColor(.primary).disabled(!MFMailComposeViewController.canSendMail())
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    FeedbackView(result: .constant(nil))
}
