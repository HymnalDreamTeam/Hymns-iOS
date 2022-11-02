import Foundation
import SwiftUI

struct SubcategoryViewModel: Equatable, Hashable {
    let subcategory: String? // subcategory is null in the "All subcategories" case
    let count: Int
}

extension SubcategoryViewModel: Identifiable {
    var id: String {
        "\(subcategory ?? "nil") \(count)"
    }
}

struct SubcategoryView: View {

    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory
    let viewModel: SubcategoryViewModel
    let allSubcategories = NSLocalizedString("All subcategories", comment: "Browse all subcategories of this category.")

    var body: some View {
        Group {
            if sizeCategory.isAccessibilityCategory() {
                Text("\(viewModel.subcategory != nil ? viewModel.subcategory! : allSubcategories) (\(viewModel.count))").fixedSize(horizontal: false, vertical: true)
            } else {
                HStack {
                    Text(viewModel.subcategory != nil ? viewModel.subcategory! : allSubcategories)
                    Spacer()
                    Text("\(viewModel.count)")
                }
            }
        }
    }
}

#if DEBUG
struct SubcategoryView_Previews: PreviewProvider {

    static var previews: some View {

        let viewModel = SubcategoryViewModel(subcategory: "His Worship", count: 5)

        return Group {
            SubcategoryView(viewModel: viewModel).previewLayout(.sizeThatFits)
        }
    }
}
#endif
