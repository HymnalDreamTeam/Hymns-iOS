import Mockingbird
import Nimble
import Quick
import StoreKit
@testable import Hymns

class DonationViewModelSpec: AsyncSpec {

    override class func spec() {
        describe("DonationViewModel") {
            var coffeeDonation1: CoffeeDonationMock!
            var coffeeDonation2: CoffeeDonationMock!
            var coffeeDonation3: CoffeeDonationMock!
            var target: DonationViewModel!
            beforeEach {
                coffeeDonation1 = mock(CoffeeDonation.self)
                given(coffeeDonation1.id) ~> "donation_coffee_1"
                coffeeDonation2 = mock(CoffeeDonation.self)
                given(coffeeDonation2.id) ~> "donation_coffee_5"
                coffeeDonation3 = mock(CoffeeDonation.self)
                given(coffeeDonation3.id) ~> "donation_coffee_10"
            }
            describe("initialize") {
                var coffeeDonation4: CoffeeDonationMock!
                context("with recognized and unrecognized ids") {
                    beforeEach {
                        coffeeDonation4 = mock(CoffeeDonation.self)
                        given(coffeeDonation4.id) ~> "unidentified"
                        target = DonationViewModel(coffeeDonations: [coffeeDonation3, coffeeDonation1, coffeeDonation2, coffeeDonation4],
                                                   resultBinding: .constant(nil))
                    }
                    it("should skip the unidentified id and store the identfied ones in sorted order") {
                        expect(target.coffeeDonations).to(equal([.donationCoffee1, .donationCoffee5, .donationCoffee10]))
                    }
                }
                describe("initiatePurchase") {
                    var result: Result<SettingsToastItem, Error>?
                    beforeEach {
                        target = DonationViewModel(coffeeDonations: [coffeeDonation1], resultBinding: .init(get: {
                            result
                        }, set: { newResult in
                            result = newResult
                        }))
                    }
                    context("with unrecognized coffee donation") {
                        beforeEach {
                            await target.initiatePurchase(donationType: .donationCoffee5)
                        }
                        it("should not initiate any purchase") {
                            verify(await coffeeDonation1.purchase(options: any())).wasNeverCalled()
                            verify(await coffeeDonation2.purchase(options: any())).wasNeverCalled()
                            verify(await coffeeDonation3.purchase(options: any())).wasNeverCalled()
                        }
                        it("should set the result to sucess.other") {
                            expect(target.resultBinding).toNot(beNil())
                            expect(target.resultBinding.debugDescription).to(equal("Optional(Swift.Result<Hymns.SettingsToastItem, Swift.Error>.success(Hymns.SettingsToastItem.donate(Hymns.DonationResult.other)))"))
                        }
                    }
                    context("with recognized coffee donation") {
                        context("purchase successful") {
                            beforeEach {
                                given(await coffeeDonation1.purchase(options: [])) ~> { _ in .success }
                                await target.initiatePurchase(donationType: .donationCoffee1)
                            }
                            it("should set the result to sucess.success") {
                                expect(target.resultBinding).toNot(beNil())
                                expect(target.resultBinding.debugDescription).to(equal("Optional(Swift.Result<Hymns.SettingsToastItem, Swift.Error>.success(Hymns.SettingsToastItem.donate(Hymns.DonationResult.success)))"))
                            }
                        }
                        context("purchase cancelled") {
                            beforeEach {
                                given(await coffeeDonation1.purchase(options: [])) ~> { _ in .userCancelled }
                                await target.initiatePurchase(donationType: .donationCoffee1)
                            }
                            it("should set the result to sucess.success") {
                                expect(target.resultBinding).toNot(beNil())
                                expect(target.resultBinding.debugDescription).to(equal("Optional(Swift.Result<Hymns.SettingsToastItem, Swift.Error>.success(Hymns.SettingsToastItem.donate(Hymns.DonationResult.cancelled)))"))
                            }
                        }
                        context("purchase pending") {
                            beforeEach {
                                given(await coffeeDonation1.purchase(options: [])) ~> { _ in .pending }
                                await target.initiatePurchase(donationType: .donationCoffee1)
                            }
                            it("should set the result to sucess.success") {
                                expect(target.resultBinding).toNot(beNil())
                                expect(target.resultBinding.debugDescription).to(equal("Optional(Swift.Result<Hymns.SettingsToastItem, Swift.Error>.success(Hymns.SettingsToastItem.donate(Hymns.DonationResult.other)))"))
                            }
                        }
                        context("purchase other") {
                            beforeEach {
                                given(await coffeeDonation1.purchase(options: [])) ~> { _ in .other }
                                await target.initiatePurchase(donationType: .donationCoffee1)
                            }
                            it("should set the result to sucess.success") {
                                expect(target.resultBinding).toNot(beNil())
                                expect(target.resultBinding.debugDescription).to(equal("Optional(Swift.Result<Hymns.SettingsToastItem, Swift.Error>.success(Hymns.SettingsToastItem.donate(Hymns.DonationResult.other)))"))
                            }
                        }
                        context("purchase error") {
                            beforeEach {
                                // Need to stub throwing async functions like this
                                // https://github.com/birdrides/mockingbird/issues/302
                                givenSwift(await coffeeDonation1.purchase(options: [])).will { _ in throw Product.PurchaseError.productUnavailable }
                                await target.initiatePurchase(donationType: .donationCoffee1)
                            }
                            it("should set the result to sucess.success") {
                                expect(target.resultBinding).toNot(beNil())
                                expect(target.resultBinding.debugDescription).to(equal("Optional(Swift.Result<Hymns.SettingsToastItem, Swift.Error>.failure(StoreKit.Product.PurchaseError.productUnavailable))"))
                            }
                        }
                    }
                }
            }
        }
    }
}
