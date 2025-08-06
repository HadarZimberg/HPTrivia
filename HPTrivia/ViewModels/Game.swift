import SwiftUI
import FirebaseDatabase

@Observable
class Game {
    var bookQuestions = BookQuestions()
    var gameScore = 0
    var questionScore = 5
    var activeQuestions: [Question] = []
    var answeredQuestions: [Int] = []
    var currentQuestion = try! JSONDecoder().decode([Question].self, from: Data(contentsOf: Bundle.main.url(forResource: "trivia", withExtension: "json")!))[0]
    var answers: [String] = []
    var recentScoreEntries: [ScoreEntry] = []
    var allScoreEntries: [ScoreEntry] = []
    
    let savePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: "RecentScore")
    
    init() {
        loadScores()
    }
    
    func startGame() {
        for book in bookQuestions.books {
            if book.status == .active {
                for question in book.questions {
                    activeQuestions.append(question) // collecting question from all active books
                }
            }
        }
        newQuestion()
    }
    
    func newQuestion() {
        if answeredQuestions.count == activeQuestions.count {
            answeredQuestions = []
        }
        currentQuestion = activeQuestions.randomElement()!
        
        while(answeredQuestions.contains(currentQuestion.id)) { // avoid duplicates
            currentQuestion = activeQuestions.randomElement()!
        }
        
        answers = []
        answers.append(currentQuestion.answer) // shuffle answers
        
        for answer in currentQuestion.wrong {
            answers.append(answer)
        }
        
        answers.shuffle()
        questionScore = 5
    }
    
    func correct() {
        answeredQuestions.append(currentQuestion.id)
        withAnimation {
            gameScore += questionScore
        }
    }
    
    func endGame() {
        let score = gameScore
        let timestamp = Date().timeIntervalSince1970

        let ref = Database.database().reference().child("scores").childByAutoId()
        let scoreData: [String: Any] = [ // save score to firebase
            "score": score,
            "timestamp": timestamp
        ]
        ref.setValue(scoreData) { error, _ in
            if error == nil {
                self.loadScores() // Reload scores once saved
            } else {
                print("Failed to save score: \(error!.localizedDescription)")
            }
        }

        gameScore = 0
        activeQuestions = []
        answeredQuestions = []
    }

    
    func loadScores() { // load the 3 last score for home page
        let ref = Database.database().reference().child("scores")
        ref.queryOrdered(byChild: "timestamp").queryLimited(toLast: 3).observeSingleEvent(of: .value) { snapshot in
            var scores: [ScoreEntry] = []

            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any],
                   let score = dict["score"] as? Int,
                   let timestamp = dict["timestamp"] as? TimeInterval {
                    scores.append(ScoreEntry(id: snap.key, score: score, timestamp: timestamp))
                }
            }

            // Sort oldest → newest
            scores.sort(by: { $0.timestamp < $1.timestamp })
            self.recentScoreEntries = scores
        }
    }
    
    func loadAllScores() {
        let ref = Database.database().reference().child("scores")
        ref.queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { snapshot in
            var all: [ScoreEntry] = []
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any],
                   let score = dict["score"] as? Int,
                   let timestamp = dict["timestamp"] as? TimeInterval {
                    all.append(ScoreEntry(id: snap.key, score: score, timestamp: timestamp))
                }
            }
            self.allScoreEntries = all
        }
    }

}

