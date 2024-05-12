import SwiftUI

struct SelectableText: View {

    @Environment(\.selectableTextContainerSize) var containerSize
    private let text: NSAttributedString

    @State var height: CGFloat?

    init(_ text: NSAttributedString) {
        self.text = text
    }

    var body: some View {
        SelectableTextUITextView(text, size: containerSize, height: $height)
            .preference(key: HymnLyricsView.DisplayContentHeight.self, value: height)
    }
}

struct SelectableTextContainerSize: EnvironmentKey {
    static var defaultValue: CGSize?
}

extension EnvironmentValues {
    var selectableTextContainerSize: CGSize? {
        get { self[SelectableTextContainerSize.self] }
        set { self[SelectableTextContainerSize.self] = newValue }
    }
}

struct SelectableTextUITextView: UIViewRepresentable {

    private let text: NSAttributedString
    private let size: CGSize?

    @Binding var height: CGFloat?

    init(_ text: NSAttributedString, size: CGSize?, height: Binding<CGFloat?>) {
        self.text = text
        self.size = size
        self._height = height
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        textView.delegate = context.coordinator
        return textView
    }
 
    func updateUIView(_ textView: UITextView, context: Context) {
        textView.attributedText = text
        DispatchQueue.main.async {
            size.map { size in
                height = textView.sizeThatFits(size).height
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: SelectableTextUITextView

        init(_ parent: SelectableTextUITextView) {
            self.parent = parent
        }
    }
}
