import SwiftUI

/// The top of the altar: a quiet greeting, the mandir's name, the presiding
/// devata, and the single settings affordance (the gear).
struct AltarHeader: View {
    let greeting: String
    let mandirName: String
    let devataName: String?
    let onSettings: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.sacredCaption)
                    .foregroundStyle(Theme.Palette.inkSecondary)
                Text(mandirName)
                    .font(.mandirTitle)
                    .foregroundStyle(Theme.Palette.ink)
                if let devataName {
                    Text("\(devataName) presides")
                        .font(.sacredLabel)
                        .foregroundStyle(Theme.Palette.brass)
                }
            }
            Spacer()
            Button(action: onSettings) {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundStyle(Theme.Palette.inkSecondary)
                    .padding(8)
            }
            .accessibilityLabel("Settings")
        }
    }
}
