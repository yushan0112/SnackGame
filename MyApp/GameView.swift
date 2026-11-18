import SwiftUI

// 遊戲畫面（從首頁用 fullScreenCover 打開）
struct GameView: View {
    @Environment(GameModel.self) private var game
    @Environment(\.dismiss) private var dismiss

    @State private var shake: CGFloat = 0
    @State private var flash = false

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()

            VStack(spacing: 14) {
                GameHUD(onClose: close)
                classroom
                Spacer(minLength: 0)
                SnackDesk()
            }
            .padding()
            .modifier(Shake(animatableData: shake))

            // 被抓到時閃紅光
            Color.red
                .opacity(flash ? 0.35 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            overlays
        }
        .fontDesign(.rounded)
        .onAppear { game.start() }
        .onDisappear { game.stop() }
        .onChange(of: game.phase) { _, newPhase in
            if newPhase == .finished && game.endReason == .caught {
                caughtEffect()
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: game.snacksEaten)
        .sensoryFeedback(.warning, trigger: game.teacher == .warning)
    }

    // 黑板 + 老師 + 對話泡泡
    private var classroom: some View {
        ZStack(alignment: .top) {
            Blackboard(isWriting: game.teacher == .writing && game.phase == .playing)

            TeacherView(state: game.teacher)
                .offset(y: 90)

            bubble
                .offset(x: 95, y: 100)
        }
        .frame(height: 270, alignment: .top)
    }

    @ViewBuilder
    private var bubble: some View {
        switch game.teacher {
        case .writing:
            EmptyView()
        case .warning:
            SpeechBubble(text: "咳咳⋯", color: .orange)
                .transition(.scale.combined(with: .opacity))
        case .looking:
            SpeechBubble(text: game.phase == .finished ? "抓到了！" : "嗯？",
                         color: .red)
                .transition(.scale.combined(with: .opacity))
        }
    }

    @ViewBuilder
    private var overlays: some View {
        if game.phase == .countdown {
            CountdownView(number: game.countdown)
        }
        if game.phase == .finished {
            ResultView(onHome: close)
                .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
    }

    private func caughtEffect() {
        withAnimation(.linear(duration: 0.5)) {
            shake += 1
        }
        withAnimation(.easeOut(duration: 0.15)) {
            flash = true
        }
        withAnimation(.easeIn(duration: 0.6).delay(0.2)) {
            flash = false
        }
    }

    private func close() {
        game.stop()
        dismiss()
    }
}

// MARK: - 上方：關閉、倒數時間、分數、危險程度
struct GameHUD: View {
    @Environment(GameModel.self) private var game
    let onClose: () -> Void

    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.8), in: Circle())
            }

            Spacer()

            timeLabel

            Spacer()

            DangerBadge(state: game.teacher)
        }
    }

    private var timeLabel: some View {
        let seconds = Int(ceil(game.timeRemaining))
        let urgent = seconds <= 10

        return VStack(spacing: 2) {
            Label("\(seconds)", systemImage: "clock.fill")
                .font(.title2.bold())
                .monospacedDigit()
                .foregroundStyle(urgent ? .red : .primary)
                .contentTransition(.numericText(countsDown: true))
                .animation(.snappy, value: seconds)
            Text("\(game.score) 口")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
        }
    }
}

// 右上角：老師現在多危險
struct DangerBadge: View {
    let state: TeacherState

    private var info: (text: String, icon: String, color: Color) {
        switch state {
        case .writing: ("安全", "checkmark.shield.fill", .green)
        case .warning: ("小心", "exclamationmark.triangle.fill", .orange)
        case .looking: ("危險", "eye.fill", .red)
        }
    }

    var body: some View {
        Label(info.text, systemImage: info.icon)
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(info.color.gradient, in: Capsule())
            .contentTransition(.symbolEffect(.replace))
            .symbolEffect(.pulse, isActive: state == .looking)
            .animation(.spring, value: state)
    }
}

// MARK: - 下方：書桌和零食，按住就偷吃
struct SnackDesk: View {
    @Environment(GameModel.self) private var game
    @State private var chewing = false

    var body: some View {
        VStack(spacing: 12) {
            comboLabel

            Text(game.currentSnack.emoji)
                .font(.system(size: 92))
                .scaleEffect(chewing ? 1.12 : 0.96)
                .rotationEffect(.degrees(chewing ? 6 : -6))
                .id(game.snackIndex)
                .transition(.scale.combined(with: .opacity))

            Text(game.currentSnack.name)
                .font(.headline)

            ProgressView(value: 1 - game.snackProgress)
                .tint(Theme.accent)
                .frame(width: 180)

            Text(hint)
                .font(.subheadline.bold())
                .foregroundStyle(game.isEating ? Theme.accent : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(deskBackground)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in game.startEating() }
                .onEnded { _ in game.stopEating() }
        )
        .onChange(of: game.isEating) { _, eating in
            if eating {
                withAnimation(.easeInOut(duration: 0.15).repeatForever(autoreverses: true)) {
                    chewing = true
                }
            } else {
                withAnimation(.easeOut(duration: 0.15)) {
                    chewing = false
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: game.snackIndex)
    }

    private var hint: String {
        if game.phase != .playing { return " " }
        return game.isEating ? "偷吃中⋯小心老師！" : "👆 按住螢幕偷吃"
    }

    @ViewBuilder
    private var comboLabel: some View {
        if game.combo > 1 {
            Text("🔥 連吃 x\(game.combo)")
                .font(.headline.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.red.gradient, in: Capsule())
                .transition(.scale.combined(with: .opacity))
        } else {
            Text(" ")
                .font(.headline)
                .padding(.vertical, 6)
        }
    }

    private var deskBackground: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(Theme.desk.gradient)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .strokeBorder(Theme.wood, lineWidth: 6)
            )
            .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
    }
}

// MARK: - 3、2、1 倒數
struct CountdownView: View {
    let number: Int

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
            Text("\(number)")
                .font(.system(size: 140, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .id(number)
                .transition(.scale(scale: 2).combined(with: .opacity))
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: number)
    }
}

// MARK: - 左右搖晃的效果
struct Shake: GeometryEffect {
    var amount: CGFloat = 12
    var shakesPerUnit: CGFloat = 4
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let x = amount * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: x, y: 0))
    }
}
