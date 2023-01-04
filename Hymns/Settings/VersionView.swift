import Resolver
import SwiftUI

struct VersionView: View {

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var coordinator: NavigationCoordinator

    init(coordinator: NavigationCoordinator = Resolver.resolve()) {
        self.coordinator = coordinator
    }

    var body: some View {
        VStack(alignment: .leading) {
            TitleWithBackButton("Version information")
            HStack {
                Text("Release version")
                Spacer()
                Text("\(Bundle.main.releaseVersion)").foregroundColor(.gray)
            }.padding()
            HStack {
                Text("Build version")
                Spacer()
                Text("\(Bundle.main.buildVersion)").foregroundColor(.gray)
            }.padding()
            HStack {
                Text("iOS version")
                Spacer()
                Text("\(UIDevice.current.systemVersion)").foregroundColor(.gray)
            }.padding()
            Spacer()
        }.hideNavigationBar()
    }
}

#if DEBUG
struct VersionView_Previews: PreviewProvider {
    static var previews: some View {
        VersionView()
    }
}
#endif
