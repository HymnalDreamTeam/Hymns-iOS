import Resolver

/**
 * Registers repositories to the dependency injection framework.
 */
extension Resolver {
    public static func registerRepositories() {
        register {BrowseRepositoryImpl() as BrowseRepository}.scope(.application)
        register {CategoriesRepositoryImpl() as CategoriesRepository}.scope(.application)
        register {HymnsRepositoryImpl() as HymnsRepository}.scope(.application)
        register {SongResultsRepositoryImpl() as SongResultsRepository}.scope(.application)
    }
}
