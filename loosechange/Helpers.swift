import Foundation
import SwiftUI

func authorizedFetchWithStatus(
    state: AppState,
    fetch: @MainActor () async throws -> Void
) async {
    if state.requiresLogin {
        return
    }
    
    state.fetchStatus = .fetching
    do {
        try await fetch()
        state.fetchStatus = .fetched
    } catch {
        state.fetchStatus = .errored
    }
}
