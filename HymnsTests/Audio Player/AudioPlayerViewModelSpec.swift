import Combine
import Mockingbird
import Nimble
import Quick
@testable import Hymns

// swiftlint:disable:next type_body_length
class AudioPlayerViewModelSpec: QuickSpec {

    // swiftlint:disable:next function_body_length
    override class func spec() {
        describe("AudioPlayerViewModel") {
            // https://www.vadimbulavin.com/unit-testing-async-code-in-swift/
            let testQueue = DispatchQueue(label: "test_queue")
            let url = URL(string: "https://www.hymnal.net/en/hymn/h/767/f=mp3")!
            var service: HymnalNetServiceMock!
            var systemUtil: SystemUtilMock!
            var target: AudioPlayerViewModel!
            beforeEach {
                service = mock(HymnalNetService.self)
                systemUtil = mock(SystemUtil.self)
                given(systemUtil.isSmallScreen()) ~> false
                target = AudioPlayerViewModel(url: url, backgroundQueue: testQueue, mainQueue: testQueue, service: service, systemUtil: systemUtil)
            }
            context("regular screen size") {
                it("should show the speed adjuster") {
                    expect(target.showSpeedAdjuster).to(beTrue())
                }
            }
            context("small screen size") {
                it("should not show the speed adjuster") {
                    given(systemUtil.isSmallScreen()) ~> true
                    target = AudioPlayerViewModel(url: url, backgroundQueue: testQueue, mainQueue: testQueue, service: service, systemUtil: systemUtil)
                    expect(target.showSpeedAdjuster).to(beFalse())
                }
            }
            describe("toggle repeat") {
                it("should toggle the shouldRepeat variable") {
                    expect(target.shouldRepeat).to(beFalse())
                    target.toggleRepeat()
                    expect(target.shouldRepeat).to(beTrue())
                    target.toggleRepeat()
                    expect(target.shouldRepeat).to(beFalse())
                }
            }
            context("successfully preload music") {
                beforeEach {
                    let path = Bundle(for: AudioPlayerViewModelSpec.self).path(forResource: "e0767_i", ofType: "mp3")!
                    // swiftlint:disable:next force_try
                    let data = try! Data(contentsOf: URL(fileURLWithPath: path))
                    given(service.getData(url)) ~> { _ in
                        Just(data).mapError({ _ -> ErrorType in
                            // This will never be triggered.
                        }).eraseToAnyPublisher()
                    }

                    target.load()
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                    verify(service.getData(url)).wasCalled(1)
                }
                it("should set the delegate to itself") {
                    expect(target.player!.delegate).to(be(target))
                }
                it("should set the song duration") {
                    expect(target.songDuration).to(beGreaterThan(16))
                }
                describe("playing the music") {
                    beforeEach {
                        clearInvocations(on: service)
                        target.play()
                    }
                    it("should not call the service") {
                        verify(service.getData(any())).wasNeverCalled()
                    }
                    it("should play the music") {
                        expect(target.playbackState).to(equal(.playing))
                        expect(target.player!.isPlaying).to(beTrue())
                    }
                    describe("pause") {
                        beforeEach {
                            target.pause()
                        }
                        it("should pause the playback") {
                            expect(target.playbackState).to(equal(.stopped))
                            expect(target.player!.isPlaying).to(beFalse())
                        }
                        describe("play again") {
                            beforeEach {
                                target.play()
                            }
                            it("should not call the service") {
                                verify(service.getData(any())).wasNeverCalled()
                            }
                            it("should play the music") {
                                expect(target.playbackState).to(equal(.playing))
                                expect(target.player!.isPlaying).to(beTrue())
                            }
                        }
                    }
                    describe("increase audio speed") {
                        beforeEach {
                            target.increaseSpeed()
                        }
                        it("should increase the speed by 0.1") {
                            expect(target.player!.rate).to(equal(1.1))
                            expect(target.currentSpeed).to(equal(1.1))
                        }
                    }
                    describe("decrease audio speed") {
                        beforeEach {
                            target.decreaseSpeed()
                        }
                        it("should decrease the speed by 0.1") {
                            expect(target.player!.rate).to(equal(0.9))
                            expect(target.currentSpeed).to(equal(0.9))
                        }
                    }
                    describe("reset") {
                        beforeEach {
                            target.seek(to: 5)
                            target.reset()
                            testQueue.sync {}
                            testQueue.sync {}
                            testQueue.sync {}
                        }
                        it("should set the current time to 0") {
                            expect(target.currentTime).to(equal(0))
                        }
                        it("should set repeat to false") {
                            expect(target.shouldRepeat).to(beFalse())
                        }
                        it("should stop the playback") {
                            expect(target.playbackState).to(equal(.stopped))
                            expect(target.player!.isPlaying).to(beFalse())
                        }
                        it("should reload the song") {
                            verify(service.getData(url)).wasCalled(1)
                        }
                        describe("play again") {
                            beforeEach {
                                reset(service)
                                target.play()
                            }
                            it("should not call the service") {
                                verify(service.getData(any())).wasNeverCalled()
                            }
                            it("should play the music") {
                                expect(target.playbackState).to(equal(.playing))
                                expect(target.player!.isPlaying).to(beTrue())
                            }
                        }
                    }
                    describe("seek to a time") {
                        beforeEach {
                            target.seek(to: 10)
                        }
                        it("should set current time to the seek time") {
                            expect(target.currentTime).to(equal(10))
                            expect(target.player!.currentTime).to(equal(10))
                        }
                    }
                    describe("rewind") {
                        context("playback is paused") {
                            it("should still work") {
                                target.pause()
                                target.seek(to: AudioPlayerViewModel.seekDuration)
                                target.rewind()
                                expect(target.player!.currentTime).to(equal(0))
                                expect(target.currentTime).to(equal(0))
                            }
                        }
                        context("rewound time becomes negative") {
                            it("should rewind to 0") {
                                target.seek(to: 0)
                                target.rewind()
                                expect(target.player!.currentTime).to(equal(0))
                                expect(target.currentTime).to(equal(0))
                            }
                        }
                        context("rewound time is positive") {
                            it("should rewind by \(AudioPlayerViewModel.seekDuration) seconds") {
                                target.seek(to: 5)
                                target.rewind()
                                expect(target.player!.currentTime).to(equal(5 - AudioPlayerViewModel.seekDuration))
                                expect(target.currentTime).to(equal(5 - AudioPlayerViewModel.seekDuration))
                            }
                        }
                    }
                    describe("fast forward") {
                        context("playback is paused") {
                            it("should still work") {
                                target.pause()
                                target.seek(to: 0)
                                target.fastForward()
                                expect(target.player!.currentTime).to(equal(AudioPlayerViewModel.seekDuration))
                                expect(target.currentTime).to(equal(AudioPlayerViewModel.seekDuration))
                            }
                        }
                        context("fast forwarded time stays song duration") {
                            it("should fast forward by \(AudioPlayerViewModel.seekDuration) seconds") {
                                target.seek(to: 5)
                                target.fastForward()
                                expect(target.player!.currentTime).to(equal(5 + AudioPlayerViewModel.seekDuration))
                                expect(target.currentTime).to(equal(5 + AudioPlayerViewModel.seekDuration))
                            }
                        }
                    }
                }
            }
            describe("do not preload music") {
                context("unsuccessful music fetch") {
                    beforeEach {
                        let path = Bundle(for: AudioPlayerViewModelSpec.self).path(forResource: "e0767_i", ofType: "mp3")!
                        // swiftlint:disable:next force_try
                        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
                        given(service.getData(url)) ~> { _ in
                            Just(data)
                                .tryMap({ _ -> Data in
                                    throw URLError(.badServerResponse)
                                }).mapError({ _ -> ErrorType in
                                    .data(description: "forced data error")
                                }).eraseToAnyPublisher()
                        }

                        target.play()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        verify(service.getData(url)).wasCalled(1)
                    }
                    it("should stolp the playback") {
                        expect(target.playbackState).to(equal(.stopped))
                        expect(target.player).to(beNil())
                    }
                }
                context("successful music fetch") {
                    beforeEach {
                        let path = Bundle(for: AudioPlayerViewModelSpec.self).path(forResource: "e0767_i", ofType: "mp3")!
                        // swiftlint:disable:next force_try
                        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
                        given(service.getData(url)) ~> { _ in
                            Just(data).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }

                        target.play()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                        verify(service.getData(url)).wasCalled(1)
                    }
                    it("should play the music") {
                        expect(target.playbackState).to(equal(.playing))
                        expect(target.player!.isPlaying).to(beTrue())
                    }
                    describe("pause") {
                        beforeEach {
                            target.pause()
                        }
                        it("should pause the playback") {
                            expect(target.playbackState).to(equal(.stopped))
                            expect(target.player!.isPlaying).to(beFalse())
                        }
                        describe("play again") {
                            beforeEach {
                                reset(service)
                                target.play()
                            }
                            it("should not call the service") {
                                verify(service.getData(any())).wasNeverCalled()
                            }
                            it("should play the music") {
                                expect(target.playbackState).to(equal(.playing))
                                expect(target.player!.isPlaying).to(beTrue())
                            }
                        }
                    }
                    describe("playback finished") {
                        context("should repeat") {
                            beforeEach {
                                target.shouldRepeat = true
                                target.audioPlayerDidFinishPlaying(target.player!, successfully: true)
                            }
                            it("should play from the beginning") {
                                expect(target.player!.currentTime).to(equal(TimeInterval.zero))
                                expect(target.playbackState).to(equal(.playing))
                            }
                        }
                        context("should not repeat") {
                            beforeEach {
                                target.shouldRepeat = false
                                target.audioPlayerDidFinishPlaying(target.player!, successfully: true)
                            }
                            it("should stop playing") {
                                expect(target.player!.currentTime).to(equal(TimeInterval.zero))
                                expect(target.playbackState).to(equal(.stopped))
                                expect(target.player!.isPlaying).to(beFalse())
                            }
                        }
                    }
                }
            }
        }
    }
}
