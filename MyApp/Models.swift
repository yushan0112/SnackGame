import SwiftUI

// MARK: - 遊戲階段
enum GamePhase {
    case ready       // 還沒開始
    case countdown   // 3、2、1 倒數
    case playing     // 遊戲中
    case finished    // 結束
}

// MARK: - 老師的狀態
enum TeacherState {
    case writing   // 背對學生寫黑板：可以偷吃
    case warning   // 咳嗽、準備轉頭：快停！
    case looking   // 轉過來看：被看到在吃就完蛋
}

// MARK: - 結束原因
enum EndReason {
    case caught    // 被抓到
    case timeUp    // 撐到下課
}

// MARK: - 難度
enum Difficulty: String, CaseIterable, Identifiable, Codable {
    case easy, normal, hard

    var id: Self { self }

    var title: String {
        switch self {
        case .easy: "簡單"
        case .normal: "普通"
        case .hard: "困難"
        }
    }

    var teacherName: String {
        switch self {
        case .easy: "愛睏的國文老師"
        case .normal: "嚴格的班導"
        case .hard: "鷹眼教官"
        }
    }

    var detail: String {
        switch self {
        case .easy: "寫黑板寫很久，咳嗽後過很久才轉頭。"
        case .normal: "會假裝要轉頭，咳嗽後不一定會轉。"
        case .hard: "轉頭超快又常常假動作，眼神很銳利。"
        }
    }

    // 背對學生寫黑板的時間（秒）
    var writingRange: ClosedRange<Double> {
        switch self {
        case .easy: 3.0...6.0
        case .normal: 2.0...5.0
        case .hard: 1.2...3.5
        }
    }

    // 咳嗽後到轉頭的時間（秒）
    var warningTime: Double {
        switch self {
        case .easy: 1.2
        case .normal: 0.8
        case .hard: 0.5
        }
    }

    // 咳完卻沒轉頭（假動作）的機率
    var fakeChance: Double {
        switch self {
        case .easy: 0
        case .normal: 0.2
        case .hard: 0.35
        }
    }

    // 轉過來盯著看的時間（秒）
    var lookingRange: ClosedRange<Double> {
        switch self {
        case .easy: 1.5...2.5
        case .normal: 1.5...3.0
        case .hard: 2.0...3.5
        }
    }
}

// MARK: - 零食
struct Snack {
    let emoji: String
    let name: String

    static let all: [Snack] = [
        Snack(emoji: "🍪", name: "巧克力餅乾"),
        Snack(emoji: "🍙", name: "鮪魚飯糰"),
        Snack(emoji: "🍩", name: "草莓甜甜圈"),
        Snack(emoji: "🍟", name: "麥當勞薯條"),
        Snack(emoji: "🍫", name: "牛奶巧克力"),
        Snack(emoji: "🍔", name: "起司漢堡"),
        Snack(emoji: "🍕", name: "夏威夷披薩"),
        Snack(emoji: "🍦", name: "霜淇淋")
    ]
}

// MARK: - 排行榜紀錄
struct ScoreRecord: Identifiable, Codable {
    var id = UUID()
    let name: String
    let score: Int
    let snacks: Int
    let difficulty: Difficulty
    let date: Date
}
