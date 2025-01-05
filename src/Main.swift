import SwiftUI
import Prelude

@main
struct Dev71: App {
	var body: some Scene {
		WindowGroup {
            Button("Hello, World!") {
                print(prelude_init())
            }
		}
	}
}
