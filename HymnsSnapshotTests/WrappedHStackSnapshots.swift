import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class WrappedHStackSnapshots: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_severalItemsInVStack() {
        let severalItems = Binding.constant([
            "Multiline really relaly long tag name that takes up many lines. So many lines, in fact, that it could be three lines.",
            "Nintendo", "XBox", "PlayStation", "Playstation 2", "Playstaition 3", "Stadia", "Oculus"])
        let view = ScrollView {
            VStack {
                Text("Title").font(.headline)
                WrappedHStack(items: severalItems) { item in
                    Text(item)
                }
                Button("Click me") {}
            }
        }
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }

    func test_hundredItemsInScrollView() {
        let hundredItems = Binding.constant(Array(1...100).map { number -> String in
            return "Playstation \(number)!!"
        })
        let view = ScrollView {
            VStack {
                Text("Title").font(.headline)
                WrappedHStack(items: hundredItems) { item in
                    Text(item)
                }
                Button("Click me") {}
            }
        }
        assertVersionedSnapshot(matching: view, as: .swiftUiImage())
    }
}
