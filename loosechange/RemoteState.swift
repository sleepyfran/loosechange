import Foundation
import Combine

class RemoteState<T>: ObservableObject {
    @Published var remote = RemoteContent<T>.notRequested
    private var cancellable: Cancellable?

    func fetch(
        appState: AppState,
        publisher: AnyPublisher<T, ApiError>
    ) {
        if appState.requiresLogin {
            return
        }
        
        remote = .loading
        cancellable = publisher
            .receive(on: DispatchQueue.main)
            .map(RemoteContent.done)
            .catch { error in
                Just(RemoteContent.failed(error))
            }
            .sink { [weak self] remote in
                self?.remote = remote
            }
    }
}
