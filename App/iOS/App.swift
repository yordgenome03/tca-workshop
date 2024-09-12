import SwiftUI
import RepositoryListFeature

@main
struct TCAWorkshopApp: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            RepositoryListView(
                store: .init(
                    initialState: RepositoryList.State()
                ) {
                    RepositoryList()   
                }
            )
        }
    }
}
