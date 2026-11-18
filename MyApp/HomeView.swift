import SwiftUI

// 首頁
struct HomeView: View {
    @Environment(GameModel.self) private var game

    @State private var showGame = false
    @State private var showTutorial = false
    @State private var showLeaderboard = false
    @State private var showSettings = false

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()
                titleBoard
                FloatingSnacks()
                bestScoreCard
                Spacer()
                startButton
                menuButtons
            }
            .padding(24)
        }
        .fontDesign(.rounded)
        .fullScreenCover(isPresented: $showGame) {
            GameView()
                .environment(game)
        }
        .sheet(isPresented: $showTutorial) {
            TutorialView()
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView()
                .environment(game)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environment(game)
        }
    }

    // 黑板上的標題
    private var titleBoard: some View {
        VStack(spacing: 10) {
            Text("上課偷吃零食")
                .font(.system(size: 38, weight: .heavy))
            Text("～不要被老師抓到～")
                .font(.headline)
                .opacity(0.8)
        }
        .foregroundStyle(.white)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .background(Theme.board, in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Theme.wood, lineWidth: 10)
        )
        .shadow(color: .black.opacity(0.2), radius: 10, y: 6)
    }

    private var bestScoreCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "trophy.fill")
                .foregroundStyle(.yellow)
            Text("最高紀錄")
                .foregroundStyle(.secondary)
            Text("\(game.bestScore) 口")
                .font(.title3.bold())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.white.opacity(0.7), in: Capsule())
    }

    private var startButton: some View {
        Button {
            showGame = true
        } label: {
            Label("開始上課", systemImage: "play.fill")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Theme.accent.gradient, in: Capsule())
                .shadow(color: Theme.accent.opacity(0.4), radius: 10, y: 6)
        }
    }

    private var menuButtons: some View {
        HStack(spacing: 14) {
            MenuButton(title: "教學", icon: "book.fill", color: .teal) {
                showTutorial = true
            }
            MenuButton(title: "排行榜", icon: "trophy.fill", color: .orange) {
                showLeaderboard = true
            }
            MenuButton(title: "設定", icon: "gearshape.fill", color: .indigo) {
                showSettings = true
            }
        }
    }
}

// 首頁下方的小按鈕
struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.subheadline.bold())
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .frame(height: 76)
            .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 18))
        }
    }
}

// 首頁上下飄動的零食
struct FloatingSnacks: View {
    @State private var floating = false

    var body: some View {
        HStack(spacing: 18) {
            ForEach(0..<5, id: \.self) { i in
                Text(Snack.all[i].emoji)
                    .font(.system(size: 40))
                    .offset(y: floating ? -10 : 10)
                    .animation(
                        .easeInOut(duration: 1)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.15),
                        value: floating
                    )
            }
        }
        .onAppear { floating = true }
    }
}

// 共用顏色
enum Theme {
    static let paper = Color(red: 0.99, green: 0.95, blue: 0.86)
    static let board = Color(red: 0.16, green: 0.36, blue: 0.27)
    static let wood = Color(red: 0.62, green: 0.42, blue: 0.25)
    static let desk = Color(red: 0.85, green: 0.66, blue: 0.43)
    static let accent = Color(red: 0.95, green: 0.45, blue: 0.25)
    static let skin = Color(red: 1.0, green: 0.84, blue: 0.7)
    static let hair = Color(red: 0.25, green: 0.17, blue: 0.12)
}

#Preview {
    HomeView()
        .environment(GameModel())
}
