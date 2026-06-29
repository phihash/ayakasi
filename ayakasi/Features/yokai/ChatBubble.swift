import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer() }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(12)
                    .background(message.role == .user ? Color.appPrimary : Color.appCardBackground)
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            if message.role == .assistant { Spacer() }
        }
        .padding(.horizontal)
    }
}
