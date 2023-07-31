import Combine
import Foundation
import Resolver
import SwiftUI

class LaunchRouterViewModel: ObservableObject {

    private let backgroundQueue: DispatchQueue
    private let firebaseLogger: FirebaseLogger
    private let mainQueue: DispatchQueue
    private let songbaseV3Migrater: SongbaseV3Migrater
    private let systemUtil: SystemUtil
    private let userDefaultsManager: UserDefaultsManager

    @Published var oldDatabaseFilesDeleted = false

    init(backgroundQueue: DispatchQueue = Resolver.resolve(name: "background"),
         firebaseLogger: FirebaseLogger = Resolver.resolve(),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
         songbaseV3Migrater: SongbaseV3Migrater = Resolver.resolve(),
         systemUtil: SystemUtil = Resolver.resolve(),
         userDefaultsManager: UserDefaultsManager = Resolver.resolve()) {
        self.backgroundQueue = backgroundQueue
        self.firebaseLogger = firebaseLogger
        self.mainQueue = mainQueue
        self.songbaseV3Migrater = songbaseV3Migrater
        self.systemUtil = systemUtil
        self.userDefaultsManager = userDefaultsManager
    }

    func preloadDonationProducts() async {
        await systemUtil.loadDonationProducts()
    }

    func deleteOldDatabaseFiles() async {
        // Will be executed at the end of the function, regardless of early returns. Basically the equivalent of Java "finally".
        defer {
            mainQueue.sync {
                oldDatabaseFilesDeleted = true
            }
        }

        let fileManager = FileManager.default
        do {
            let applicationSupportPath = try fileManager.url(for: .applicationSupportDirectory,
                                                             in: .userDomainMask,
                                                             appropriateFor: nil, create: true).path
            let pathsToDelete = try fileManager.contentsOfDirectory(atPath: applicationSupportPath)
                .filter({ file in
                    // Filter out the current database's file(s) so we don't delete those
                    !file.contains("hymnaldb-v\(HYMN_DATA_STORE_VERISON).sqlite")
                }).filter({ file in
                    file.contains("hymnaldb")
                }).map({ file in
                    "\(applicationSupportPath)/\(file)"
                })

            // If there are no files to delete, then just return
            if pathsToDelete.isEmpty {
                return
            }

            try pathsToDelete.forEach { pathToDelete in
                if !fileManager.isDeletableFile(atPath: pathToDelete) {
                    self.firebaseLogger.logError(DatabaseDeletionError(errorDescription: "Songbase file \(pathToDelete) is not deletable"))
                    return
                }
                try fileManager.removeItem(atPath: pathToDelete)
            }
        } catch {
            firebaseLogger.logError(error, message: "Error occurred while trying to delete songbase database files")
        }
    }

    func migrateSongbaseV3() async {
        await songbaseV3Migrater.migrate()
    }
}

extension Resolver {
    public static func registerLaunchRouterViewModel() {
        register {LaunchRouterViewModel()}.scope(.graph)
    }
}
