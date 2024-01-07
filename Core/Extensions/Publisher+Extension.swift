import Combine
import Foundation

// MARK: - Handle Events -

public extension Publisher {
    func handleEvents(
        receiveOutput: ((Output) -> Void)? = nil,
        receiveError: ((Error) -> Void)? = nil
    ) -> Publishers.HandleEvents<Self> {
        handleEvents(
            receiveOutput: receiveOutput,
            receiveCompletion: {
                if case .failure(let error) = $0 {
                    receiveError?(error)
                }
            }
        )
    }
}

// MARK: - Receive and Cancel -

public extension Publisher {
    func receiveAndCancel(
        receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void),
        receiveOutput: ((Output) -> Void)? = nil
    ) {
        var cancellable: AnyCancellable? // Needs to be optional to avoid Swift syntax error
        cancellable = self
            .sink(
                receiveCompletion: {
                    receiveCompletion($0)

                    cancellable?.cancel()
                },
                receiveValue: {
                    receiveOutput?($0)
                }
            )
    }

    func receiveAndCancel(
        receiveOutput: ((Output) -> Void)? = nil,
        receiveError: ((Error) -> Void)? = nil,
        receiveCompletion: (() -> Void)? = nil
    ) {
        receiveAndCancel(
            receiveCompletion: {
                if case .failure(let error) = $0 {
                    receiveError?(error)
                }
                receiveCompletion?()
            },
            receiveOutput: receiveOutput
        )
    }
}

// MARK: - Sink -

public extension Publisher {
    func sink(
        receiveError: ((Error) -> Void)? = nil,
        receiveValue: @escaping (Output) -> Void
    ) -> AnyCancellable {
        sink {
            if case .failure(let error) = $0 {
                receiveError?(error)
            }
        } receiveValue: {
            receiveValue($0)
        }
    }
}


// MARK: - Shared stream -

public extension Publisher {
    /// Wraps subject output to have only one unique upstream (output pipeline) for multiple subscribers.
    ///
    /// The publisher returned by this operator supports multiple subscribers, all of whom receive unchanged elements and completion states from the upstream publisher.
    ///
    /// - Note: If ``share()`` isn't used, the number of upstreams is equal to the number of the subscribers which leads to
    /// having duplicates or different values in different subscribers.
    ///
    /// - Returns: A publisher whose output is shared with all subscribers
    func eraseToSharedPublisher() -> AnyPublisher<Output, Failure> {
        self
            .share()
            .eraseToAnyPublisher()
    }
}
