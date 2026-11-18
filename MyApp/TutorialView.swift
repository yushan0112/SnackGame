import SwiftUI

// 教學頁面：左右滑動看玩法
struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var page = 0

    private let pages: [(emoji: String, title: String, text: String)] = [
        ("🍪", "按住螢幕偷吃", "按住下方的書桌就會開始吃零食，放開就停。吃越多口分數越高！"),
        ("🧑‍🏫", "老師背對時最安全", "老師在寫黑板時可以放心吃，右上角會顯示綠色的「安全」。"),
        ("😷", "聽到咳嗽快放手", "老師咳嗽代表要轉頭了，右上角變成橘色「小心」，趕快放開！有時候老師只是假咳嗽。"),
        ("👀", "被看到就完蛋", "老師轉過來時還在吃，或是在老師盯著你的時候偷吃，就會被抓到，遊戲結束。"),
        ("🔥", "連吃加成", "不間斷地吃越久，加成越高，最多 3 倍。放手一次加成就歸零，要冒險嗎？")
    ]

    var body: some View {
        VStack(spacing: 20) {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { i in
                    TutorialPage(emoji: pages[i].emoji,
                                 title: pages[i].title,
                                 text: pages[i].text)
                        .tag(i)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button {
                if page < pages.count - 1 {
                    withAnimation { page += 1 }
                } else {
                    dismiss()
                }
            } label: {
                Text(page < pages.count - 1 ? "下一頁" : "我學會了！")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.teal.gradient, in: Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .padding(.top, 30)
        .background(Theme.paper.ignoresSafeArea())
        .fontDesign(.rounded)
    }
}

struct TutorialPage: View {
    let emoji: String
    let title: String
    let text: String

    var body: some View {
        VStack(spacing: 20) {
            Text(emoji)
                .font(.system(size: 110))
            Text(title)
                .font(.title.bold())
            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.bottom, 40)
    }
}

#Preview {
    TutorialView()
}
