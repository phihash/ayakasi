#if DEBUG
import PhotosUI
import SwiftUI

struct VisitComposerContext: Identifiable {
    let id = UUID()
    let yokaiId: String
    let spots: [YokaiSpot]
}

/// 画面の右下に浮かせる「訪問記を書く」ボタン
struct VisitComposeButton: View {
    let yokaiId: String
    let spots: [YokaiSpot]
    @Binding var composer: VisitComposerContext?

    var body: some View {
        if composer == nil {
            Button {
                composer = VisitComposerContext(yokaiId: yokaiId, spots: spots)
            } label: {
                ActionCircleIcon(systemName: "square.and.pencil")
            }
            .accessibilityLabel("訪問記を書く")
        }
    }
}

extension View {
    func visitComposer(_ context: Binding<VisitComposerContext?>) -> some View {
        safeAreaInset(edge: .bottom, spacing: 0) {
            if let draft = context.wrappedValue {
                SpotVisitComposer(context: draft) { context.wrappedValue = nil }
                    .id(draft.id)
            }
        }
    }
}

private struct SpotVisitComposer: View {
    let context: VisitComposerContext
    let close: () -> Void
    @EnvironmentObject private var auth: AuthViewModel
    @FocusState private var typing: Bool
    @State private var selectedIndex: Int?
    @State private var note = ""
    @State private var items: [PhotosPickerItem] = []
    @State private var previews: [PhotosPickerItem: UIImage] = [:]
    @State private var failedItems: Set<PhotosPickerItem> = []
    @State private var requestId = UUID()
    @State private var posting = false
    @State private var error: String?
    @State private var showLogin = false

    init(context: VisitComposerContext, close: @escaping () -> Void) {
        self.context = context
        self.close = close
        _selectedIndex = State(initialValue: context.spots.count == 1 ? 0 : nil)
    }

    private var text: String { note.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var canSend: Bool {
        selectedIndex != nil && (!text.isEmpty || !items.isEmpty) && text.unicodeScalars.count <= 2000 &&
            items.allSatisfy { previews[$0] != nil } && !posting
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
            HStack {
                let place = selectedIndex.map { context.spots[$0].spotName }
                if context.spots.count == 1 {
                    Label(place ?? "", systemImage: "mappin.and.ellipse")
                } else {
                    Menu {
                        ForEach(context.spots.indices, id: \.self) { i in
                            let spot = context.spots[i]
                            Button("\(spot.spotName)（\(spot.prefecture)）") { selectedIndex = i }
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Label(place ?? "訪問先を選ぶ", systemImage: "mappin.and.ellipse")
                            Image(systemName: "chevron.down")
                        }
                    }
                    .accessibilityHint("この訪問記の訪問先を選びます")
                }
                Spacer()
                Button(action: close) {
                    Image(systemName: "xmark").frame(width: 44, height: 44)
                }
                .accessibilityLabel("入力欄を閉じる")
            }
            .appFont(.subheadline)
            .foregroundStyle(Color.appTextSecondary)

            if !items.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(items, id: \.self) { item in
                            ZStack {
                                Color.appTextFieldBackground
                                if let image = previews[item] {
                                    Image(uiImage: image).resizable().scaledToFill()
                                } else if failedItems.contains(item) {
                                    Image(systemName: "exclamationmark.triangle")
                                } else {
                                    ProgressView()
                                }
                            }
                            .frame(width: 128, height: 88)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(alignment: .topTrailing) {
                                Button { items.removeAll { $0 == item } } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, .black.opacity(0.65))
                                        .appFont(.title3)
                                        .frame(width: 44, height: 44)
                                }
                                .accessibilityLabel("写真\((items.firstIndex(of: item) ?? 0) + 1)を外す")
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
            }

            if let message = validationMessage {
                Text(message).appFont(.footnote).foregroundStyle(Color.appError)
                    .padding(.bottom, 4)
            }
            HStack(alignment: .bottom, spacing: 6) {
                PhotosPicker(selection: $items, maxSelectionCount: SpotLogAPI.maxPhotos,
                             selectionBehavior: .ordered, matching: .images) {
                    Image(systemName: "photo.on.rectangle")
                        .appFont(.title2).frame(width: 44, height: 44)
                }
                .accessibilityLabel("写真を選ぶ（最大4枚）")
                TextField("訪問記を書く", text: $note, axis: .vertical)
                    .appFont(.body)
                    .lineLimit(1...3)
                    .focused($typing)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .frame(minHeight: 44)
                    .background(Color.appTextFieldBackground, in: RoundedRectangle(cornerRadius: 20))
                if posting {
                    ProgressView().frame(width: 44, height: 44).accessibilityLabel("送信中")
                } else {
                    Button("送信", action: send)
                        .appFont(.headline).frame(minWidth: 44, minHeight: 44)
                        .disabled(!canSend)
                }
            }
            .padding(.bottom, 6)
        }
        .padding(.horizontal, 12)
        .background(Color.appCardBackground)
        .disabled(posting)
        .onAppear { typing = true }
        .onChange(of: note) { requestId = UUID(); error = nil }
        .onChange(of: selectedIndex) { requestId = UUID(); error = nil }
        .onChange(of: items) { requestId = UUID(); error = nil }
        .task(id: items) { await loadPreviews() }
        .sheet(isPresented: $showLogin) {
            NavigationStack {
                LoginView().toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("閉じる") { showLogin = false }
                    }
                }
            }
        }
    }

    private var validationMessage: String? {
        if text.unicodeScalars.count > 2000 { return "本文は2,000文字以内で入力してください。" }
        if items.contains(where: failedItems.contains) { return "読み込めなかった写真を外すか、選び直してください。" }
        return error
    }

    private func loadPreviews() async {
        let selection = items
        previews = previews.filter { selection.contains($0.key) }
        failedItems = []
        for item in selection where previews[item] == nil {
            let data = try? await item.loadTransferable(type: Data.self)
            let thumbnail = await data.flatMap(UIImage.init(data:))?.byPreparingThumbnail(ofSize: CGSize(width: 1200, height: 1200))
            guard !Task.isCancelled else { return }
            if let thumbnail { previews[item] = thumbnail } else { failedItems.insert(item) }
        }
    }

    private func send() {
        guard canSend, let selectedIndex else { return }
        guard auth.authStatus == .authenticated else {
            typing = false
            showLogin = true
            return
        }
        posting = true
        error = nil
        Task {
            defer { posting = false }
            do {
                let photos = try items.map { item in
                    guard let data = previews[item]?.jpegData(compressionQuality: 0.8), data.count <= 2 * 1024 * 1024 else {
                        throw VisitError("送信できない写真があります。写真を選び直してください。")
                    }
                    return data
                }
                let spot = context.spots[selectedIndex]
                let submission = SpotLogSubmission(requestId: requestId, yokaiId: context.yokaiId,
                    spotName: spot.spotName, prefecture: spot.prefecture, body: text, photos: photos)
                _ = try await SpotLogAPI.publish(submission)
                close()
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}
#endif
