import SwiftUI

struct ToolTipModifier<Label: View>: ViewModifier {

    @Binding var shouldShow: Bool

    let tapAction: () -> Void
    let label: () -> Label
    let configuration: ToolTipConfiguration

    init(tapAction: @escaping () -> Void,
         @ViewBuilder label: @escaping () -> Label,
         configuration: ToolTipConfiguration,
         shouldShow: Binding<Bool>) {
        self.tapAction = tapAction
        self.label = label
        self.configuration = configuration
        self._shouldShow = shouldShow
    }

    func body(content: Content) -> some View {
        content
            .alignmentGuide(.toolTipHorizontalAlignment, computeValue: { dimens -> CGFloat in
                dimens[HorizontalAlignment.center] // middle of tool tip to middle of view
            })
            .alignmentGuide(configuration.verticalAlignmentGuide.toolTipAlignment, computeValue: { dimens -> CGFloat in
                dimens[configuration.verticalAlignmentGuide.viewDimensionAlignment]
            })
            .overlay(alignment: Alignment(horizontal: .toolTipHorizontalAlignment,
                                          vertical: configuration.verticalAlignmentGuide.toolTipAlignment)) {
                if shouldShow {
                    ToolTipView(tapAction: tapAction, label: label, configuration: configuration)
                        .alignmentGuide(.toolTipHorizontalAlignment, computeValue: { dimens -> CGFloat in
                            dimens[HorizontalAlignment.center]
                        })
                }
            }.zIndex(1)
    }
}

extension View {
    func toolTip<Label: View>(tapAction: @escaping () -> Void,
                              @ViewBuilder label: @escaping () -> Label,
                              configuration: ToolTipConfiguration,
                              shouldShow: Binding<Bool>) -> some View {
        self.modifier(ToolTipModifier(tapAction: tapAction, label: label, configuration: configuration, shouldShow: shouldShow))
    }
}

/**
 * Creates a rounded rectangle shape with a little arrow on the top to serve as a tool tip.
 */
struct ToolTipShape: Shape {

    private let cornerRadius: CGFloat
    private let toolTipMidX: CGFloat
    private let toolTipHeight: CGFloat

    init(cornerRadius: CGFloat, toolTipMidX: CGFloat, toolTipHeight: CGFloat = 40) {
        self.cornerRadius = cornerRadius
        self.toolTipMidX = toolTipMidX
        self.toolTipHeight = toolTipHeight
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            let width = rect.width
            let height = rect.height

            // Starting point
            path.move(to: CGPoint(x: cornerRadius, y: 0))

            // Top line (including caret)
            path.addLine(to: CGPoint(x: toolTipMidX - toolTipHeight, y: 0))
            path.addLine(to: CGPoint(x: toolTipMidX, y: -toolTipHeight)) // Tool tip caret
            path.addLine(to: CGPoint(x: toolTipMidX + toolTipHeight, y: 0)) // Tool tip caret
            path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))

            // Top-right corner
            path.addArc(center: CGPoint(x: width - cornerRadius, y: 0 + cornerRadius),
                        radius: cornerRadius, startAngle: .degrees(270), endAngle: .degrees(0),
                        clockwise: false)

            // Right line
            path.addLine(to: CGPoint(x: width, y: height - cornerRadius))

            // Bottom-right corner
            path.addArc(center: CGPoint(x: width - cornerRadius, y: height - cornerRadius),
                        radius: cornerRadius, startAngle: .degrees(0), endAngle: .degrees(90),
                        clockwise: false)

            // Bottom line
            path.addLine(to: CGPoint(x: cornerRadius, y: height))

            // Bottom-left corner
            path.addArc(center: CGPoint(x: cornerRadius, y: height - cornerRadius),
                        radius: cornerRadius, startAngle: .degrees(90), endAngle: .degrees(180),
                        clockwise: false)

            // Left line
            path.addLine(to: CGPoint(x: 0, y: cornerRadius + 0))

            // Top-left corner
            path.addArc(center: CGPoint(x: cornerRadius, y: 0 + cornerRadius),
                        radius: cornerRadius, startAngle: .degrees(180), endAngle: .degrees(270),
                        clockwise: false)

            path.closeSubpath()
        }
    }
}

