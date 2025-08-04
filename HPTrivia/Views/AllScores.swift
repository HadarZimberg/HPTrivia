import SwiftUI

struct AllScores: View {
    @Environment(Game.self) private var game
    @Environment(\.dismiss) private var dismiss

    var body: some View {
            ZStack {
                Image("parchment")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .background(.brown)

                List(game.allScoreEntries.sorted(by: { $0.timestamp > $1.timestamp })) { entry in
                    VStack {
                        Text("Score: \(entry.score)")
                            .font(.headline)
                        Text("🕒 \(formatTimestamp(entry.timestamp))")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 4)
                    .listRowBackground(Color.clear)
                    .padding(.bottom, 16)
                }
                .scrollContentBackground(.hidden) // hide default List background
            }
            .navigationTitle("All Scores")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        .onAppear {
            game.loadAllScores()
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
