import Combine
import Mockingbird
import Nimble
import Quick
import SwiftUI
@testable import Hymns

class SongResultViewModelSpec: QuickSpec {

    override func spec() {
        describe("equals") {
            it("should be equal if they are the same object") {
                let viewModel = SongResultViewModel(stableId: "empty title 1 view", title: "title 1", destinationView: EmptyView().eraseToAnyView())
                expect(viewModel).to(equal(viewModel))
            }
            it("should not be equal if they have the same stable id but different titles") {
                let viewModel1 = SongResultViewModel(stableId: "stable id", title: "title 1", destinationView: EmptyView().eraseToAnyView())
                let viewModel2 = SongResultViewModel(stableId: "stable id", title: "title 2", destinationView: Text("different view").eraseToAnyView())
                expect(viewModel1).toNot(equal(viewModel2))
            }
            it("should not be equal if they have the same title but different stable ids") {
                let viewModel1 = SongResultViewModel(stableId: "empty title 1 view", title: "title 1", destinationView: EmptyView().eraseToAnyView())
                let viewModel2 = SongResultViewModel(stableId: "empty title 2 view", title: "title 1", destinationView: EmptyView().eraseToAnyView())
                expect(viewModel1).toNot(equal(viewModel2))
            }
            it("should be equal if they have the same title and same stable ids") {
                let viewModel1 = SongResultViewModel(stableId: "empty title 1 view", title: "title 1", destinationView: EmptyView().eraseToAnyView())
                let viewModel2 = SongResultViewModel(stableId: "empty title 1 view", title: "title 1", destinationView: EmptyView().eraseToAnyView())
                expect(viewModel1).to(equal(viewModel2))
            }
        }

        describe("hasher") {
            it("hashes title and stable id") {
                let viewModel1 = SongResultViewModel(stableId: "empty title 1 view", title: "title 1", destinationView: EmptyView().eraseToAnyView())
                let viewModel2 = SongResultViewModel(stableId: "empty title 1 view", title: "title 1", destinationView: Text("abc").eraseToAnyView())
                expect(viewModel1.hashValue).to(equal(viewModel2.hashValue))
            }
        }
    }
}
