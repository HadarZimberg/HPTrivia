import Foundation
import FirebaseDatabase

@Observable
class BookQuestions {
    var books: [Book] = []
    
    
    init() {
        loadQuestions { questions in
            let organizedQuestions = self.organizeQuestions(questions)
            self.populateBooks(with: organizedQuestions)
        }
    }
    
    // Loads questions from Firebase - falls back to local JSON if necessary
    private func loadQuestions(completion: @escaping ([Question]) -> Void) {
        let ref = Database.database().reference().child("questions")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                print("Firebase empty or nil - falling back to local JSON.")
                completion(self.decodeQuestions())
                return
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: value)
                let questions = try JSONDecoder().decode([Question].self, from: data)
                print("Successfully loaded questions from Firebase.")
                completion(questions)
            } catch {
                print("Error decoding Firebase data: \(error.localizedDescription) - using local JSON.")
                completion(self.decodeQuestions())
            }
            
        } withCancel: { error in
            print("Firebase request failed: \(error.localizedDescription) - using local JSON.")
            completion(self.decodeQuestions())
        }
    }
    
    // Loads questions from local trivia.json
    private func decodeQuestions() -> [Question] {
        var decodedQuestions: [Question] = []
        
        if let url = Bundle.main.url(forResource: "trivia", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                decodedQuestions = try JSONDecoder().decode([Question].self, from: data)
            } catch {
                print("Error decoding JSON data: \(error)")
            }
        }
        return decodedQuestions
    }
    
    // Fills books array using grouped questions
    private func organizeQuestions(_ questions: [Question]) -> [[Question]] {
        var organizedQuestions: [[Question]] = [[], [], [], [], [], [], [], []]
        
        for question in questions {
            organizedQuestions[question.book].append(question)
        }
        
        return organizedQuestions
    }
    
    // Fills books array using grouped questions
    private func populateBooks(with questions: [[Question]]) {
        books.append(Book(id: 1, image: "hp1", questions: questions[1], status: .active))
        books.append(Book(id: 2, image: "hp2", questions: questions[2], status: .active))
        books.append(Book(id: 3, image: "hp3", questions: questions[3], status: .inactive))
        books.append(Book(id: 4, image: "hp4", questions: questions[4], status: .locked))
        books.append(Book(id: 5, image: "hp5", questions: questions[5], status: .locked))
        books.append(Book(id: 6, image: "hp6", questions: questions[6], status: .locked))
        books.append(Book(id: 7, image: "hp7", questions: questions[7], status: .locked))
    }
    
    func changeStatus(of id: Int, to status: BookStatus) {
        books[id-1].status = status
    }
}
