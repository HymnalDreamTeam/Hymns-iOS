import SwiftUI

// https://stackoverflow.com/a/58876712/1907538
// https://stackoverflow.com/questions/62102647/swiftui-hstack-with-wrap-and-dynamic-height
struct WrappedHStack<Item: Hashable, Content: View>: View {

    @Binding var items: [Item]
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    let viewBuilder: (Item) -> Content

    @State private var totalHeight = CGFloat.zero

    init(items: Binding<[Item]>, horizontalSpacing: CGFloat = 5, verticalSpacing: CGFloat = 5,
         viewBuilder: @escaping (Item) -> Content) {
        self._items = items
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.viewBuilder = viewBuilder
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }.frame(height: totalHeight)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        guard let lastItem = self.items.last else {
            return EmptyView().eraseToAnyView()
        }

        var topLeftX = CGFloat.zero
        var topLeftY = CGFloat.zero
        var bottomRightX = CGFloat.zero
        var bottomRightY = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.items, id: \.self) { item in
                self.viewBuilder(item)
                    .padding(.horizontal, horizontalSpacing)
                    .padding(.vertical, verticalSpacing)
                    .alignmentGuide(.leading, computeValue: { dimension in
                        topLeftX = bottomRightX
                        if abs(topLeftX - dimension.width) > geometry.size.width {
                            topLeftX = 0
                            topLeftY = bottomRightY
                        }

                        let result = topLeftX
                        if item == lastItem {
                            topLeftX = 0 // last item
                            bottomRightX = 0
                        } else {
                            bottomRightX = topLeftX - dimension.width
                        }

                        bottomRightY = topLeftY - dimension.height
                        return result
                    }).alignmentGuide(.top, computeValue: { _ in
                        let result = topLeftY
                        if item == lastItem {
                            topLeftY = 0 // last item
                            bottomRightY = 0
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight)).eraseToAnyView()
    }

    private func viewHeightReader(_ totalHeightBinding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                totalHeightBinding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

#if DEBUG
/// Note: as height of view is calculated dynamically the result works in run-time, not in Preview
struct WrappedHStack_Previews: PreviewProvider {
    static var previews: some View {
        let severalItems = Binding.constant([
            "Multiline really relaly long tag name that takes up many lines. So many lines, in fact, that it could be three lines.",
            "Nintendo", "XBox", "PlayStation", "Playstation 2", "Playstaition 3", "Stadia", "Oculus"])
        let hundredItems = Binding.constant(Array(1...100).map { number -> String in
            return "Playstation \(number)!!"
        })
        let lyrics = Binding.constant("""
1
[G]Drink! A river pure and clear
That’s [G7]flowing from the throne;
[C]Eat! The tree of life with fruits
Abundant, richly [G]grown;
Look! No need of lamp nor sun nor [B7]moon
To keep it [Em]bright, for
[G]Here there [D7]is no [G-C-G]night!


  Do come, oh, do come,
  Says [G7]Spirit and the Bride:
  [C]Do come, oh, do come,
  Let him that heareth, [G]cry.
  []Do come, oh, do come,
  Let [B7]him who thirsts and [Em]will
  Take [G]freely the [D]water of [G-C-G]life!

2
Christ, our river, Christ, our water,
Springing from within;
Christ, our tree, and Christ, the fruits,
To be enjoyed therein,
Christ, our day, and Christ, our light,
and Christ, our morningstar:
Christ, our everything!

3
We are washing all our robes
The tree of life to eat;
"O Lord, Amen, Hallelujah!”—
Jesus is so sweet!
We our spirits exercise,
And thus experience Christ.
What a Christ have we!

4
Now we have a home so bright
That outshines the sun,
Where the brothers all unite
And truly are one.
Jesus gets us all together,
Him we now display
In the local church.
""".split(whereSeparator: \.isWhitespace))
        return Group {
            ScrollView {
                VStack {
                    Text("%_PREVIEW_% Title").font(.headline)
                    WrappedHStack(items: severalItems) { item in
                        Text(item)
                    }
                    Button("Click me") {}
                }
            }.previewDisplayName("several items")
            ScrollView {
                VStack {
                    Text("%_PREVIEW_% Title").font(.headline)
                    WrappedHStack(items: hundredItems, horizontalSpacing: 0, verticalSpacing: 0) { item in
                        Text(item)
                    }
                    Button("Click me") {}
                }
            }.previewDisplayName("hundred items")
            ScrollView {
                VStack {
                    Text("%_PREVIEW_% Hymn 1151").font(.headline)
                    WrappedHStack(items: lyrics, horizontalSpacing: 0, verticalSpacing: 0) { item in
                        Text(item)
                    }
                    Button("Click me") {}
                }
            }.previewDisplayName("Lyrics")
        }
    }
}
#endif
