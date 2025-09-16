import MessageUI
import SwiftUI
import UIKit

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation

    var address: [String]
    var subject: String
    var body: String

    init(address: [String], subject: String, body: String) {
        self.address = address
        self.subject = subject
        self.body = body
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(presentation: presentation)
    }

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<MailView>
    ) -> MFMailComposeViewController {
        let viewController = MFMailComposeViewController()
        viewController.mailComposeDelegate = context.coordinator
        viewController.setToRecipients(address)
        viewController.setSubject(subject)
        viewController.setMessageBody(body, isHTML: false)

        return viewController
    }

    func updateUIViewController(_: MFMailComposeViewController, context _: UIViewControllerRepresentableContext<MailView>) {}
}

extension MailView {
    class Coordinator: NSObject {
        @Binding var presentation: PresentationMode

        init(
            presentation: Binding<PresentationMode>
        ) {
            _presentation = presentation
        }
    }
}

extension MailView.Coordinator: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _: MFMailComposeViewController,
        didFinishWith _: MFMailComposeResult,
        error _: Error?
    ) {
        $presentation.wrappedValue.dismiss()
    }
}

extension MailView {
    static func canSendMail() -> Bool {
        MFMailComposeViewController.canSendMail()
    }
}

extension Bundle {
    var appName: String {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        ?? object(forInfoDictionaryKey: "CFBundleName") as? String
        ?? "App"
    }
    var appVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    }
    var buildNumber: String {
        object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
    }
}
