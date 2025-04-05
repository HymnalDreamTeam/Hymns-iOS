import Combine
import Mockingbird
import Nimble
import Quick
import SwiftUI
@testable import Hymns

class SongResultViewModelSpec: QuickSpec {

    override class func spec() {
        describe("SingleSongResultViewModel") {
            let viewModel = SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"), title: "title 1",
                                                      destinationView: EmptyView().eraseToAnyView())
            describe("equals") {
                it("should be equal if they are the same object") {
                    expect(viewModel).to(equal(viewModel))
                }
                it("should be equal if they have the same stable id but different titles") {
                    let viewModel1 = SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"), title: "title 1",
                                                               destinationView: EmptyView().eraseToAnyView())
                    let viewModel2 = SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"), title: "title 2",
                                                               destinationView: Text("different view").eraseToAnyView())
                    expect(viewModel1).to(equal(viewModel2))
                }
                it("should not be equal if they have the same title but different stable ids") {
                    let viewModel1 = SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"), title: "title 1",
                                                               destinationView: EmptyView().eraseToAnyView())
                    let viewModel2 = SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .cebuano, hymnNumber: "232"), title: "title 1",
                                                               destinationView: EmptyView().eraseToAnyView())
                    expect(viewModel1).toNot(equal(viewModel2))
                }
                it("should be equal if they have the same stable ids but different labels") {
                    let viewModel1 = SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"), title: "title 1", label: "label 1",
                                                               destinationView: EmptyView().eraseToAnyView())
                    let viewModel2 = SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"), title: "title 1", label: "label 2",
                                                               destinationView: EmptyView().eraseToAnyView())
                    expect(viewModel1).to(equal(viewModel2))
                }
            }
            describe("hasher") {
                it("hashes stable id") {
                    let viewModel1 = SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"), title: "title 3",
                                                               destinationView: EmptyView().eraseToAnyView())
                    let viewModel2 = SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"), title: "title 1",
                                                               destinationView: Text("abc").eraseToAnyView())
                    expect(viewModel1.hashValue).to(equal(viewModel2.hashValue))
                }
            }
            describe("overlaps") {
                it("should overlap with another view model with the same stableId") {
                    let sameIdViewModel = SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"), title: "Different Title",
                                                                    label: nil, destinationView: EmptyView().eraseToAnyView())
                    expect(viewModel.overlaps(with: sameIdViewModel)).to(beTrue())
                }
                it("should not overlap with another view model with a different stableId") {
                    let differentIdViewModel = SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .cebuano, hymnNumber: "2223"), title: "Different Title",
                                                                         label: nil, destinationView: EmptyView().eraseToAnyView())
                    expect(viewModel.overlaps(with: differentIdViewModel)).to(beFalse())
                }
            }
            describe("merge") {
                it("should merge with another view model by returning itself") {
                    let otherViewModel = SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .cebuano, hymnNumber: "233"), title: "New Title",
                                                                   label: "New Label", destinationView: EmptyView().eraseToAnyView())
                    let mergedViewModel = viewModel.merge(with: otherViewModel)
                    expect(mergedViewModel).to(equal(viewModel))
                }
            }
        }
        describe("MultiSongResultViewModel") {
            let viewModel = MultiSongResultViewModel(stableId: [HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"),
                                                                HymnIdentifier(hymnType: .cebuano, hymnNumber: "253")],
                                                     title: "title 1", destinationView: EmptyView().eraseToAnyView())
            describe("equals") {
                it("should be equal if they are the same object") {
                    expect(viewModel).to(equal(viewModel))
                }
                it("should be equal if they have the same stable id but different titles") {
                    let viewModel2 = MultiSongResultViewModel(stableId: [HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"),
                                                                         HymnIdentifier(hymnType: .cebuano, hymnNumber: "253")],
                                                              title: "title 2", destinationView: Text("different view").eraseToAnyView())
                    expect(viewModel).to(equal(viewModel2))
                }
                it("should not be equal if they have the same title but different stable ids") {
                    let viewModel2 = MultiSongResultViewModel(stableId: [HymnIdentifier(hymnType: .cebuano, hymnNumber: "2533"),
                                                                         HymnIdentifier(hymnType: .cebuano, hymnNumber: "233")],
                                                              title: "title 1", destinationView: EmptyView().eraseToAnyView())
                    expect(viewModel).toNot(equal(viewModel2))
                }
                it("should not be equal if they have the same different stable ids but different labels") {
                    let viewModel2 = MultiSongResultViewModel(stableId: [HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"),
                                                                         HymnIdentifier(hymnType: .cebuano, hymnNumber: "253")],
                                                              title: "title 1", labels: ["label 2"], destinationView: EmptyView().eraseToAnyView())
                    expect(viewModel).to(equal(viewModel2))
                }
            }
            describe("hasher") {
                it("hashes stable id") {
                    let viewModel2 = MultiSongResultViewModel(stableId: [HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"),
                                                                         HymnIdentifier(hymnType: .cebuano, hymnNumber: "253")],
                                                              title: "title 2", destinationView: Text("abc").eraseToAnyView())
                    expect(viewModel.hashValue).to(equal(viewModel2.hashValue))
                }
            }
            describe("overlaps") {
                it("should overlap with another view model if they share at lesat one stableId") {
                    let sameIdViewModel = MultiSongResultViewModel(stableId: [HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"),
                                                                              HymnIdentifier(hymnType: .farsi, hymnNumber: "2233"),
                                                                              HymnIdentifier(hymnType: .french, hymnNumber: "23")],
                                                                   title: "Different Title", labels: nil, destinationView: EmptyView().eraseToAnyView())
                    expect(viewModel.overlaps(with: sameIdViewModel)).to(beTrue())
                }
                it("should not overlap with another view model if they don't share any stableIds") {
                    let differentIdViewModel = MultiSongResultViewModel(stableId: [HymnIdentifier(hymnType: .cebuano, hymnNumber: "233"),
                                                                                   HymnIdentifier(hymnType: .farsi, hymnNumber: "2233"),
                                                                                   HymnIdentifier(hymnType: .french, hymnNumber: "23")],
                                                                        title: "Different Title", labels: nil, destinationView: EmptyView().eraseToAnyView())
                    expect(viewModel.overlaps(with: differentIdViewModel)).to(beFalse())
                }
            }
            describe("merge") {
                it("should merge with another view model by merging the stableIds") {
                    let otherViewModel = MultiSongResultViewModel(stableId: [HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"),
                                                                             HymnIdentifier(hymnType: .farsi, hymnNumber: "2233"),
                                                                             HymnIdentifier(hymnType: .french, hymnNumber: "23")],
                                                                  title: "Different Title", labels: nil, destinationView: EmptyView().eraseToAnyView())
                    let mergedViewModel = viewModel.merge(with: otherViewModel)
                    expect(mergedViewModel).to(equal(MultiSongResultViewModel(stableId: [HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"),
                                                                                         HymnIdentifier(hymnType: .cebuano, hymnNumber: "253"),
                                                                                         HymnIdentifier(hymnType: .farsi, hymnNumber: "2233"),
                                                                                         HymnIdentifier(hymnType: .french, hymnNumber: "23")],
                                                                              title: "title 1", destinationView: EmptyView().eraseToAnyView())))
                }
            }
        }
        describe("SongResultViewModel") {
            let single = SingleSongResultViewModel(stableId: HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"), title: "title 1",
                                                   destinationView: EmptyView().eraseToAnyView())
            let multi = MultiSongResultViewModel(stableId: [HymnIdentifier(hymnType: .cebuano, hymnNumber: "23"),
                                                            HymnIdentifier(hymnType: .cebuano, hymnNumber: "253")],
                                                 title: "title 1", destinationView: EmptyView().eraseToAnyView())
            context("SingleSongResultViewModel") {
                let viewModel: SongResultViewModel = .single(single)
                describe("singleSongResultViewModel") {
                    it("returns view model") {
                        expect(viewModel.singleSongResultViewModel).to(be(single))
                    }
                }
                describe("multiSongResultViewModel") {
                    it("returns nil") {
                        expect(viewModel.multiSongResultViewModel).to(beNil())
                    }
                }
            }
            context("MultiSongResultViewModel") {
                let viewModel: SongResultViewModel = .multi(multi)
                describe("singleSongResultViewModel") {
                    it("returns nil") {
                        expect(viewModel.singleSongResultViewModel).to(beNil())
                    }
                }
                describe("multiSongResultViewModel") {
                    it("returns view model") {
                        expect(viewModel.multiSongResultViewModel).to(be(multi))
                    }
                }
            }
            describe("overlaps") {
                it("mixed type should return false") {
                    expect(SongResultViewModel.single(single).overlaps(with: .multi(multi))).to(beFalse())
                }
                it("same type should call subclass's method") {
                    expect(SongResultViewModel.single(single).overlaps(with: .single(single))).to(beTrue())
                    expect(SongResultViewModel.multi(multi).overlaps(with: .multi(multi))).to(beTrue())
                }
            }
            describe("merge") {
                it("mixed type should return nil") {
                    expect(SongResultViewModel.single(single).merge(with: .multi(multi))).to(beNil())
                }
                it("same type should call subclass's method") {
                    expect(SongResultViewModel.single(single).merge(with: .single(single))).to(equal(.single(single)))
                    expect(SongResultViewModel.multi(multi).merge(with: .multi(multi))).to(equal(.multi(multi)))
                }
            }
        }
    }
}
