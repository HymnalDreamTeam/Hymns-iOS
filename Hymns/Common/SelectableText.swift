import SwiftUI

public struct SelectableText: View {

    let text: NSAttributedString
    @Binding var width: CGFloat?

    init(_ text: NSAttributedString, width: Binding<CGFloat?>) {
        self.text = text
        self._width = width
    }

    public var body: some View {
        SelectableUiText(text)
            .frame(height: SelectableUiText.calculateHeight(text: text, width: width))
    }
}

struct SelectableUiText: UIViewRepresentable {

    let text: NSAttributedString

    init(_ text: NSAttributedString) {
        self.text = text
    }

    func makeUIView(context: Context) -> UITextView {
        SelectableUiText.createTextView()
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        textView.attributedText = text
        textView.sizeToFit()
    }

    static func createTextView() -> UITextView {
        let textView = UITextView()
        textView.isSelectable = true
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        return textView
    }

    fileprivate static func calculateHeight(text: NSAttributedString, width: CGFloat?) -> CGFloat {
        guard let width = width else { return 0 }

        let textView = createTextView()
        textView.attributedText = text

        return textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height
    }
}
