import Combine
import Foundation
import Resolver

class BrowseCategoriesViewModel: ObservableObject {

    @Published var categories: [CategoryViewModel]? = [CategoryViewModel]()

    private let analytics: FirebaseLogger
    private let backgroundQueue: DispatchQueue
    private let categoriesRepository: CategoriesRepository
    private let hymnType: HymnType
    private let mainQueue: DispatchQueue

    private var disposables = Set<AnyCancellable>()

    init(hymnType: HymnType,
         analytics: FirebaseLogger = Resolver.resolve(),
         backgroundQueue: DispatchQueue = Resolver.resolve(name: "background"),
         categoriesRepository: CategoriesRepository = Resolver.resolve(),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main")) {
        self.analytics = analytics
        self.backgroundQueue = backgroundQueue
        self.categoriesRepository = categoriesRepository
        self.hymnType = hymnType
        self.mainQueue = mainQueue
    }

    func fetchCategories() {
        categoriesRepository
            .categories(by: hymnType)
            .subscribe(on: backgroundQueue)
            .replaceError(with: [CategoryEntity]())
            .map({ categories -> [CategoryViewModel]? in
                guard !categories.isEmpty else {
                    return nil
                }

                let categoryViewModels = categories.reduce(into: [CategoryViewModel]()) { viewModels, entity in
                    guard let sameCategory = viewModels.first(where: { viewModel -> Bool in
                        viewModel.category == entity.category
                    }) else {
                        let viewModel = CategoryViewModel(category: entity.category,
                                                          hymnType: self.hymnType,
                                                          subcategories: [SubcategoryViewModel(subcategory: entity.subcategory, count: entity.count)])
                        viewModels.append(viewModel)
                        return
                    }
                    sameCategory.subcategories.append(SubcategoryViewModel(subcategory: entity.subcategory, count: entity.count))
                }

                // Add the "All subcategories" section to each categoryViewModel
                return categoryViewModels.map({ categoryViewModel -> CategoryViewModel in
                    let total = categoryViewModel.subcategories.reduce(0) { (totalSoFar, subcategory) -> Int in
                        return totalSoFar + subcategory.count
                    }
                    categoryViewModel.subcategories.insert(SubcategoryViewModel(subcategory: nil, count: total), at: 0)
                    return categoryViewModel
                })
            }).receive(on: mainQueue).sink(receiveValue: { categories in
                self.categories = categories
            }).store(in: &disposables)
    }

    func clearCategories() {
        categories = [CategoryViewModel]()
    }
}
