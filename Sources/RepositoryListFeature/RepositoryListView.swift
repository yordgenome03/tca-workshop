import ComposableArchitecture
import Entity
import Foundation

@Reducer
public struct RepositoryList {
    
    @ObservableState
    public struct State: Equatable {
        var repositories: [Repository] = []
        var isLoading: Bool = false
        
        public init() {}
    }
    
    public enum Action {
        case onAppear
        case searchRepositoriesResponse(Result<[Repository], Error>)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await send(
                        .searchRepositoriesResponse(
                            Result {
                                let query = "composable"
                                let url = URL(string: "https://api.github.com/search/repositories?q=\(query)&sort=stars")!
                                var request = URLRequest(url: url)
                                if let token = Bundle.main.infoDictionary?["GitHubPersonalAccessToken"] as? String {
                                    request.setValue(
                                        "Bearer \(token)",
                                        forHTTPHeaderField: "Authorization")
                                }
                                let (data, _) = try await URLSession.shared.data(for: request)
                                let repositories = try jsonDecoder.decode(
                                    GithubSearchResult.self,
                                    from: data
                                ).items
                                return repositories
                            }
                        )
                    )    
                }
            case let .searchRepositoriesResponse(result):
                state.isLoading = false
                
                switch result {
                case let .success(response):
                    state.repositories = response
                    return .none
                case .failure:
                    // TODO: Handling error
                    return .none
                }
            }
        }
    }
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

// MARK: - View

import SwiftUI

public struct RepositoryListView: View {
    let store: StoreOf<RepositoryList>
    
    public init(store: StoreOf<RepositoryList>) {
        self.store = store
    }
    
    public var body: some View {
        Group {
            if store.isLoading {
                ProgressView()
            } else {
                List {
                    ForEach(store.repositories, id: \.id) { repository in
                        Button {
                            
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(repository.fullName)
                                    .font(.title2.bold())
                                Text(repository.description ?? "")
                                    .font(.body)
                                    .lineLimit(2)
                                HStack(allignment: .center, spacing: 32) {
                                    Label(
                                        title: {
                                            Text("\(repository.stargazersCount)")
                                                .font(.callout)
                                        },
                                        icon: {
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(.gray)
                                        }
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    } 
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

