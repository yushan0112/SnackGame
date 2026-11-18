import SwiftUI

// 設定頁面
struct SettingsView: View {
    @Environment(GameModel.self) private var game
    @Environment(\.dismiss) private var dismiss
    @State private var confirmClear = false

    var body: some View {
        // @Bindable 讓 Observable 物件可以產生 $ 綁定
        @Bindable var game = game

        NavigationStack {
            Form {
                Section("玩家") {
                    TextField("你的名字", text: $game.playerName)
                }

                Section {
                    Picker("難度", selection: $game.difficulty) {
                        ForEach(Difficulty.allCases) { level in
                            Text(level.title).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(game.difficulty.teacherName)
                            .font(.headline)
                        Text(game.difficulty.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("老師")
                }

                Section("一節課多久") {
                    Picker("時間", selection: $game.duration) {
                        Text("30 秒").tag(30)
                        Text("60 秒").tag(60)
                        Text("90 秒").tag(90)
                    }
                    .pickerStyle(.segmented)
                }

                Section("聲音") {
                    Toggle(isOn: $game.soundOn) {
                        Label("音效", systemImage: "speaker.wave.2.fill")
                    }
                    Toggle(isOn: $game.musicOn) {
                        Label("背景音樂", systemImage: "music.note")
                    }
                }

                Section {
                    Button("清除排行榜", role: .destructive) {
                        confirmClear = true
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
            .alert("要清除所有紀錄嗎？", isPresented: $confirmClear) {
                Button("取消", role: .cancel) { }
                Button("清除", role: .destructive) { game.clearRecords() }
            }
        }
        .fontDesign(.rounded)
    }
}
