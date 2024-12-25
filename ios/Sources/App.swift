import Core71
import SwiftUI

@main
struct Dev71: App {
    var body: some Scene {
        WindowGroup {
            Button("Hello World") {
                print(core71_init())
            }
            Text("Hello World")
        }
    }
}

#Preview {
    Text("hello world")
}
