
import SwiftUI

struct RecentScores: View {
    @Environment(Game.self) private var game
    @Binding var animateViewsIn: Bool

    @State private var showAllScores = false
    @State private var blink = false

    var body: some View {
        VStack {
            if animateViewsIn {
                Button {
                    showAllScores.toggle()
                } label: {
                    VStack(spacing: 10) {
                        HStack {
                            Text("Recent Scores")
                            Image(systemName: "chevron.right")
                                .opacity(blink ? 1 : 0.3)
                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: blink)
                        }
                        .font(.title2)

                        ForEach(game.recentScoreEntries.sorted(by: { $0.timestamp > $1.timestamp })) { entry in

                            VStack {
                                Text("Score: \(entry.score)")
                                Text("🕒 \(formatTimestamp(entry.timestamp))")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                    .foregroundStyle(.foreStyle)
                    .background(.btnForeStyle.opacity(0.7))
                    .clipShape(.rect(cornerRadius: 15))
                }
                .onAppear { blink = true }
                .font(.title3)
                .transition(.opacity)
            }
        }
        .animation(.linear(duration: 1).delay(4), value: animateViewsIn)
        .sheet(isPresented: $showAllScores) {
            AllScores()
        }
    }

    private func formatTimestamp(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}


#Preview {
    let game = Game()
    game.recentScoreEntries = [
        ScoreEntry(id: "1", score: 87, timestamp: Date().timeIntervalSince1970 - 3600),
        ScoreEntry(id: "2", score: 92, timestamp: Date().timeIntervalSince1970 - 7200),
        ScoreEntry(id: "3", score: 100, timestamp: Date().timeIntervalSince1970 - 10800)
    ]
    
    return RecentScores(animateViewsIn: .constant(true))
        .environment(game)
}

