import SwiftUI

struct CategoryView: View {

    @State fileprivate var isExpanded = false

    let viewModel: CategoryViewModel

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
                    NavigationLink(destination: BrowseResultsListView(viewModel: BrowseResultsListViewModel(category: self.viewModel.category, subcategory: subcategory.subcategory, hymnType: self.viewModel.hymnType))) {
                        SubcategoryView(viewModel: subcategory)
                    }
                }
            }
        }
    }
}

struct CategoryView_Previews: PreviewProvider {

    static var previews: some View {

        let viewModel = CategoryViewModel(category: "Category",
                                          hymnType: nil,
                                          subcategories: [SubcategoryViewModel(subcategory: "Subcategory 1", count: 5),
                                                          SubcategoryViewModel(subcategory: "Subcategory 2", count: 1)])

        return Group {
            CategoryView(viewModel: viewModel).previewLayout(.sizeThatFits)
        }
    }
}
