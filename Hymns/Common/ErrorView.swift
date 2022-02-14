import SwiftUI

/**
 * Generic error view for cases that should not arise in the wild.
 */
struct ErrorView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image("error illustration")
            Text("Well, this is unexpected", comment: "Title for the error page.").font(.headline).padding()
            Text("An error has occurred. Please try again. You can also send feedback and we’ll look into the issue.",
                 comment: "Subtitle for the error page.")
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .font(.callout)
                .padding(.horizontal)
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
    }
}
