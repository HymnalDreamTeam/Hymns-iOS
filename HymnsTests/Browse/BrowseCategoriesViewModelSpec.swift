import Combine
import Mockingbird
import Nimble
import Quick
@testable import Hymns

class BrowseCategoriesViewModelSpec: QuickSpec {

    override func spec() {

        // https://www.vadimbulavin.com/unit-testing-async-code-in-swift/
        let testQueue = DispatchQueue(label: "test_queue")
        var categoriesRepository: CategoriesRepositoryMock!
        var target: BrowseCategoriesViewModel!

        describe("fetching categories") {
            beforeEach {
                categoriesRepository = mock(CategoriesRepository.self)
                target = BrowseCategoriesViewModel(hymnType: .dutch, backgroundQueue: testQueue, categoriesRepository: categoriesRepository, mainQueue: testQueue)
            }
            context("with results") {
                let categories = [CategoryEntity(category: "Category 1", subcategory: "Subcategory 1", count: 5),
                                  CategoryEntity(category: "Category 2", subcategory: "Subcategory 1", count: 6),
                                  CategoryEntity(category: "Category 1", subcategory: "Subcategory 3", count: 2),
                                  CategoryEntity(category: "Category 1", subcategory: "Subcategory 4", count: 5),
                                  CategoryEntity(category: "Category 3", subcategory: "Subcategory 20", count: 98),
                                  CategoryEntity(category: "Category 1", subcategory: "Subcategory 2", count: 738)]
                let currentValue = CurrentValueSubject<[CategoryEntity], ErrorType>(categories)
                beforeEach {
                    given(categoriesRepository.categories(by: .dutch)) ~> {_ in
                        currentValue.eraseToAnyPublisher()
                    }
                    target.fetchCategories()
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("should contain returned categories") {
                    let expected = [CategoryViewModel(category: "Category 1",
                                                      hymnType: .dutch,
                                                      subcategories: [SubcategoryViewModel(subcategory: nil, count: 750),
                                                                      SubcategoryViewModel(subcategory: "Subcategory 1", count: 5),
                                                                      SubcategoryViewModel(subcategory: "Subcategory 3", count: 2),
                                                                      SubcategoryViewModel(subcategory: "Subcategory 4", count: 5),
                                                                      SubcategoryViewModel(subcategory: "Subcategory 2", count: 738)]),
                                    CategoryViewModel(category: "Category 2",
                                                      hymnType: .dutch,
                                                      subcategories: [SubcategoryViewModel(subcategory: nil, count: 6),
                                                                      SubcategoryViewModel(subcategory: "Subcategory 1", count: 6)]),
                                    CategoryViewModel(category: "Category 3",
                                                      hymnType: .dutch,
                                                      subcategories: [SubcategoryViewModel(subcategory: nil, count: 98),
                                                                      SubcategoryViewModel(subcategory: "Subcategory 20", count: 98)])]
                    expect(target.categories).to(equal(expected))
                }
            }
        }
    }
}
