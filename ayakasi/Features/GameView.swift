import SwiftUI

// MARK: - Model
enum Cell: CaseIterable {
    case red, blue, yellow

    var color: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .yellow: return .yellow
        }
    }
}

struct Pos: Hashable {
    let x: Int
    let y: Int
}

// MARK: - ViewModel
@MainActor
class GameViewModel: ObservableObject {
    @Published var columns: [[Cell?]] = []
    @Published var highlighted: Set<Pos> = []
    @Published var gameState: GameState = .idle
    @Published var debugInfo: String = ""

    let cols = 7
    let rows = 10

    enum GameState {
        case idle          // 待機中（タップ可能）
        case highlighted   // ハイライト中（再タップまたは解除待ち）
        case removing      // 消去中
        case settling      // 安定化中（入力無効）
        case clear         // クリア
        case gameOver      // ゲームオーバー
    }

    var gameStateText: String {
        switch gameState {
        case .idle: return "待機中"
        case .highlighted: return "選択中"
        case .removing: return "消去中"
        case .settling: return "落下中"
        case .clear: return "クリア"
        case .gameOver: return "終了"
        }
    }

    init() {
        newGame()
    }

    func newGame() {
        repeat {
            columns = (0..<cols).map { _ in
                (0..<rows).map { _ in Cell.allCases.randomElement()! }
            }
        } while !hasAnyMove()

        highlighted = []
        gameState = .idle
        debugInfo = ""
    }

    func onTap(x: Int, y: Int) {
        // 入力を受け付ける状態かチェック
        guard gameState == .idle || gameState == .highlighted else {
            debugInfo = "入力無効: \(gameState)"
            return
        }
        guard x >= 0, x < cols, y >= 0, y < rows else { return }

        // ハイライト中に同じグループ内をタップ→消去確定
        if gameState == .highlighted, highlighted.contains(Pos(x: x, y: y)) {
            debugInfo = "消去確定"
            Task {
                await confirmRemove()
            }
            return
        }

        // ハイライトをクリア（グループ外タップ or 新規タップ）
        highlighted = []
        gameState = .idle

        // 空白タップなら何もしない
        guard let cell = columns[x][y] else {
            debugInfo = "空白タップ"
            return
        }

        // 新規グループ検索
        let group = floodFill(x: x, y: y, target: cell)
        debugInfo = "連結: \(group.count)個"

        if group.count >= 2 {
            highlighted = group
            gameState = .highlighted
        }
    }

    func floodFill(x: Int, y: Int, target: Cell) -> Set<Pos> {
        var result: Set<Pos> = []
        var stack = [Pos(x: x, y: y)]

        while let pos = stack.popLast() {
            guard pos.x >= 0, pos.x < cols, pos.y >= 0, pos.y < rows else { continue }
            guard !result.contains(pos) else { continue }
            guard columns[pos.x][pos.y] == target else { continue }

            result.insert(pos)
            stack.append(Pos(x: pos.x - 1, y: pos.y))
            stack.append(Pos(x: pos.x + 1, y: pos.y))
            stack.append(Pos(x: pos.x, y: pos.y - 1))
            stack.append(Pos(x: pos.x, y: pos.y + 1))
        }

        return result
    }

