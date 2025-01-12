import Prefire
import SwiftUI

struct BrowseCategoriesView: View {

    @ObservedObject var viewModel: BrowseCategoriesViewModel

    var body: some View {
        Group<AnyView> {
            guard let categories = viewModel.categories else {
                return ErrorView().maxSize().eraseToAnyView()
            }

            guard !categories.isEmpty else {
                return ActivityIndicator().maxSize().onAppear {
                    self.viewModel.fetchCategories()
                }.eraseToAnyView()
            }

            return List(categories) { category in
                CategoryView(viewModel: category).listRowSeparator(.hidden)
            }.listStyle(.plain).id(viewModel.categories).eraseToAnyView() // https://stackoverflow.com/questions/56533511/how-update-a-swiftui-list-without-animation
        }.background(Color(.systemBackground))
    }
}

#if DEBUG
struct BrowseCategoriesView_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        let errorViewModel = BrowseCategoriesViewModel(hymnType: .classic)
        errorViewModel.categories = nil
        let error = BrowseCategoriesView(viewModel: errorViewModel)

        let loadingViewModel = BrowseCategoriesViewModel(hymnType: .classic)
        let loading = BrowseCategoriesView(viewModel: loadingViewModel)

        let resultsViewModel = BrowseCategoriesViewModel(hymnType: .classic)
        resultsViewModel.categories
            = [CategoryViewModel(category: "Category 1",
                                 hymnType: nil,
                                 subcategories: [SubcategoryViewModel(subcategory: "Subcategory 1", count: 15),
                                                 SubcategoryViewModel(subcategory: "Subcategory 2", count: 2)]),
               CategoryViewModel(category: "Category 2",
                                 hymnType: nil,
                                 subcategories: [SubcategoryViewModel(subcategory: "Subcategory 2", count: 12),
                                                 SubcategoryViewModel(subcategory: "Subcategory 3", count: 1)])]
        let results = BrowseCategoriesView(viewModel: resultsViewModel)
        return Group {
            error.previewDisplayName("error")
            loading.previewDisplayName("loading")
            results.previewDisplayName("results")
        }
    }
}
#endif
