import SwiftUI

/// The prominent "next sacred date" card on the home screen.
struct NextSacredDateCard: View {
    let entry: SacredDateEntry

    var body: some View {
        SacredCard {
            HStack(alignment: .center, spacing: 16) {
                VStack(spacing: 2) {
                    Text(entry.nextOccurrence, format: .dateTime.day())
                        .font(.system(.title, design: .serif).weight(.semibold))
                        .foregroundStyle(Theme.Palette.accent)
                    Text(entry.nextOccurrence, format: .dateTime.month(.abbreviated))
                        .font(.sacredLabel)
                        .textCase(.uppercase)
                        .foregroundStyle(Theme.Palette.inkSecondary)
                }
                .frame(width: 56)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(entry.name)
                            .font(.sacredHeadline)
                            .foregroundStyle(Theme.Palette.ink)
                        if let dev = entry.nameDevanagari {
                            Text(dev)
                                .font(.sacredCaption)
                                .foregroundStyle(Theme.Palette.gold)
                        }
                    }
                    Text(entry.nextOccurrence.sacredRelativePhrase)
                        .font(.sacredLabel)
                        .foregroundStyle(Theme.Palette.inkSecondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundStyle(Theme.Palette.gold)
            }
        }
    }
}

/// A list row in the full Sacred Time screen.
struct SacredDateRow: View {
    let entry: SacredDateEntry

    var body: some View {
        SacredCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(entry.name)
                        .font(.sacredHeadline)
                        .foregroundStyle(Theme.Palette.ink)
                    if let dev = entry.nameDevanagari {
                        Text(dev)
                            .font(.sacredCaption)
                            .foregroundStyle(Theme.Palette.gold)
                    }
                    Spacer()
                    Text(entry.nextOccurrence.sacredShortString)
                        .font(.sacredLabel)
                        .foregroundStyle(Theme.Palette.accent)
                }

                Text(entry.significance)
                    .font(.sacredCaption)
                    .foregroundStyle(Theme.Palette.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    Text(entry.nextOccurrence.sacredRelativePhrase)
                        .font(.sacredLabel)
                        .foregroundStyle(Theme.Palette.inkSecondary)
                    if let devata = entry.devataAssociation {
                        Text("· \(devata)")
                            .font(.sacredLabel)
                            .foregroundStyle(Theme.Palette.gold)
                    }
                }
            }
        }
    }
}
