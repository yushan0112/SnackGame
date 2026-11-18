import SwiftUI

// 用形狀畫出來的老師
struct TeacherView: View {
    let state: TeacherState

    var body: some View {
        ZStack(alignment: .top) {
            shirt
                .offset(y: 70)
            if state == .writing {
                writingArm
            }
            head
        }
        .frame(width: 140, height: 160)
    }

    // 頭：背對時只看得到頭髮，轉過來才看得到臉
    @ViewBuilder
    private var head: some View {
        switch state {
        case .writing:
            TeacherBackHead()
        case .warning:
            TeacherBackHead()
                .rotationEffect(.degrees(-14))
                .offset(x: -6)
        case .looking:
            TeacherFace()
                .transition(.scale.combined(with: .opacity))
        }
    }

    private var shirt: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.indigo.gradient)
                .frame(width: 130, height: 90)
            // 領帶
            Capsule()
                .fill(Color.red.gradient)
                .frame(width: 14, height: 46)
                .opacity(state == .looking ? 1 : 0)
        }
    }

    private var writingArm: some View {
        WritingArm()
            .offset(x: 50, y: 70)
    }
}

// 寫黑板的手會上下動（每次出現都重新開始動畫）
struct WritingArm: View {
    @State private var moving = false

    var body: some View {
        HStack(spacing: -4) {
            Capsule()
                .fill(Color.indigo)
                .frame(width: 60, height: 22)
            Circle()
                .fill(Theme.skin)
                .frame(width: 22, height: 22)
        }
        .rotationEffect(.degrees(moving ? -40 : -25), anchor: .leading)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true)) {
                moving = true
            }
        }
    }
}

// 背面：一整顆頭髮加一個包包頭
struct TeacherBackHead: View {
    var body: some View {
        ZStack(alignment: .top) {
            Circle()
                .fill(Theme.hair)
                .frame(width: 86, height: 86)
            Circle()
                .fill(Theme.hair)
                .frame(width: 34, height: 34)
                .offset(y: -18)
        }
    }
}

// 正面：眼鏡加生氣的眉毛
struct TeacherFace: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.skin)
                .frame(width: 86, height: 86)

            // 頭髮
            Capsule()
                .fill(Theme.hair)
                .frame(width: 92, height: 38)
                .offset(y: -32)
            Circle()
                .fill(Theme.hair)
                .frame(width: 34, height: 34)
                .offset(y: -58)

            // 眉毛
            Capsule()
                .fill(Theme.hair)
                .frame(width: 20, height: 5)
                .rotationEffect(.degrees(20))
                .offset(x: -17, y: -14)
            Capsule()
                .fill(Theme.hair)
                .frame(width: 20, height: 5)
                .rotationEffect(.degrees(-20))
                .offset(x: 17, y: -14)

            // 眼鏡 + 眼睛
            Glasses()
                .offset(y: 2)

            // 嘴巴
            Capsule()
                .fill(Color.black.opacity(0.7))
                .frame(width: 24, height: 5)
                .offset(y: 26)
        }
    }
}

struct Glasses: View {
    var body: some View {
        HStack(spacing: 6) {
            lens
            lens
        }
        .overlay(
            Rectangle()
                .fill(.black)
                .frame(width: 8, height: 2)
        )
    }

    private var lens: some View {
        ZStack {
            Circle()
                .strokeBorder(.black, lineWidth: 2.5)
                .frame(width: 26, height: 26)
            Circle()
                .fill(.black)
                .frame(width: 8, height: 8)
        }
    }
}

// 黑板：老師在寫字時，字會一個一個寫出來（TimelineView）
struct Blackboard: View {
    let isWriting: Bool
    private let text = "期中考範圍：\nsin²θ + cos²θ = 1"
    @State private var startDate = Date.now

    var body: some View {
        TimelineView(.periodic(from: startDate, by: 0.25)) { context in
            let steps = Int(context.date.timeIntervalSince(startDate) / 0.25)
            let count = steps % (text.count + 8)

            Text(isWriting ? String(text.prefix(count)) : text)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 70, alignment: .top)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 130, alignment: .top)
        .background(Theme.board, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Theme.wood, lineWidth: 8)
        )
    }
}

// 老師旁邊的對話泡泡
struct SpeechBubble: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.headline.bold())
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.white, in: Capsule())
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
    }
}
