import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct HPTriviaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var game: Game? = nil

    var body: some Scene {
        WindowGroup {
            if let game = game {
                ContentView()
                    .environment(game)
            } else {
                ProgressView("Loading...")
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.game = Game()
                        }
                    }
            }
        }
    }
}
