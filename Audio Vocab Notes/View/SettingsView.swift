import SwiftUI
import UIKit
import Combine
import StoreKit
import MessageUI
struct SettingsView: View {
    @EnvironmentObject var store: NoteStore
    @EnvironmentObject var toggleMaanger: ToggleModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var noteManager: NoteCountManager
    @StateObject var storeManager: StoreManager
    @State var model = ToggleModel()

    @State var isExport: Bool = false
    @State var shouldPurchase = false
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false

    func getTheme() -> Bool {
        return colorScheme == .dark
    }
    var body: some View {
        ZStack {
            VStack{
                Form {
                    Section(header: Text("")) {
                        Toggle(isOn: .init(get: { toggleMaanger.isDark },
                                           set: { toggleMaanger.isDark = $0} ), label: {
                            Text("Dark Mode")
                        })
                    }
                    Section(header: Text("")) {
                        NavigationLink(
                            destination: FontView(selectedFont: fontManager.appFontName, fontSize: fontManager.fontSize),
                            label: {
                                Text("Change Font")
                            }
                        )
                    }
                    Section(header: Text("")) {
                        Button(action: {
                            if let windowScene = UIApplication.shared.windows.first?.windowScene { SKStoreReviewController.requestReview(in: windowScene) }
                        }, label: {
                            Text("Rate us in App Store")
                        })
                    }
                    Section(header: Text("")) {
                        if MFMailComposeViewController.canSendMail() {
                            Button("Feedback") {
                                self.isShowingMailView.toggle()
                            }
                        }
                    }
                    Section(header: Text("")) {
                        if !noteManager.purchased {
                            Button("Upgrade to Pro version") {
                                if storeManager.myProducts.count > 0 {
                                    shouldPurchase.toggle()
                                }
                            }
                        } else {
                            Text("You purchased Pro version")
                        }
                    }
                    Section(header: Text("")) {
                        NavigationLink(
                            destination: SelectFolderView(folders: NoteStore.shared.folders),
                            label: {
                                Text("Export notes")
                            })
                    }
                }
            }

            if storeManager.isLoading {
                ActivityIndicatorView(isVisible: .constant(true), type: .default)
                    .frame(width: 36, height: 36)
                    .foregroundColor(toggleMaanger.isDark ? .white: .black)
            }

        }
        .navigationBarTitle("Settings", displayMode: .inline)
        .edgesIgnoringSafeArea(.all)
        .actionSheet(isPresented: $shouldPurchase, content: {
            ActionSheet(
                title: Text("Pro Version"),
                message: Text("Unlock to limited capability."),
                buttons: [
                    .default(Text("Purchase to Pro \(storeManager.myProducts[0].priceLocale.currencySymbol!)\(storeManager.myProducts[0].price)"), action: {
                        if storeManager.myProducts.count > 0 {
                            self.storeManager.purchaseProduct(product: storeManager.myProducts[0], noteManager: noteManager)
                        }
                    }),
                    .default(Text("Restore"), action: {
                        if storeManager.myProducts.count > 0 {
                            self.storeManager.restoreProducts()
                        }
                    }),
                    .cancel()
                ]
            )
        })
        .sheet(isPresented: $isShowingMailView) {
            MailView(isShowing: self.$isShowingMailView, message: "", result: self.$result)
        }

    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}

//struct MailView: UIViewControllerRepresentable {
//
//    @Binding var isShowing: Bool
//    @Binding var result: Result<MFMailComposeResult, Error>?
//
//    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
//
//        @Binding var isShowing: Bool
//        @Binding var result: Result<MFMailComposeResult, Error>?
//
//        init(isShowing: Binding<Bool>,
//             result: Binding<Result<MFMailComposeResult, Error>?>) {
//            _isShowing = isShowing
//            _result = result
//        }
//
//        func mailComposeController(_ controller: MFMailComposeViewController,
//                                   didFinishWith result: MFMailComposeResult,
//                                   error: Error?) {
//            defer {
//                isShowing = false
//            }
//            guard error == nil else {
//                self.result = .failure(error!)
//                return
//            }
//            self.result = .success(result)
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(isShowing: $isShowing,
//                           result: $result)
//    }
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
//        let vc = MFMailComposeViewController()
//        vc.mailComposeDelegate = context.coordinator
//        return vc
//    }
//
//    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
//                                context: UIViewControllerRepresentableContext<MailView>) {
//
//    }
//}
