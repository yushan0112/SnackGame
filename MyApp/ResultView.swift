import SwiftUI

// 遊戲結束的結算卡片
struct ResultView: View {
    @Environment(GameModel.self) private var game
    let onHome: () -> Void

    @State private var showLeaderboard = false

    private var caught: Bool { game.endReason == .caught }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text(caught ? "😱" : "🔔")
                    .font(.system(size: 70))

                Text(caught ? "被抓到了！" : "下課鐘響！")
                    .font(.largeTitle.bold())

                Text(caught ? "老師：「你在吃什麼？拿過來！」" : "成功撐過一整節課，沒被發現！")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                stats

                if let rank = game.newRank {
                    Label(rank == 1 ? "新紀錄！排行榜第 1 名" : "進入排行榜第 \(rank) 名",
                          systemImage: "trophy.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)
                        .symbolEffect(.bounce, value: rank)
                }

                buttons
            }
            .padding(26)
            .frame(maxWidth: 360)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 30))
            .padding(24)
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView()
                .environment(game)
        }
    }

    private var stats: some View {
        HStack(spacing: 30) {
            StatItem(value: "\(game.score)", unit: "口", title: "偷吃")
            StatItem(value: "\(game.snacksEaten)", unit: "包", title: "吃完")
            StatItem(value: game.difficulty.title, unit: "", title: "難度")
        }
        .padding(.vertical, 6)
    }

    private var buttons: some View {
        VStack(spacing: 12) {
            // Replay：再玩一次
            Button {
                game.start()
            } label: {
                Label("再玩一次", systemImage: "arrow.counterclockwise")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Theme.accent.gradient, in: Capsule())
            }

            HStack(spacing: 12) {
                Button {
                    showLeaderboard = true
                } label: {
                    Label("排行榜", systemImage: "trophy")
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(.white.opacity(0.7), in: Capsule())
                }
                Button(action: onHome) {
                    Label("回首頁", systemImage: "house")
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(.white.opacity(0.7), in: Capsule())
                }
            }
            .font(.subheadline.bold())
        }
    }
}

struct StatItem: View {
    let value: String
    let unit: String
    let title: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title.bold())
                Text(unit)
                    .font(.caption)
            }
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
