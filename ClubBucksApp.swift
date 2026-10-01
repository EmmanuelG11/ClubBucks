import SwiftUI

@main
struct ClubBucksApp: App {

    @StateObject private var store = ClubBucksStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}
