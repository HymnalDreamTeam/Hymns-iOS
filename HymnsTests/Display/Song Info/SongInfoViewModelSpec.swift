import Combine
import Quick
import Mockingbird
import Nimble
@testable import Hymns

class SongInfoViewModelSpec: QuickSpec {

    override class func spec() {
        describe("SongInfoViewModel") {
            var target: SongInfoViewModel!
            context("type category") {
                beforeEach {
                    target = SongInfoViewModel(type: .category, values: ["value1", "value2"])
                }
                it("should correctly set the type") {
                    expect(target.type).to(equal(.category))
                }
                it("should correctly set the values") {
                    expect(target.values).to(equal(["value1", "value2"]))
                }
                describe("createSongInfoItem") {
                    it("should use the type and value") {
                        expect(target.createSongInfoItem("value")).to(equal(BrowseResultsListViewModel(category: "value")))
                    }
                }
            }
            context("type subcategory") {
                beforeEach {
                    target = SongInfoViewModel(type: .subcategory, values: ["value1", "value2"])
                }
                it("should correctly set the type") {
                    expect(target.type).to(equal(.subcategory))
                }
                it("should correctly set the values") {
                    expect(target.values).to(equal(["value1", "value2"]))
                }
                describe("createSongInfoItem") {
                    it("should use the type and value") {
                        expect(target.createSongInfoItem("value")).to(equal(BrowseResultsListViewModel(subcategory: "value")))
                    }
                }
            }
            context("type author") {
                beforeEach {
                    target = SongInfoViewModel(type: .author, values: ["value1", "value2"])
                }
                it("should correctly set the type") {
                    expect(target.type).to(equal(.author))
                }
                it("should correctly set the values") {
                    expect(target.values).to(equal(["value1", "value2"]))
                }
                describe("createSongInfoItem") {
                    it("should use the type and value") {
                        expect(target.createSongInfoItem("value")).to(equal(BrowseResultsListViewModel(author: "value")))
                    }
                }
            }
            context("type composer") {
                beforeEach {
                    target = SongInfoViewModel(type: .composer, values: ["value1", "value2"])
                }
                it("should correctly set the type") {
                    expect(target.type).to(equal(.composer))
                }
                it("should correctly set the values") {
                    expect(target.values).to(equal(["value1", "value2"]))
                }
                describe("createSongInfoItem") {
                    it("should use the type and value") {
                        expect(target.createSongInfoItem("value")).to(equal(BrowseResultsListViewModel(composer: "value")))
                    }
                }
            }
            context("type key") {
                beforeEach {
                    target = SongInfoViewModel(type: .key, values: ["value1", "value2"])
                }
                it("should correctly set the type") {
                    expect(target.type).to(equal(.key))
                }
                it("should correctly set the values") {
                    expect(target.values).to(equal(["value1", "value2"]))
                }
                describe("createSongInfoItem") {
                    it("should use the type and value") {
                        expect(target.createSongInfoItem("value")).to(equal(BrowseResultsListViewModel(key: "value")))
                    }
                }
            }
            context("type time") {
                beforeEach {
                    target = SongInfoViewModel(type: .time, values: ["value1", "value2"])
                }
                it("should correctly set the type") {
                    expect(target.type).to(equal(.time))
                }
                it("should correctly set the values") {
                    expect(target.values).to(equal(["value1", "value2"]))
                }
                describe("createSongInfoItem") {
                    it("should use the type and value") {
                        expect(target.createSongInfoItem("value")).to(equal(BrowseResultsListViewModel(time: "value")))
                    }
                }
            }
            context("type meter") {
                beforeEach {
                    target = SongInfoViewModel(type: .meter, values: ["value1", "value2"])
                }
                it("should correctly set the type") {
                    expect(target.type).to(equal(.meter))
                }
                it("should correctly set the values") {
                    expect(target.values).to(equal(["value1", "value2"]))
                }
                describe("createSongInfoItem") {
                    it("should use the type and value") {
                        expect(target.createSongInfoItem("value")).to(equal(BrowseResultsListViewModel(meter: "value")))
                    }
                }
            }
            context("type scriptures") {
                beforeEach {
                    target = SongInfoViewModel(type: .scriptures, values: ["value1", "value2"])
                }
                it("should correctly set the type") {
                    expect(target.type).to(equal(.scriptures))
                }
                it("should correctly set the values") {
                    expect(target.values).to(equal(["value1", "value2"]))
                }
                describe("createSongInfoItem") {
                    it("should use the type and value") {
                        expect(target.createSongInfoItem("value")).to(equal(BrowseResultsListViewModel(scriptures: "value")))
                    }
                }
            }
            context("type hymnCode") {
                beforeEach {
                    target = SongInfoViewModel(type: .hymnCode, values: ["value1", "value2"])
                }
                it("should correctly set the type") {
                    expect(target.type).to(equal(.hymnCode))
                }
                it("should correctly set the values") {
                    expect(target.values).to(equal(["value1", "value2"]))
                }
                describe("createSongInfoItem") {
                    it("should use the type and value") {
                        expect(target.createSongInfoItem("value")).to(equal(BrowseResultsListViewModel(hymnCode: "value")))
                    }
                }
            }
        }
    }
}