#if DEBUG
struct ToolTipShape_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ToolTipShape(cornerRadius: 15, toolTipMidX: 300).fill().previewDisplayName("filled tooltip")
            ToolTipShape(cornerRadius: 15, toolTipMidX: 300).stroke().previewDisplayName("outlined tooltip")
        }
    }
}
#endif

// Configuration of the tool tip, including arrow height, arrow position, and tool tip corner radius.
struct ToolTipConfiguration {
    /// Alignment of the tool tip with respect to the content
    let alignment: Alignment
    let cornerRadius: CGFloat
    let arrowPosition: ArrowPosition
    let arrowHeight: CGFloat

    init(alignment: Alignment = .bottom, cornerRadius: CGFloat, arrowPosition: ArrowPosition, arrowHeight: CGFloat) {
        self.alignment = alignment
        self.cornerRadius = cornerRadius
        self.arrowPosition = arrowPosition
        self.arrowHeight = arrowHeight
    }

    enum Alignment {
        case top // Show tool tip above the content view
        case bottom // Show tool tip below the content view
    }

    var verticalAlignmentGuide: (toolTipAlignment: VerticalAlignment, viewDimensionAlignment: VerticalAlignment) {
        switch alignment {
        case .top:
            return (toolTipAlignment: .bottom, viewDimensionAlignment: .top) // align top of tool tip to bottom of view
        case .bottom:
            return (toolTipAlignment: .top, viewDimensionAlignment: .bottom) // align bottom of tool tip to top of view
        }
    }

    struct ArrowPosition {
        /**
         * Horizontal midpoint of the tool tip arrow
         */
        let midX: CGFloat

        /**
         * What the horizontal midpoint of the tool tip arrow refers to.
         */
        let alignmentType: AlignmentType

        // Different ways to align the tool tip arrow
        enum AlignmentType {
            /**
             * Horizontal midpoint of the tool tip arrow will be a percentage of the size of the entire tool tip box
             */
            case percentage

            /**
             * Horizontal midpoint of the tool tip arrow will be an offset based on the starting edge of the tool tip box
             */
            case offset
        }
    }
}

struct ToolTipView<Label>: View where Label: View {

    let tapAction: () -> Void
    let label: Label
    let configuration: ToolTipConfiguration

    public init(tapAction: @escaping () -> Void, @ViewBuilder label: () -> Label, configuration: ToolTipConfiguration) {
        self.tapAction = tapAction
        self.label = label()
        self.configuration = configuration
    }

    var body: some View {
        Button(action: {
            self.tapAction()
        }, label: {
            self.label.foregroundColor(.white)
        }).background( GeometryReader { geometry in
            ToolTipShape(cornerRadius: self.configuration.cornerRadius,
                         toolTipMidX: self.configuration.arrowPosition.alignmentType == .offset ?
                            self.configuration.arrowPosition.midX :
                            self.configuration.arrowPosition.midX * geometry.size.width,
                         toolTipHeight: self.configuration.arrowHeight).fill(Color.accentColor)
        })
    }
}

#if DEBUG
struct ToolTipView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ToolTipView(tapAction: {}, label: {
                Text("%_PREVIEW_% tool tip text").padding()
            }, configuration:
                ToolTipConfiguration(cornerRadius: 10,
                                     arrowPosition: ToolTipConfiguration.ArrowPosition(midX: 30, alignmentType: .offset),
                                     arrowHeight: 7))
                .previewDisplayName("offset arrow positioning")

            ToolTipView(tapAction: {}, label: {
                Text("%_PREVIEW_% tool tip text").padding()
            }, configuration:
                ToolTipConfiguration(cornerRadius: 10,
                                     arrowPosition: ToolTipConfiguration.ArrowPosition(midX: 0.7, alignmentType: .percentage),
                                     arrowHeight: 7))
                .previewDisplayName("percentage arrow positioning")
        }.previewLayout(.fixed(width: 250, height: 100))
    }
}
#endif

extension HorizontalAlignment {
    private enum ToolTipHorizontal: AlignmentID {
        static func defaultValue(in dimens: ViewDimensions) -> CGFloat {
            dimens[.leading]
        }
    }

    static let toolTipHorizontalAlignment = HorizontalAlignment(ToolTipHorizontal.self)
}

extension Alignment {
    static let toolTipAlignment = Alignment(horizontal: .toolTipHorizontalAlignment, vertical: .top)
}
