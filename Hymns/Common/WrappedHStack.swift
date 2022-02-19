import SwiftUI

// https://stackoverflow.com/a/58876712/1907538
struct WrappedHStack<Item: Hashable, Content: View>: View {

    @Binding var items: [Item]
    let geometry: GeometryProxy
    let viewBuilder: (Item) -> Content

    var body: some View {
        guard let lastItem = self.items.last else {
            return EmptyView().eraseToAnyView()
        }

        var topLeftX = CGFloat.zero
        var topLeftY = CGFloat.zero
        var bottomRightX = CGFloat.zero
        var bottomRightY = CGFloat.zero
        return
            ZStack(alignment: .topLeading) {
                ForEach(self.items, id: \.self) { item in
                    self.viewBuilder(item).alignmentGuide(.leading, computeValue: { dimension in
                        topLeftX = bottomRightX
                        if abs(topLeftX - dimension.width) > self.geometry.size.width {
                            topLeftX = 0
                            topLeftY = bottomRightY
                        }

                        let result = topLeftX
                        if item == lastItem {
                            topLeftX = 0
                            bottomRightX = 0
                        } else {
                            bottomRightX = topLeftX - dimension.width - 5
                        }

                        bottomRightY = topLeftY - dimension.height - 5
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
            }.eraseToAnyView()
    }
}

#if DEBUG
struct WrappedHStack_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            GeometryReader { geometry in
                WrappedHStack(items: Binding.constant([String]()), geometry: geometry) { item in
                    Text(item)
                }
            }
            GeometryReader { geometry in
                WrappedHStack(items: Binding.constant([
                    "Multiline really relaly long tag name that takes up many lines. So many lines, in fact, that it could be three lines.",
                    "Nintendo", "XBox", "PlayStation", "Playstation 2", "Playstaition 3", "Stadia", "Oculus"]), geometry: geometry) { platform in
                        Button(action: {}, label: {
                            HStack {
                                Text(platform).font(.body).fontWeight(.bold)
                                Image(systemName: "xmark.circle")
                            }.padding(7).foregroundColor(Color.white).background(Color.purple).cornerRadius(15)
                        })
                }
            }
        }.previewLayout(.sizeThatFits)
    }
}
#endif
