import SwiftUI

// 排行榜：前 10 名
struct LeaderboardView: View {
    @Environment(GameModel.self) private var game
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if game.records.isEmpty {
                    ContentUnavailableView("還沒有紀錄",
                                           systemImage: "trophy",
                                           description: Text("玩一場就會出現在這裡！"))
                } else {
                    List(Array(game.records.enumerated()), id: \.element.id) { index, record in
                        RecordRow(rank: index + 1, record: record)
                    }
                }
            }
            .navigationTitle("排行榜")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .fontDesign(.rounded)
    }
}

struct RecordRow: View {
    let rank: Int
    let record: ScoreRecord

    private var medal: String {
        switch rank {
        case 1: "🥇"
        case 2: "🥈"
        case 3: "🥉"
        default: "\(rank)"
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Text(medal)
                .font(rank <= 3 ? .title : .headline)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.name)
                    .font(.headline)
                Text("\(record.difficulty.title) · 吃完 \(record.snacks) 包 · \(record.date.formatted(date: .numeric, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(record.score) 口")
                .font(.title3.bold())
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
}
