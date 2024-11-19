import SwiftUI
import Core71

public struct ContentView: View {
    public init() {}

    public var body: some View {
        Button("Hello, World!") {
            print(Core71.add(1, 2))
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
