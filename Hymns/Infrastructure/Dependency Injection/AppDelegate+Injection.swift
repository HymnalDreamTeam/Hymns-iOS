import Resolver
import Foundation
/**
 * Registers dependencies to be injected in the app
 */
extension Resolver: ResolverRegistering {

    #if DEBUG
    static let mock = Resolver(child: main)
    #endif

    public static func registerAllServices() {
        registerApplication()
        register(name: "main") { DispatchQueue.main }
        register(name: "background") { DispatchQueue.global() }
        register(JSONDecoder.self, factory: {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        })
        register(JSONEncoder.self, factory: {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.dataEncodingStrategy = .deferredToData
            encoder.nonConformingFloatEncodingStrategy = .throw
            return encoder
        })
        register {NavigationCoordinator()}.scope(.application)
        register {URLSession.shared}.scope(.application)
        register {UserDefaultsManager()}.scope(.application)
        register {AnalyticsLogger()}
        register {SystemUtilImpl() as SystemUtil}
        registerPDFLoader()
        registerConverters()
        registerHymnDataStore()
        registerSongbaseStore()
        registerHistoryStore()
        registerTagStore()
        registerFavoriteStore()
        registerHymnalApiService()
        registerHymnalNetService()
        registerRepositories()
        registerHomeViewModel()
        registerBrowseViewModel()
        registerTagListViewModel()
        registerBrowseScripturesViewModel()
        registerAllSongsViewModel()
        registerFavoritesViewModel()
        registerSettingsViewModel()

        #if DEBUG
        if CommandLine.arguments.contains(AppDelegate.uiTestingFlag) {
            mock.register { PdfLoaderTestImpl() as PDFLoader }.scope(.application)
            mock.register { FavoriteStoreTestImpl() as FavoriteStore }.scope(.application)
            mock.register { HymnDataStoreTestImpl() as HymnDataStore }.scope(.application)
            mock.register { SongbaseStoreTestImpl() as SongbaseStore }.scope(.application)
            mock.register { HymnalApiServiceTestImpl() as HymnalApiService }.scope(.application)
            mock.register { HistoryStoreTestImpl() as HistoryStore }.scope(.application)
            mock.register { TagStoreTestImpl() as TagStore }.scope(.application)
            root = mock
        }
        #endif
    }
}
