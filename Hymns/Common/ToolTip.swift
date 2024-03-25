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
            .background(GeometryReader { geo in
                // Use invisible background to calculate and save the container's size
                Color.clear.preference(key: ToolTipContainerKey.self, value: geo.size)
            }).alignmentGuide(.toolTipHorizontalAlignment, computeValue: { dimens -> CGFloat in
                dimens[HorizontalAlignment.center] // middle of tool tip to middle of view
            })
            .alignmentGuide(configuration.verticalAlignmentGuide.toolTipAlignment, computeValue: { dimens -> CGFloat in
                dimens[configuration.verticalAlignmentGuide.viewDimensionAlignment]
            }).overlayPreferenceValue(
                ToolTipContainerKey.self,
                alignment: Alignment(horizontal: .toolTipHorizontalAlignment,
                                     vertical: configuration.verticalAlignmentGuide.toolTipAlignment),
                { containerSize in
                    if shouldShow {
                        ToolTipView(tapAction: tapAction, label: label, configuration: configuration)
                            .alignmentGuide(.toolTipHorizontalAlignment, computeValue: { dimens -> CGFloat in
                                dimens[HorizontalAlignment.center]
                            }).frame(width: configuration.bodyConfiguration.size(containerSize: containerSize).width,
                                     height: configuration.bodyConfiguration.size(containerSize: containerSize).height)
                    }
                }).zIndex(1)
    }
}

/// Preference key for storing the size of the tooltip's container.
struct ToolTipContainerKey: PreferenceKey {
    static var defaultValue: CGSize = CGSize(width: 0, height: 0)

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = CGSize(width: value.width + nextValue().width, height: value.height + nextValue().height)
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
    private let direction: Direction
    private let toolTipMidX: CGFloat
    private let toolTipHeight: CGFloat

    /// Direction the arrow is pointing.
    enum Direction {
        case up // Show arrow pointing up
        case down // Show arrow pointing down
    }

    init(cornerRadius: CGFloat, direction: Direction, toolTipMidX: CGFloat, toolTipHeight: CGFloat = 40) {
        self.cornerRadius = cornerRadius
        self.direction = direction
        self.toolTipMidX = toolTipMidX
        self.toolTipHeight = toolTipHeight
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            let width = rect.width
            let height = rect.height

            // Starting point
            path.move(to: CGPoint(x: cornerRadius, y: 0))

            if direction == .up {
                // Top line (including caret)
                path.addLine(to: CGPoint(x: toolTipMidX - toolTipHeight, y: 0))
                path.addLine(to: CGPoint(x: toolTipMidX, y: -toolTipHeight)) // Tool tip caret
                path.addLine(to: CGPoint(x: toolTipMidX + toolTipHeight, y: 0)) // Tool tip caret
                path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
            }

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

            if direction == .down {
                // Bottom line (including caret)
                path.addLine(to: CGPoint(x: toolTipMidX - toolTipHeight, y: height))
                path.addLine(to: CGPoint(x: toolTipMidX, y: height + toolTipHeight)) // Tool tip caret
                path.addLine(to: CGPoint(x: toolTipMidX, y: height + toolTipHeight)) // Tool tip caret
                path.addLine(to: CGPoint(x: toolTipMidX + toolTipHeight, y: height)) // Tool tip caret
                path.addLine(to: CGPoint(x: width - cornerRadius, y: height))
            }
            
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
            ToolTipShape(cornerRadius: 15, direction: .up, toolTipMidX: 300).fill().previewDisplayName("filled tooltip")
            ToolTipShape(cornerRadius: 15, direction: .up, toolTipMidX: 300).stroke().previewDisplayName("outlined tooltip")
            ToolTipShape(cornerRadius: 15, direction: .down, toolTipMidX: 150).stroke().previewDisplayName("pointing down")
        }
    }
}
#endif

// Configuration of the tool tip, including arrow height, arrow position, and tool tip corner radius.
struct ToolTipConfiguration {
    /// Alignment of the tool tip with respect to the content
    let alignment: Alignment
    let arrowConfiguration: ArrowConfiguration
    let bodyConfiguration: BodyConfiguration

    init(alignment: Alignment = .bottom, 
         arrowConfiguration: ArrowConfiguration,
         bodyConfiguration: BodyConfiguration) {
        self.alignment = alignment
        self.arrowConfiguration = arrowConfiguration
        self.bodyConfiguration = bodyConfiguration
    }

    enum Alignment {
        case top // Show tool tip above the content view
        case bottom // Show tool tip below the content view
    }

    /// Computed property for how to align the tool tip with respect to the content.
    var verticalAlignmentGuide: (toolTipAlignment: VerticalAlignment, viewDimensionAlignment: VerticalAlignment) {
        switch alignment {
        case .top:
            return (toolTipAlignment: .bottom, viewDimensionAlignment: .top) // align top of tool tip to bottom of view
        case .bottom:
            return (toolTipAlignment: .top, viewDimensionAlignment: .bottom) // align bottom of tool tip to top of view
        }
    }

