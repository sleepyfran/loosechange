import Foundation
import Combine

class RemoteState<T>: ObservableObject {
    @Published var remote = RemoteContent<T>.notRequested
    private var cancellable: Cancellable?

    func fetch(
        appState: AppState,
        action: () -> AnyPublisher<T, ApiError>
    ) {
        if appState.requiresLogin {
            return
        }
        
        remote = .loading
        cancellable = action()
            .receive(on: DispatchQueue.main)
            .map(RemoteContent.done)
            .catch { error in
                Just(RemoteContent.failed(error))
            }
            .assign(to: \.remote, on: self)
    }
}
