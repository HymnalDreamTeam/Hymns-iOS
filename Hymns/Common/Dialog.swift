import Prefire
import SwiftUI

/**
 * Shows a dialog and dims the background
 */
struct Dialog<Content: View>: View {

    @Binding private var viewModelBinding: DialogViewModel<Content>?
    @ObservedObject private var viewModel: DialogViewModel<Content>

    init?(viewModel: Binding<DialogViewModel<Content>?>) {
        self._viewModelBinding = viewModel
        guard let viewModel = viewModel.wrappedValue else {
            return nil
        }
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            if viewModel.options.dimBackground {
                Color.black.opacity(0.66).edgesIgnoringSafeArea(.all).onTapGesture {
                    guard let closeHandler = self.viewModel.closeHandler else {
                        // if no close handler provided, just dismiss the dialog
                        withAnimation {
                            self.viewModelBinding = nil
                        }
                        return
                    }
                    closeHandler()
                }
            }
            viewModel.contentBuilder().background(Color(UIColor.systemBackground))
        }.opacity(viewModel.opacity).transition(self.viewModel.options.transition ?? .identity).animation(.easeInOut)
    }
}

#if DEBUG
struct Dialog_Previews: PreviewProvider, PrefireProvider {

    static var previews: some View {
        let backgroundText = Text("""
%_PREVIEW_% I'm baby kale chips bushwick whatever irony umami paleo. Selvage selfies art party vinyl distillery fanny pack. Taxidermy farm-to-table snackwave, narwhal copper mug listicle hashtag chambray tofu ethical forage pug chillwave kitsch sriracha. Slow-carb pabst poke listicle coloring book locavore williamsburg.

Fam asymmetrical whatever VHS pop-up leggings gastropub af iPhone sartorial chartreuse palo santo man braid. Chartreuse fanny pack organic, vexillologist lomo asymmetrical af. Wolf chia swag live-edge butcher VHS la croix, scenester deep v tote bag lomo. Ugh jianbing pitchfork vegan farm-to-table normcore synth green juice beard distillery hot chicken.

Palo santo seitan actually aesthetic. Narwhal plaid chambray schlitz pour-over kickstarter master cleanse letterpress glossier franzen. 3 wolf moon kinfolk leggings taxidermy. Farm-to-table artisan poke kale chips. Hoodie vinyl jean shorts taiyaki aesthetic artisan, meh church-key cold-pressed seitan blue bottle celiac irony.

Dummy text? More like dummy thicc text, amirite?
""")
        let viewModel = DialogViewModel(contentBuilder: {
            Text("%_PREVIEW_% Example Dialog").foregroundColor(.green).padding().eraseToAnyView()
        })
        let dialog = Dialog(viewModel: .constant(viewModel))
        return ZStack {
            backgroundText
            dialog
        }
    }
}
#endif
