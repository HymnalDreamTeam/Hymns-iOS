import SwiftUI
import UIKit
import MessageUI

// https://stackoverflow.com/questions/56784722/swiftui-send-email
struct MailFeedbackView: UIViewControllerRepresentable {

    @Environment(\.presentationMode) var presentation
    @Binding var result: SettingsResult<SettingsToastItem, Error>?

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var presentation: PresentationMode
        @Binding var result: SettingsResult<SettingsToastItem, Error>?

        init(presentation: Binding<PresentationMode>,
             result: Binding<SettingsResult<SettingsToastItem, Error>?>) {
            _presentation = presentation
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(.feedback(result))
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation, result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailFeedbackView>) -> MFMailComposeViewController {
        let mailVC = MFMailComposeViewController()
        let randomIssueNum = Int.random(in: 1000000000...9999999999)
        mailVC.setToRecipients(["hymnalappfeedback@gmail.com"])
        mailVC.setSubject("Hymns Mobile Feedback (iOS) # \(randomIssueNum)")

        // Add device information in HTML format
        let device = UIDevice.current
        let osVersion = device.systemVersion
        let deviceModel = device.model

        // Add app version in HTML format
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"

        let deviceInfoHTML = """
                    <br><br>
                    <hr>
                    <b>Device Information:</b><br>
                    Type: \(deviceModel)<br>
                    OS: iOS \(osVersion)<br>
                    App Version: \(appVersion) (\(buildNumber))
                """
        mailVC.setMessageBody(deviceInfoHTML, isHTML: true)
        mailVC.mailComposeDelegate = context.coordinator
        return mailVC
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailFeedbackView>) {
    }
}
