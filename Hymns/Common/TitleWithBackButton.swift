import Resolver
import SwiftUI

struct TitleWithBackButton: View {

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
                    self.coordinator.goBack()
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

#Preview(traits: .fixedLayout(width: 200, height: 50)) {
    TitleWithBackButton("Custom Title")
}
