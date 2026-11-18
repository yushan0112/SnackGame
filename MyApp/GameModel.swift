import SwiftUI
import Observation

// 用 Observation 管理整個遊戲的狀態
@Observable
final class GameModel {

    // MARK: - 設定（改了會自動存起來）
    var playerName: String {
        didSet { defaults.set(playerName, forKey: Keys.playerName) }
    }
    var difficulty: Difficulty {
        didSet { defaults.set(difficulty.rawValue, forKey: Keys.difficulty) }
    }
    var duration: Int {
        didSet { defaults.set(duration, forKey: Keys.duration) }
    }
    var soundOn: Bool {
        didSet {
            defaults.set(soundOn, forKey: Keys.soundOn)
            sound.effectsOn = soundOn
        }
    }
    var musicOn: Bool {
        didSet {
            defaults.set(musicOn, forKey: Keys.musicOn)
            sound.musicOn = musicOn
            if !musicOn { sound.stopMusic() }
        }
    }

    // MARK: - 遊戲狀態
    var phase: GamePhase = .ready
    var teacher: TeacherState = .writing
    var countdown = 3
    var timeRemaining: Double = 60
    var score = 0                 // 吃了幾口
    var snacksEaten = 0           // 吃完幾包
    var snackIndex = 0
    var snackProgress: Double = 0 // 目前這包吃了多少（0～1）
    var combo = 1                 // 連續偷吃的加成，最多 3 倍
    var isEating = false
    var endReason: EndReason = .timeUp
    var newRank: Int?             // 這次進排行榜的名次

    // MARK: - 排行榜
    var records: [ScoreRecord] = []

    var bestScore: Int { records.map(\.score).max() ?? 0 }
    var currentSnack: Snack { Snack.all[snackIndex] }

    // MARK: - 內部使用
    private let sound = SoundManager.shared
    private let defaults = UserDefaults.standard
    private var gameTask: Task<Void, Never>?
    private var teacherTask: Task<Void, Never>?
    private var eatTime: Double = 0          // 這次連續吃了幾秒
    private var biteBuffer: Double = 0
    private var crunchBuffer: Double = 0

    private let bitesPerSnack = 40
    private let tickInterval = 0.05

    private enum Keys {
        static let playerName = "playerName"
        static let difficulty = "difficulty"
        static let duration = "duration"
        static let soundOn = "soundOn"
        static let musicOn = "musicOn"
        static let records = "records"
    }

    init() {
        let defaults = UserDefaults.standard
        playerName = defaults.string(forKey: Keys.playerName) ?? "我"
        difficulty = Difficulty(rawValue: defaults.string(forKey: Keys.difficulty) ?? "") ?? .normal
        duration = defaults.object(forKey: Keys.duration) as? Int ?? 60
        soundOn = defaults.object(forKey: Keys.soundOn) as? Bool ?? true
        musicOn = defaults.object(forKey: Keys.musicOn) as? Bool ?? true

        if let data = defaults.data(forKey: Keys.records),
           let saved = try? JSONDecoder().decode([ScoreRecord].self, from: data) {
            records = saved
        }

        sound.effectsOn = soundOn
        sound.musicOn = musicOn
    }

    // MARK: - 開始 / 再玩一次
    func start() {
        stop()

        teacher = .writing
        timeRemaining = Double(duration)
        score = 0
        snacksEaten = 0
        snackIndex = Int.random(in: 0..<Snack.all.count)
        snackProgress = 0
        combo = 1
        isEating = false
        newRank = nil
        eatTime = 0
        biteBuffer = 0
        crunchBuffer = 0

        phase = .countdown
        countdown = 3

        gameTask = Task {
            // 3、2、1 倒數
            for number in stride(from: 3, through: 1, by: -1) {
                countdown = number
                sound.play(.tick)
                try? await Task.sleep(for: .seconds(0.8))
                if Task.isCancelled { return }
            }

            phase = .playing
            sound.play(.go)
            sound.startMusic()

            teacherTask = Task { await runTeacher() }
            await runGameLoop()
        }
    }

