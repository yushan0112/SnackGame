import SwiftUI

@main
struct SnackGameApp: App {
    // 整個遊戲共用一個 GameModel，用 environment 傳給所有畫面
    @State private var game = GameModel()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(game)
        }
    }
}
