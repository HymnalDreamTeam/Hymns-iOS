import SwiftUI

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

struct ToolTipConfiguration {
    let cornerRadius: CGFloat
    let arrowPosition: ArrowPosition
    let arrowHeight: CGFloat

    struct ArrowPosition {
        /**
         * Horizontal midpoint of the tool tip arrow
         */
        let midX: CGFloat

        /**
         * What the horizontal midpoint of the tool tip arrow refers to.
         */
        let alignmentType: AlignmentType
    }

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

extension VerticalAlignment {
    private enum ToolTipVerticalAlignment: AlignmentID {
        static func defaultValue(in dimens: ViewDimensions) -> CGFloat {
            dimens[.top]
        }
    }

    static let toolTipVerticalAlignment = VerticalAlignment(ToolTipVerticalAlignment.self)
}

extension HorizontalAlignment {
    private enum ToolTipHorizontal: AlignmentID {
        static func defaultValue(in dimens: ViewDimensions) -> CGFloat {
            dimens[.leading]
        }
    }

    static let toolTipHorizontalAlignment = HorizontalAlignment(ToolTipHorizontal.self)
}

extension Alignment {
    static let toolTipAlignment = Alignment(horizontal: .toolTipHorizontalAlignment, vertical: .toolTipVerticalAlignment)
}