    /// Configuration for determining size and position of the "arrow" of the tooltip.
    struct ArrowConfiguration {
        /// Height of the arrow
        let height: CGFloat
        /// Position of the arrow relative to the tooltip
        let position: Position

        struct Position {
            /// Horizontal midpoint of the tool tip arrow.
            private let midX: CGFloat

            /// What the horizontal midpoint of the tool tip arrow refers to.
            private let alignmentType: AlignmentType
            
            init(midX: CGFloat, alignmentType: AlignmentType) {
                self.midX = midX
                self.alignmentType = alignmentType
            }

            /// Different ways to align the tool tip arrow
            enum AlignmentType {
                /// Horizontal midpoint of the tool tip arrow will be a percentage of the size of the entire tool tip box
                case percentage

                /// Horizontal midpoint of the tool tip arrow will be an offset based on the starting edge of the tool tip box
                case offset
            }

            /// Returns the horizontal midpoint (the tip of the arrow) of the tooltip arrow.
            func midX(containerWidth: CGFloat) -> CGFloat {
                switch alignmentType {
                case .percentage:
                    midX * containerWidth
                case .offset:
                    midX
                }
            }
        }
    }
    
    /// Configuration determining the size and position of the body of the tool tip.
    struct BodyConfiguration {
        let cornerRadius: CGFloat
        private let size: Size

        init(cornerRadius: CGFloat, size: Size = Size(height: 1.0, width: 1.0, sizeType: .relative)) {
            self.cornerRadius = cornerRadius
            self.size = size
        }

        struct Size {
            let height: CGFloat
            let width: CGFloat
            let sizeType: SizeType

            enum SizeType {
                case absolute // Height and width attributes represent absolute values.
                case relative // Height and width attributes are relative (by percentage) to the container.
            }
        }

        /// Returns the configured width and height of the tooltip body, given the size of the container.
        func size(containerSize: CGSize) -> CGSize {
            switch size.sizeType {
            case .absolute:
                return CGSize(width: size.width, height: size.height)
            case .relative:
                return CGSize(width: size.width * containerSize.width, height: size.height * containerSize.height)
            }
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
            ToolTipShape(cornerRadius: configuration.bodyConfiguration.cornerRadius,
                         direction: configuration.alignment == .bottom ? .up : .down,
                         toolTipMidX: configuration.arrowConfiguration.position.midX(containerWidth: geometry.size.width),
                         toolTipHeight: configuration.arrowConfiguration.height).fill(Color.accentColor)
        })
    }
}

#if DEBUG
struct ToolTipView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ToolTipView(tapAction: {}, label: {
                Text("%_PREVIEW_% tool tip text").padding()
            }, configuration: ToolTipConfiguration(
                arrowConfiguration: ToolTipConfiguration.ArrowConfiguration(height: 7, 
                                                                            position: 
                                                                                ToolTipConfiguration.ArrowConfiguration.Position(
                                                                                    midX: 30,alignmentType: .offset)),
                bodyConfiguration: ToolTipConfiguration.BodyConfiguration(cornerRadius: 10)
            )).previewDisplayName("offset arrow positioning")

            ToolTipView(tapAction: {}, label: {
                Text("%_PREVIEW_% tool tip text").padding()
            }, configuration: ToolTipConfiguration(
                arrowConfiguration: ToolTipConfiguration.ArrowConfiguration(height: 7, 
                                                                            position: 
                                                                                ToolTipConfiguration.ArrowConfiguration.Position(
                                                                                    midX: 0.7, alignmentType: .percentage)),
                bodyConfiguration: ToolTipConfiguration.BodyConfiguration(cornerRadius: 10)
            )).previewDisplayName("percentage arrow positioning")

            ToolTipView(tapAction: {}, label: {
                Text("%_PREVIEW_% tool tip text").padding()
            }, configuration: ToolTipConfiguration(
                alignment: .top,
                arrowConfiguration: ToolTipConfiguration.ArrowConfiguration(height: 7,
                                                                            position:
                                                                                ToolTipConfiguration.ArrowConfiguration.Position(
                                                                                    midX: 0.5, alignmentType: .percentage)),
                bodyConfiguration: ToolTipConfiguration.BodyConfiguration(cornerRadius: 10)
            )).previewDisplayName("top-aligned")

            ToolTipView(tapAction: {}, label: {
                Text("%_PREVIEW_% tool tip text").padding()
            }, configuration: ToolTipConfiguration(
                arrowConfiguration: ToolTipConfiguration.ArrowConfiguration(height: 7,
                                                                            position:
                                                                                ToolTipConfiguration.ArrowConfiguration.Position(
                                                                                    midX: 0.5, alignmentType: .percentage)),
                bodyConfiguration: ToolTipConfiguration.BodyConfiguration(cornerRadius: 10,
                                                                          size: 
                                                                            ToolTipConfiguration.BodyConfiguration.Size(
                                                                                height: 0.5, width: 0.5, sizeType: .relative))
            )).previewDisplayName("half-sized")
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
