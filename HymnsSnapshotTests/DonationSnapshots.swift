import SnapshotTesting
import SwiftUI
import XCTest
@testable import Hymns

// https://troz.net/post/2020/swiftui_snapshots/
class DonationHymnSnapshots: XCTestCase {

    var viewModel: DonationViewModel!

    func test_button() {
        assertVersionedSnapshot(
            matching: DonationButtonView(coffeeDonations: [], resultBinding: .constant(nil)).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_error() {
        viewModel = DonationViewModel(coffeeDonations: [CoffeeDonation](), resultBinding: .constant(nil))
        viewModel.coffeeDonations = []
        assertVersionedSnapshot(
            matching: DonationView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }

    func test_donations() {
        viewModel = DonationViewModel(coffeeDonations: [CoffeeDonation](), resultBinding: .constant(nil))
        viewModel.coffeeDonations = [.donationCoffee1, .donationCoffee5, .donationCoffee10]
        assertVersionedSnapshot(
            matching: DonationView(viewModel: viewModel).ignoresSafeArea(),
            as: .swiftUiImage())
    }
}
