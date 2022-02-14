import SwiftEventBus
import SwiftUI

struct SoundCloudView: View {

    @Binding private var dialogModel: DialogViewModel<AnyView>?
    @Binding private var soundCloudPlayer: SoundCloudPlayerViewModel?

    @ObservedObject private var viewModel: SoundCloudViewModel

    init(dialogModel: Binding<DialogViewModel<AnyView>?>,
         soundCloudPlayer: Binding<SoundCloudPlayerViewModel?>,
         viewModel: SoundCloudViewModel) {
        self._dialogModel = dialogModel
        self._soundCloudPlayer = soundCloudPlayer
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Button(action: {
                        self.dialogModel = nil
                    }, label: {
                        Text("Exit", comment: "Exit the SoundCloud player.").padding()
                    })
                    Spacer()
                    if self.viewModel.showMinimizeCaret {
                        Button(action: {
                            self.soundCloudPlayer = SoundCloudPlayerViewModel(dialogModel: self.$dialogModel, title: self.viewModel.$title)
                            self.dialogModel?.opacity = 0
                        }, label: {
                            Image(systemName: "chevron.down").accessibility(label: Text("Minimize SoundCloud", comment: "A11y label for minimzing SoundCloud.")).padding(.horizontal)
                        }).transformAnchorPreference(key: ToolTipPreferenceKey.self,
                                                     value: .bounds,
                                                     transform: { (value: inout ToolTipPreferenceData, anchor: Anchor<CGRect>) in
                                                        value.indicatorAnchor = anchor
                        })
                    }
                }.overlay(Image("soundcloud_banner"))
                SoundCloudWebView(viewModel: viewModel).maxSize()
            }
            ToolTipView(tapAction: {}, label: {
                HStack(alignment: .center, spacing: CGFloat.zero) {
                    Image(systemName: "xmark").padding()
                    Text("DO_NOT_TRANSLATE: Invisible tool tip used for calculating tool tip size. Not actually used.").font(.caption).padding(.trailing)
                }
            }, configuration: ToolTipConfiguration(cornerRadius: 10, arrowPosition: ToolTipConfiguration.ArrowPosition(midX: 0.5, alignmentType: .percentage), arrowHeight: 7))
                .transformAnchorPreference(key: ToolTipPreferenceKey.self,
                                           value: .bounds,
                                           transform: { (value: inout ToolTipPreferenceData, anchor: Anchor<CGRect>) in
                                            value.toolTipAnchor = anchor
                }).opacity(0) // Create an invisible tool tip view in order to calculate the size.
        }.overlayPreferenceValue(ToolTipPreferenceKey.self) { toolTipPreferenceData in
            if self.viewModel.showMinimizeToolTip {
                GeometryReader { geometry in
                    self.createToolTip(geometry, toolTipPreferenceData)
                }
            }
        }.onAppear {
            // Modal is up, so disable song swiping
            SwiftEventBus.post(DisplayHymnContainerViewModel.songSwipableEvent, sender: false)
        }.onDisappear {
            // Modal is up, so enable song swiping
            SwiftEventBus.post(DisplayHymnContainerViewModel.songSwipableEvent, sender: true)
        }
    }

    private func createToolTip(_ geometry: GeometryProxy, _ data: ToolTipPreferenceData) -> some View {
        guard let toolTipAnchor = data.toolTipAnchor, let indicatorAnchor = data.indicatorAnchor else {
            return EmptyView().eraseToAnyView()
        }

        let toolTipSize = geometry[toolTipAnchor].size
        let indicatorPoint = geometry[indicatorAnchor]

        return
            ToolTipView(tapAction: {
                self.viewModel.dismissToolTip()
            }, label: {
                HStack(alignment: .center, spacing: CGFloat.zero) {
                    Image(systemName: "xmark").padding()
                    Text("Tap to keep playing song in background", comment: "Tooltip text for minimizing SoundCloud and to keep the song playing.").font(.caption).padding(.trailing)
                }
            }, configuration: ToolTipConfiguration(
                cornerRadius: 10,
                arrowPosition: ToolTipConfiguration.ArrowPosition(midX: toolTipSize.width - (indicatorPoint.maxX - indicatorPoint.minX)/2 + 7, alignmentType: .offset),
                arrowHeight: 7))
                .offset(x: indicatorPoint.maxX - toolTipSize.width - 7, y: indicatorPoint.maxY + 7).eraseToAnyView()
    }
}

struct ToolTipPreferenceData {

    /**
     * Anchor of the tool tip itself.
     */
    var toolTipAnchor: Anchor<CGRect>?

    /**
     * Anchor that we want the tool tip to point to.
     */
    var indicatorAnchor: Anchor<CGRect>?
}

struct ToolTipPreferenceKey: PreferenceKey {
    static var defaultValue: ToolTipPreferenceData = ToolTipPreferenceData()

    static func reduce(value: inout ToolTipPreferenceData, nextValue: () -> ToolTipPreferenceData) {
        if let toolTipAnchor = nextValue().toolTipAnchor {
            value.toolTipAnchor = toolTipAnchor
        }

        if let indicatorAnchor = nextValue().indicatorAnchor {
            value.indicatorAnchor = indicatorAnchor
        }
    }
}

#if DEBUG
struct SoundCloudView_Previews: PreviewProvider {
    static var previews: some View {

        let defaultStateViewModel = SoundCloudViewModel(url: URL(string: "https://soundcloud.com/anthonyjohntunes/broken-vessels-amazing-grace-hillsong-live-cover")!)
        let defaultState = SoundCloudView(dialogModel: .constant(nil), soundCloudPlayer: .constant(nil), viewModel: defaultStateViewModel)

        let minimizeCaretViewModel = SoundCloudViewModel(url: URL(string: "https://www.example.com")!)
        minimizeCaretViewModel.showMinimizeCaret = true
        let minimizeCaret = SoundCloudView(dialogModel: .constant(nil), soundCloudPlayer: .constant(nil), viewModel: minimizeCaretViewModel)

        let minimizeCaretAndToolTipViewModel = SoundCloudViewModel(url: URL(string: "https://www.example.com")!)
        minimizeCaretAndToolTipViewModel.showMinimizeCaret = true
        minimizeCaretAndToolTipViewModel.showMinimizeToolTip = true
        let minimizeCaretAndToolTip = SoundCloudView(dialogModel: .constant(nil), soundCloudPlayer: .constant(nil), viewModel: minimizeCaretAndToolTipViewModel)

        return
            Group {
                defaultState.previewDisplayName("default state")
                minimizeCaret.previewDisplayName("minimize caret is shown")
                minimizeCaretAndToolTip.previewDisplayName("minimize caret and tooltip is shown")
        }
    }
}
#endif
