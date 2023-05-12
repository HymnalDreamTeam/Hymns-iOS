import Resolver
import SwiftUI

struct LaunchRouterView: View {

    @ObservedObject private var viewModel: LaunchRouterViewModel

    @AppStorage("favorites_migrated") var favoritesMigrated = false
    @AppStorage("tags_migrated") var tagsMigrated = false
    @AppStorage("history_migrated") var historyMigrated = false

    private let firebaseLogger: FirebaseLogger
    private let userDefaultsManager: UserDefaultsManager
    private let systemUtil: SystemUtil

    init(firebaseLogger: FirebaseLogger = Resolver.resolve(),
         userDefaultsManager: UserDefaultsManager = Resolver.resolve(),
         systemUtil: SystemUtil = Resolver.resolve(),
         viewModel: LaunchRouterViewModel) {
        self.firebaseLogger = firebaseLogger
        self.userDefaultsManager = userDefaultsManager
        self.systemUtil = systemUtil
        self.viewModel = viewModel
    }

    var body: some View {
        Group { () -> AnyView in
            if viewModel.oldDatabaseFilesDeleted && favoritesMigrated && tagsMigrated && historyMigrated {
                if #available(iOS 16, *) {
                    return HomeContainerView().eraseToAnyView()
                } else {
                    return HomeContainerView15().eraseToAnyView()
                }
            } else {
                return LottieView(fileName: "firstLaunchAnimation", shouldLoop: true).eraseToAnyView()
            }
        }.task {
            await viewModel.preloadDonationProducts()
            await viewModel.deleteOldDatabaseFiles()
            await viewModel.migrateSongbaseV3()
        }
    }
}
