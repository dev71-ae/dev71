import SwiftUI
import Prelude

struct Dev71: App {
	var body: some Scene {
		WindowGroup {
            Button("Hello, World!") {
                print(prelude_init())
            }
		}
	}
}

Dev71.main()
