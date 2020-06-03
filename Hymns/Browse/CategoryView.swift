import SwiftUI

struct CategoryView: View {

    @State fileprivate var isExpanded = false

    let viewModel: CategoryViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.category).onTapGesture {
                self.isExpanded.toggle()
            }
            if isExpanded {
                List {
                    ForEach(viewModel.subcategories, id: \.self) { subcategory in
                        NavigationLink(destination: BrowseResultsListView(viewModel: BrowseResultsListViewModel(category: self.viewModel.category, subcategory: subcategory.subcategory, hymnType: self.viewModel.hymnType))) {
                            SubcategoryView(viewModel: subcategory)
                        }
                    }
                }.frame(height: CGFloat(viewModel.subcategories.count * 45))
            }
        }
    }
}

struct CategoryView_Previews: PreviewProvider {

    static var previews: some View {

        let viewModel = CategoryViewModel(category: "Category",
                                          subcategories: [SubcategoryViewModel(subcategory: "Subcategory 1", count: 5),
                                                          SubcategoryViewModel(subcategory: "Subcategory 2", count: 1)])

        return Group {
            CategoryView(viewModel: viewModel).previewLayout(.sizeThatFits)
        }
    }
}
