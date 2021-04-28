import SwiftUI
import UIKit
import Combine
import Foundation
import MessageUI

let feedbackEmail = "madkevinsensei@gmail.com"

struct MailView: UIViewControllerRepresentable {

    @Binding var isShowing: Bool
    var message: String
    @Binding var result: Result<MFMailComposeResult, Error>?

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        var message: String = ""
        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(isShowing: Binding<Bool>, message: String,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _isShowing = isShowing
            _result = result
            self.message = message
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                isShowing = false
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing, message: message,
                           result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileUrl = dir.appendingPathComponent("Notes.txt")
            do {
                try message.write(to: fileUrl, atomically: false, encoding: .utf8)
                let data = try Data(contentsOf: fileUrl)
                vc.setCcRecipients([feedbackEmail])
                vc.addAttachmentData(data, mimeType: "text/txt", fileName: "Notes.text")
            } catch let e {
                print(e.localizedDescription)
            }
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {

    }
}
