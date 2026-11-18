import AVFoundation

// 遊戲裡的音效，檔名要和放進專案的 .wav 一樣
enum SoundEffect: String, CaseIterable {
    case crunch   // 咀嚼
    case cough    // 老師咳嗽
    case caught   // 被抓到
    case tick     // 倒數嗶聲
    case go       // 開始
    case win      // 下課
    case pop      // 吃完一包
}

final class SoundManager {
    static let shared = SoundManager()

    var effectsOn = true
    var musicOn = true

    private var players: [SoundEffect: AVAudioPlayer] = [:]
    private var musicPlayer: AVAudioPlayer?

    private init() {
        // ambient：不會打斷使用者正在聽的音樂，靜音模式時也不會發出聲音
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)

        for effect in SoundEffect.allCases {
            if let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "wav"),
               let player = try? AVAudioPlayer(contentsOf: url) {
                player.prepareToPlay()
                players[effect] = player
            }
        }

        if let url = Bundle.main.url(forResource: "bgm", withExtension: "wav") {
            musicPlayer = try? AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1   // 無限循環
            musicPlayer?.volume = 0.45
            musicPlayer?.prepareToPlay()
        }
    }

    func play(_ effect: SoundEffect) {
        guard effectsOn, let player = players[effect] else { return }
        player.currentTime = 0
        player.play()
    }

    func startMusic() {
        guard musicOn else { return }
        musicPlayer?.currentTime = 0
        musicPlayer?.play()
    }

    func stopMusic() {
        musicPlayer?.stop()
    }
}
