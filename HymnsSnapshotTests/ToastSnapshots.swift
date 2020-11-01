import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class ToastSnapshots: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_top() {
        let toast =
            Text("Content here")
                .maxSize()
                .toast(item: .constant(TagColor.blue), options: ToastOptions(alignment: .top)) { _ -> AnyView in
                    Text("Toast text").padding()
                        .eraseToAnyView()
        }
        assertVersionedSnapshot(matching: toast, as: .swiftUiImage())
    }

    func test_center() {
        let toast =
            Text("Content here")
                .maxSize()
                .toast(item: .constant(TagColor.blue), options: ToastOptions(alignment: .center)) { _ -> AnyView in
                    VStack {
                        Text("Toast line 1")
                        Text("Toast line 2")
                    }.padding()
                        .eraseToAnyView()
        }
        assertVersionedSnapshot(matching: toast, as: .swiftUiImage())
    }

    func test_bottom() {
        let toast =
            Text("Content here")
                .maxSize()
                .toast(item: .constant(TagColor.blue), options: ToastOptions(alignment: .bottom)) { _ -> AnyView in
                    HStack {
                        Image(systemName: "checkmark").foregroundColor(.green).padding()
                        Text("Toast text").padding(.trailing)
                    }
                    .eraseToAnyView()
        }
        assertVersionedSnapshot(matching: toast, as: .swiftUiImage())
    }

    func test_bottomWithoutBackdrop() {
        let toast =
            Text("Content here")
                .maxSize()
                .toast(item: .constant(TagColor.blue), options: ToastOptions(alignment: .bottom, backdrop: false)) { _ -> AnyView in
                    HStack {
                        Image(systemName: "checkmark").foregroundColor(.green).padding()
                        Text("Toast text").padding(.trailing)
                    }
                    .eraseToAnyView()
        }
        assertVersionedSnapshot(matching: toast, as: .swiftUiImage())
    }

    func test_darkMode() {
        let toast =
            Text("Content here")
                .maxSize()
                .toast(item: .constant(TagColor.blue), options: ToastOptions(alignment: .bottom)) { _ -> AnyView in
                    HStack {
                        Image(systemName: "checkmark").foregroundColor(.green).padding()
                        Text("Toast text").padding(.trailing)
                    }
                    .eraseToAnyView()
        }.background(Color(.systemBackground)).environment(\.colorScheme, .dark)
        assertVersionedSnapshot(matching: toast, as: .swiftUiImage())
    }

    func test_darkModeWithoutBackdrop() {
        let toast =
            Text("Content here")
                .maxSize()
                .toast(item: .constant(TagColor.blue), options: ToastOptions(alignment: .bottom, backdrop: false)) { _ -> AnyView in
                    HStack {
                        Image(systemName: "checkmark").foregroundColor(.green).padding()
                        Text("Toast text").padding(.trailing)
                    }
                    .eraseToAnyView()
            }.background(Color(.systemBackground)).environment(\.colorScheme, .dark)
        assertVersionedSnapshot(matching: toast, as: .swiftUiImage())
    }
}