    func confirmRemove() {
        guard !highlighted.isEmpty else { return }

        gameState = .removing

        // ブロック消去
        withAnimation(.easeOut(duration: 0.2)) {
            for pos in highlighted {
                columns[pos.x][pos.y] = nil
            }
            highlighted = []
            gameState = .settling
        }

        // 安定化処理を遅延実行
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.settleUntilStable()
        }
    }

    func settleUntilStable() {
        settleStep(step: 0)
    }

    private func settleStep(step: Int) {
        var changed = false

        withAnimation(.linear(duration: 0.22)) {
            switch step % 3 {
            case 0: changed = fallDown()
            case 1: changed = slideLeft()
            case 2: changed = fallDown()
            default: break
            }
        }

        if changed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                self.settleStep(step: step + 1)
            }
        } else if step < 2 {
            // まだ3ステップ完了していない場合は次へ
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                self.settleStep(step: step + 1)
            }
        } else {
            // 全ステップ完了、判定
            self.checkGameEnd()
        }
    }

    private func checkGameEnd() {
        if isBoardEmpty() {
            gameState = .clear
        } else if !hasAnyMove() {
            gameState = .gameOver
        } else {
            gameState = .idle
        }
    }

    func fallDown() -> Bool {
        var changed = false
        for x in 0..<cols {
            var nonNil: [Cell] = []
            for y in 0..<rows {
                if let cell = columns[x][y] {
                    nonNil.append(cell)
                }
            }
            let nilCount = rows - nonNil.count
            let newCol = Array(repeating: nil as Cell?, count: nilCount) + nonNil.map { $0 as Cell? }
            if columns[x] != newCol {
                columns[x] = newCol
                changed = true
            }
        }
        return changed
    }

    func slideLeft() -> Bool {
        var changed = false
        var newCols: [[Cell?]] = []

        for x in 0..<cols {
            if columns[x].contains(where: { $0 != nil }) {
                newCols.append(columns[x])
            }
        }

        while newCols.count < cols {
            newCols.append(Array(repeating: nil, count: rows))
        }

        if columns != newCols {
            columns = newCols
            changed = true
        }

        return changed
    }

    func hasAnyMove() -> Bool {
        for x in 0..<cols {
            for y in 0..<rows {
                guard let cell = columns[x][y] else { continue }
                let group = floodFill(x: x, y: y, target: cell)
                if group.count >= 2 {
                    return true
                }
            }
        }
        return false
    }

    func isBoardEmpty() -> Bool {
        for x in 0..<cols {
            for y in 0..<rows {
                if columns[x][y] != nil {
                    return false
                }
            }
        }
        return true
    }
}

// MARK: - View
struct GameView: View {
    @StateObject private var vm = GameViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                HStack {
                    Text("パズルゲーム")
                        .font(.title)
                        .fontWeight(.bold)

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                boardView
                    .padding()

                Button("やりなおし") {
                    vm.newGame()
                }
                .font(.headline)
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(Color.appPrimary)
                .foregroundStyle(Color.white)
                .cornerRadius(8)

                Spacer()
            }

            if vm.gameState == .clear {
                resultOverlay(title: "CLEAR!", color: .appSuccess)
            } else if vm.gameState == .gameOver {
                resultOverlay(title: "GAME OVER", color: .appError)
            }
        }
    }

    var boardView: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width / CGFloat(vm.cols), geometry.size.height / CGFloat(vm.rows))
            let boardWidth = size * CGFloat(vm.cols)
            let boardHeight = size * CGFloat(vm.rows)

            HStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    Spacer()
                    HStack(spacing: 2) {
                        ForEach(0..<vm.cols, id: \.self) { x in
                            VStack(spacing: 2) {
                                ForEach(0..<vm.rows, id: \.self) { y in
                                    cellView(x: x, y: y, size: size - 2)
                                }
                            }
                        }
                    }
                    .frame(width: boardWidth, height: boardHeight)
                    Spacer()
                }
                Spacer()
            }
        }
    }

    func cellView(x: Int, y: Int, size: CGFloat) -> some View {
        let pos = Pos(x: x, y: y)
        let isHighlighted = vm.highlighted.contains(pos)
        let cellIdentifier = "\(x)-\(y)-\(vm.columns[x][y]?.hashValue ?? 0)"

        return ZStack {
            if let cell = vm.columns[x][y] {
                RoundedRectangle(cornerRadius: 4)
                    .fill(cell.color)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(isHighlighted ? Color.white.opacity(0.8) : Color.clear, lineWidth: isHighlighted ? 3 : 0)
                    )
                    .opacity(isHighlighted ? 0.85 : 1.0)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.appTextSecondary.opacity(0.1))
            }
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle())
        .onTapGesture {
            vm.onTap(x: x, y: y)
        }
        .id(cellIdentifier)
    }

    func resultOverlay(title: String, color: Color) -> some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(title)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(color)

                Button("やりなおし") {
                    vm.newGame()
                }
                .font(.headline)
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(Color.appPrimary)
                .foregroundStyle(Color.white)
                .cornerRadius(8)
            }
        }
    }
}
