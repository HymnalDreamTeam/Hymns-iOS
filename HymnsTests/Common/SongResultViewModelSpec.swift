import Combine
import Mockingbird
import Nimble
import Quick
import SwiftUI
@testable import Hymns

class SongResultViewModelSpec: AsyncSpec {

    override class func spec() {
        describe("SongResultViewModel") {
            context("SingleSongResultViewModel") {
                let viewModel = SingleSongResultViewModel(stableId: "empty title 1 view", title: "title 1", destinationView: EmptyView().eraseToAnyView())
                describe("singleSongResultViewModel") {
                    it("returns view model") {
                        expect(SongResultViewModel.single(viewModel).singleSongResultViewModel).to(equal(viewModel))
                    }
                }
                describe("multiSongResultViewModel") {
                    it("returns nil") {
                        expect(SongResultViewModel.single(viewModel).multiSongResultViewModel).to(beNil())
                    }
                }
                describe("equals") {
                    it("should be equal if they are the same object") {
                        expect(viewModel).to(equal(viewModel))
                    }
                    it("should be equal if they have the same stable id but different titles") {
                        let viewModel1 = SingleSongResultViewModel(stableId: "stable id", title: "title 1", destinationView: EmptyView().eraseToAnyView())
                        let viewModel2 = SingleSongResultViewModel(stableId: "stable id", title: "title 2", destinationView: Text("different view").eraseToAnyView())
                        expect(viewModel1).to(equal(viewModel2))
                    }
                    it("should not be equal if they have the same title but different stable ids") {
                        let viewModel1 = SingleSongResultViewModel(stableId: "empty title 1 view", title: "title 1", destinationView: EmptyView().eraseToAnyView())
                        let viewModel2 = SingleSongResultViewModel(stableId: "empty title 2 view", title: "title 1", destinationView: EmptyView().eraseToAnyView())
                        expect(viewModel1).toNot(equal(viewModel2))
                    }
                    it("should not be equal if they have the same different stable ids but different labels") {
                        let viewModel1 = SingleSongResultViewModel(stableId: "empty title 1 view", title: "title 1", label: "label 1",
                                                                   destinationView: EmptyView().eraseToAnyView())
                        let viewModel2 = SingleSongResultViewModel(stableId: "empty title 1 view", title: "title 1", label: "label 2",
                                                                   destinationView: EmptyView().eraseToAnyView())
                        expect(viewModel1).to(equal(viewModel2))
                    }
                }
                describe("hasher") {
                    it("hashes title and stable id") {
                        let viewModel1 = SingleSongResultViewModel(stableId: "empty title 1 view", title: "title 1", destinationView: EmptyView().eraseToAnyView())
                        let viewModel2 = SingleSongResultViewModel(stableId: "empty title 1 view", title: "title 1", destinationView: Text("abc").eraseToAnyView())
                        expect(viewModel1.hashValue).to(equal(viewModel2.hashValue))
                    }
                }
            }
            context("MultiSongResultViewModel") {
                let viewModel = MultiSongResultViewModel(stableId: "empty title 1 view", title: "title 1", destinationView: EmptyView().eraseToAnyView())
                describe("singleSongResultViewModel") {
                    it("returns nil") {
                        expect(SongResultViewModel.multi(viewModel).singleSongResultViewModel).to(beNil())
                    }
                }
                describe("multiSongResultViewModel") {
                    it("returns view model") {
                        expect(SongResultViewModel.multi(viewModel).multiSongResultViewModel).to(equal(viewModel))
                    }
                }
                describe("equals") {
                    it("should be equal if they are the same object") {
                        expect(viewModel).to(equal(viewModel))
                    }
                    it("should be equal if they have the same stable id but different titles") {
                        let viewModel1 = MultiSongResultViewModel(stableId: "stable id", title: "title 1", destinationView: EmptyView().eraseToAnyView())
                        let viewModel2 = MultiSongResultViewModel(stableId: "stable id", title: "title 2", destinationView: Text("different view").eraseToAnyView())
                        expect(viewModel1).to(equal(viewModel2))
                    }
                    it("should not be equal if they have the same title but different stable ids") {
                        let viewModel1 = MultiSongResultViewModel(stableId: "empty title 1 view", title: "title 1", destinationView: EmptyView().eraseToAnyView())
                        let viewModel2 = MultiSongResultViewModel(stableId: "empty title 2 view", title: "title 1", destinationView: EmptyView().eraseToAnyView())
                        expect(viewModel1).toNot(equal(viewModel2))
                    }
                    it("should not be equal if they have the same different stable ids but different labels") {
                        let viewModel1 = MultiSongResultViewModel(stableId: "empty title 1 view", title: "title 1", labels: ["label 1"],
                                                                  destinationView: EmptyView().eraseToAnyView())
                        let viewModel2 = MultiSongResultViewModel(stableId: "empty title 1 view", title: "title 1", labels: ["label 2"],
                                                                  destinationView: EmptyView().eraseToAnyView())
                        expect(viewModel1).to(equal(viewModel2))
                    }
                }
                describe("hasher") {
                    it("hashes title and stable id") {
                        let viewModel1 = MultiSongResultViewModel(stableId: "empty title 1 view", title: "title 1", destinationView: EmptyView().eraseToAnyView())
                        let viewModel2 = MultiSongResultViewModel(stableId: "empty title 1 view", title: "title 1", destinationView: Text("abc").eraseToAnyView())
                        expect(viewModel1.hashValue).to(equal(viewModel2.hashValue))
                    }
                }
            }
        }
    }
}
