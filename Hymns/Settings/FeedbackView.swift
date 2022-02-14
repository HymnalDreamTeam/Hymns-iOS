import SwiftUI
import MessageUI

struct FeedbackView: View {

    @Binding var result: Result<SettingsToastItem, Error>?
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

extension Result: Identifiable {
    public var id: Int {
        switch self {
        case .success:
            return 0
        case .failure:
            return 1
        }
    }
}

#if DEBUG
struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView(result: .constant(nil)).toPreviews()
    }
}
#endif
