import Resolver
import SwiftUI

struct TitleWithBackButton: View {

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var coordinator: NavigationCoordinator
    private let firebaseLogger: FirebaseLogger
    private let title: String

    init(_ title: String,
         coordinator: NavigationCoordinator = Resolver.resolve(),
         firebaseLogger: FirebaseLogger = Resolver.resolve()) {
        self.coordinator = coordinator
        self.firebaseLogger = firebaseLogger
        self.title = title
    }

    var body: some View {
        HStack {
            Button(action: {
                firebaseLogger.logButtonClick("back", file: #file)
                if #available(iOS 16, *) {
                    self.coordinator.goBack()
                } else {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }, label: {
                Image(systemName: "chevron.left")
                    .accessibility(label: Text("Go back", comment: "A11y label for going back."))
                    .accentColor(.primary).padding()
            })
            Text(title).font(.body).fontWeight(.bold)
            Spacer()
        }
    }
}

#if DEBUG
struct TitleWithBackButton_Previews: PreviewProvider {
    static var previews: some View {
        TitleWithBackButton("Custom Title").previewLayout(.fixed(width: 200, height: 50))
    }
}
#endif
