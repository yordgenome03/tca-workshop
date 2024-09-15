import Dependencies
import Entity
import Foundation
import XCTestDynamicOverlay

public struct GithubAPIClient {
    public var searchRepositories: @Sendable (_ query: String) async throws -> [Repository]
}

extension GithubAPIClient: DependencyKey {
    public static let liveValue = Self(
        searchRepositories: { query in
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
}

private let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()

extension GithubAPIClient: TestDependencyKey {
    public static let previewValue = Self(
        searchRepositories: { _ in [] }
    )
    
    public static let testValue = Self(
        searchRepositories: unimplemented("\(Self.self).searchRepositories")
    )
}

extension DependencyValues {
    public var gitHubAPIClient: GithubAPIClient {
        get { self[GithubAPIClient] }
        set { self[GithubAPIClient] = newValue }
    }
}
