import SwiftUI
import Core71

@main
struct Dev71: App {
    var body: some Scene {
        WindowGroup {
            Button("hello world") {
                print(core71_init())
            }
        }
    }
}
