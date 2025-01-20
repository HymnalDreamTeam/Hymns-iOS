import Resolver
import SwiftUI

struct VersionView: View {

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var coordinator: NavigationCoordinator

    let releaseVersion: String
    let buildVersion: String
    let systemVersion: String

    init(coordinator: NavigationCoordinator = Resolver.resolve(),
         releaseVersion: String = Bundle.main.releaseVersion,
         buildVersion: String = Bundle.main.buildVersion,
         systemVersion: String = UIDevice.current.systemVersion) {
        self.coordinator = coordinator
        self.releaseVersion = releaseVersion
        self.buildVersion = buildVersion
        self.systemVersion = systemVersion
    }

    var body: some View {
        VStack(alignment: .leading) {
            TitleWithBackButton("Version information")
            HStack {
                Text("Release version")
                Spacer()
                Text("\(releaseVersion)").foregroundColor(.gray)
            }.padding()
            HStack {
                Text("Build version")
                Spacer()
                Text("\(buildVersion)").foregroundColor(.gray)
            }.padding()
            HStack {
                Text("iOS version")
                Spacer()
                Text("\(systemVersion)").foregroundColor(.gray)
            }.padding()
            Spacer()
        }.hideNavigationBar()
    }
}

#Preview {
    VersionView(releaseVersion: "1.0.0", buildVersion: "12", systemVersion: "13.0")
}
