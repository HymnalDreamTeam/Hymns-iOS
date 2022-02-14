import SwiftUI

struct ColorSelectorView: View {

    @Binding var tagColor: TagColor

    var body: some View {
        VStack(alignment: .leading) {
            Text("Select a color", comment: "Color selector for the tags.").font(.body).fontWeight(.bold)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(TagColor.allColors, id: \.self) { tagColor in
                        Button(action: {
                            if self.tagColor == tagColor {
                                self.tagColor = .none
                            } else {
                                self.tagColor = tagColor
                            }
                        }, label: {
                            Text(tagColor.name)
                                .font(.body)
                                .fontWeight(self.tagColor == tagColor ? .bold : .none)
                        }).tagPill(backgroundColor: tagColor.background,
                                   foregroundColor: tagColor.foreground,
                                   showBorder: self.tagColor == tagColor)
                    }
                }.padding(.leading, 2)
            }
        }
    }
}

struct SelectLabelView_Previews: PreviewProvider {
    static var previews: some View {
        ColorSelectorView(tagColor: .constant(.blue))
    }
}
