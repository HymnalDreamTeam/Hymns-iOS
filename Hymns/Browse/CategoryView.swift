import Prefire
import SwiftUI

struct CategoryView: View {

    @State fileprivate var isExpanded: Bool

    let viewModel: CategoryViewModel

    init(viewModel: CategoryViewModel,
         isExpanded: Bool = false) {
        self.isExpanded = isExpanded
        self.viewModel = viewModel
    }

    var body: some View {
        Section {
            HStack {
                Text(viewModel.category).fixedSize(horizontal: false, vertical: true)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down").font(.system(size: smallButtonSize))
            }.onTapGesture {
                self.isExpanded.toggle()
            }.foregroundColor(isExpanded ? .accentColor : .primary)
            if isExpanded {
                ForEach(viewModel.subcategories) { subcategory in
                        NavigationLink(value: Route.browseResults(BrowseResultsListViewModel(category: self.viewModel.category,
                                                                                             subcategory: subcategory.subcategory,
                                                                                             hymnType: self.viewModel.hymnType))) {
                            SubcategoryView(viewModel: subcategory)
                        }
                }
            }
        }
    }
}

#if DEBUG
struct CategoryView_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        let viewModel = CategoryViewModel(category: "Category",
                                          hymnType: nil,
                                          subcategories: [SubcategoryViewModel(subcategory: "Subcategory 1", count: 5),
                                                          SubcategoryViewModel(subcategory: "Subcategory 2", count: 1)])
        return List {
            CategoryView(viewModel: viewModel)
            CategoryView(viewModel: viewModel, isExpanded: true).listRowSeparator(.hidden)
        }.listStyle(.plain).background(Color(.systemBackground))
    }
}
#endif
