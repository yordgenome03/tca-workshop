//
//  RepositoryRowView.swift
//  
//
//  Created by yotahara on 2024/09/12.
//

import ComposableArchitecture
import Entity

// MARK: - RepositoryRow

@Reducer
public struct RepositoryRow {
    @ObservableState
    public struct State: Equatable, Identifiable {        
        public var id: Int { repository.id }
        let repository: Repository
    }
    
    public enum Action {
        case rowTapped
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .rowTapped:
                return .none
            }    
        }
    }
}

// MARK: - RepositoryRowView

import SwiftUI

struct RepositoryRowView: View {
    let store: StoreOf<RepositoryRow>
    
    init(store: StoreOf<RepositoryRow>) {
        self.store = store
    }
    
    var body: some View {
        Button {
            store.send(.rowTapped)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(store.repository.fullName)
                    .font(.title2.bold())
                Text(store.repository.description ?? "")
                    .font(.body)
                    .lineLimit(2)
                HStack(alignment: .center, spacing: 32) {
                    Label(
                        title: {
                            Text("\(store.repository.stargazersCount)")
                                .font(.callout)
                        },
                        icon: {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    )
                    Label(
                        title: {
                            Text(store.repository.language ?? "")
                                .font(.callout)
                        },
                        icon: {
                            Image(systemName: "text.word.spacing")
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

#Preview {
    RepositoryRowView(
        store: .init(
            initialState: RepositoryRow.State(
                repository: .mock(id: 1)
            )
        ) {
            RepositoryRow()
        }
    )
    .padding()
}