    // 離開遊戲時呼叫，停止所有計時
    func stop() {
        gameTask?.cancel()
        teacherTask?.cancel()
        gameTask = nil
        teacherTask = nil
        isEating = false
        sound.stopMusic()
        if phase != .finished {
            phase = .ready
        }
    }

    // MARK: - 玩家操作
    func startEating() {
        guard phase == .playing, !isEating else { return }
        isEating = true
        eatTime = 0
        // 老師正在看還敢吃？直接抓包
        if teacher == .looking {
            finish(.caught)
        }
    }

    func stopEating() {
        isEating = false
        eatTime = 0
        combo = 1
    }

    // MARK: - 遊戲主迴圈：每 0.05 秒更新一次
    private func runGameLoop() async {
        while phase == .playing {
            try? await Task.sleep(for: .seconds(tickInterval))
            if Task.isCancelled { return }
            tick(tickInterval)
        }
    }

    private func tick(_ dt: Double) {
        guard phase == .playing else { return }

        timeRemaining = max(0, timeRemaining - dt)

        if isEating {
            if teacher == .looking {
                finish(.caught)
                return
            }

            // 連續吃越久加成越高：每 2 秒 +1，最多 3 倍
            eatTime += dt
            combo = min(3, 1 + Int(eatTime / 2))

            // 基本速度每秒 10 口
            biteBuffer += dt * 10 * Double(combo)
            let bites = Int(biteBuffer)
            if bites > 0 {
                biteBuffer -= Double(bites)
                addBites(bites)
            }

            crunchBuffer += dt
            if crunchBuffer >= 0.35 {
                crunchBuffer = 0
                sound.play(.crunch)
            }
        }

        if timeRemaining <= 0 {
            finish(.timeUp)
        }
    }

    private func addBites(_ bites: Int) {
        score += bites
        snackProgress += Double(bites) / Double(bitesPerSnack)

        while snackProgress >= 1 {
            snackProgress -= 1
            snacksEaten += 1
            snackIndex = (snackIndex + 1) % Snack.all.count
            sound.play(.pop)
        }
    }

    // MARK: - 老師的行為：用 Task.sleep 控制節奏
    private func runTeacher() async {
        while phase == .playing {
            // 1. 背對學生寫黑板
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                teacher = .writing
            }
            await wait(Double.random(in: difficulty.writingRange))
            guard phase == .playing, !Task.isCancelled else { return }

            // 2. 咳嗽，準備轉頭
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                teacher = .warning
            }
            sound.play(.cough)
            await wait(difficulty.warningTime)
            guard phase == .playing, !Task.isCancelled else { return }

            // 假動作：咳完繼續寫黑板
            if Double.random(in: 0..<1) < difficulty.fakeChance {
                continue
            }

            // 3. 轉過來看
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                teacher = .looking
            }
            if isEating {
                finish(.caught)
                return
            }
            await wait(Double.random(in: difficulty.lookingRange))
        }
    }

    private func wait(_ seconds: Double) async {
        try? await Task.sleep(for: .seconds(seconds))
    }

    // MARK: - 遊戲結束
    private func finish(_ reason: EndReason) {
        guard phase == .playing else { return }

        endReason = reason
        isEating = false
        teacherTask?.cancel()
        sound.stopMusic()

        if reason == .caught {
            withAnimation(.spring) { teacher = .looking }
            sound.play(.caught)
        } else {
            sound.play(.win)
        }

        saveRecord()

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            phase = .finished
        }
    }

    private func saveRecord() {
        guard score > 0 else { return }

        let record = ScoreRecord(name: playerName.isEmpty ? "無名氏" : playerName,
                                 score: score,
                                 snacks: snacksEaten,
                                 difficulty: difficulty,
                                 date: .now)
        records.append(record)
        records.sort { $0.score > $1.score }
        records = Array(records.prefix(10))

        if let index = records.firstIndex(where: { $0.id == record.id }) {
            newRank = index + 1
        }
        saveRecords()
    }

    func clearRecords() {
        records = []
        saveRecords()
    }

    private func saveRecords() {
        if let data = try? JSONEncoder().encode(records) {
            defaults.set(data, forKey: Keys.records)
        }
    }
}
