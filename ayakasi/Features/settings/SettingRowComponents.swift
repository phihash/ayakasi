import SwiftUI

struct SettingRowButton: View {
    let title: String
    var color: Color = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .foregroundStyle(color)
    }
}

struct SettingRowLink<Destination: View>: View {
    let title: String
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
        }
        .foregroundStyle(.primary)
    }
}
