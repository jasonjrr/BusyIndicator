//
//  CombineExt
//  Borrowed from the CombineExt project and copied internally to avoid
//  importing the whole of CombineExt.
//
//  Copyright © 2020 Combine Community. All rights reserved.
//  https://github.com/CombineCommunity/CombineExt
//

#if canImport(Combine)
import Combine
import class Foundation.NSRecursiveLock

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    /// Transforms an output value into a new publisher, and flattens the stream of events from these multiple upstream publishers to appear as if they were coming from a single stream of events
    ///
    /// Mapping to a new publisher will cancel the subscription to the previous one, keeping only a single
    /// subscription active along with its event emissions
    ///
    /// - parameter transform: A transform to apply to each emitted value, from which you can return a new Publisher
    ///
    /// - note: This operator is a combination of `map` and `switchToLatest`
    ///
    /// - returns: A publisher emitting the values of the latest inner publisher
    func flatMapLatest<P: Publisher>(_ transform: @escaping (Output) -> P) -> Publishers.SwitchToLatest<P, Publishers.Map<Self, P>> {
        map(transform).switchToLatest()
    }
}

// MARK: WithLatestFrom
// MARK: - Operator methods
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
  ///  Merges two publishers into a single publisher by combining each value
  ///  from self with the latest value from the second publisher, if any.
  ///
  ///  - parameter other: A second publisher source.
  ///  - parameter resultSelector: Function to invoke for each value from the self combined
  ///                              with the latest value from the second source, if any.
  ///
  ///  - returns: A publisher containing the result of combining each value of the self
  ///             with the latest value from the second publisher, if any, using the
  ///             specified result selector function.
  func withLatestFrom<Other: Publisher, Result>(_ other: Other,
                                                resultSelector: @escaping (Output, Other.Output) -> Result)
    -> Publishers.WithLatestFrom<Self, Other, Result> {
      return .init(upstream: self, second: other, resultSelector: resultSelector)
  }

  ///  Merges three publishers into a single publisher by combining each value
  ///  from self with the latest value from the second and third publisher, if any.
  ///
  ///  - parameter other: A second publisher source.
  ///  - parameter other1: A third publisher source.
  ///  - parameter resultSelector: Function to invoke for each value from the self combined
  ///                              with the latest value from the second and third source, if any.
  ///
  ///  - returns: A publisher containing the result of combining each value of the self
  ///             with the latest value from the second and third publisher, if any, using the
  ///             specified result selector function.
  func withLatestFrom<Other: Publisher, Other1: Publisher, Result>(_ other: Other,
                                                                   _ other1: Other1,
                                                                   resultSelector: @escaping (Output, (Other.Output, Other1.Output)) -> Result)
    -> Publishers.WithLatestFrom<Self, AnyPublisher<(Other.Output, Other1.Output), Self.Failure>, Result>
    where Other.Failure == Failure, Other1.Failure == Failure {
      let combined = other.combineLatest(other1)
        .eraseToAnyPublisher()
      return .init(upstream: self, second: combined, resultSelector: resultSelector)
  }

  ///  Merges four publishers into a single publisher by combining each value
  ///  from self with the latest value from the second, third and fourth publisher, if any.
  ///
  ///  - parameter other: A second publisher source.
  ///  - parameter other1: A third publisher source.
  ///  - parameter other2: A fourth publisher source.
  ///  - parameter resultSelector: Function to invoke for each value from the self combined
  ///                              with the latest value from the second, third and fourth source, if any.
  ///
  ///  - returns: A publisher containing the result of combining each value of the self
  ///             with the latest value from the second, third and fourth publisher, if any, using the
  ///             specified result selector function.
  func withLatestFrom<Other: Publisher, Other1: Publisher, Other2: Publisher, Result>(_ other: Other,
                                                                                      _ other1: Other1,
                                                                                      _ other2: Other2,
                                                                                      resultSelector: @escaping (Output, (Other.Output, Other1.Output, Other2.Output)) -> Result)
    -> Publishers.WithLatestFrom<Self, AnyPublisher<(Other.Output, Other1.Output, Other2.Output), Self.Failure>, Result>
    where Other.Failure == Failure, Other1.Failure == Failure, Other2.Failure == Failure {
      let combined = other.combineLatest(other1, other2)
        .eraseToAnyPublisher()
      return .init(upstream: self, second: combined, resultSelector: resultSelector)
  }

  ///  Upon an emission from self, emit the latest value from the
  ///  second publisher, if any exists.
  ///
  ///  - parameter other: A second publisher source.
  ///
  ///  - returns: A publisher containing the latest value from the second publisher, if any.
  func withLatestFrom<Other: Publisher>(_ other: Other)
    -> Publishers.WithLatestFrom<Self, Other, Other.Output> {
      return .init(upstream: self, second: other) { $1 }
  }

  /// Upon an emission from self, emit the latest value from the
  /// second and third publisher, if any exists.
  ///
  /// - parameter other: A second publisher source.
  /// - parameter other1: A third publisher source.
  ///
  /// - returns: A publisher containing the latest value from the second and third publisher, if any.
  func withLatestFrom<Other: Publisher, Other1: Publisher>(_ other: Other,
                                                           _ other1: Other1)
    -> Publishers.WithLatestFrom<Self, AnyPublisher<(Other.Output, Other1.Output), Self.Failure>, (Other.Output, Other1.Output)>
    where Other.Failure == Failure, Other1.Failure == Failure {
     withLatestFrom(other, other1) { $1 }
  }

  /// Upon an emission from self, emit the latest value from the
  /// second, third and forth publisher, if any exists.
  ///
  /// - parameter other: A second publisher source.
  /// - parameter other1: A third publisher source.
  /// - parameter other2: A forth publisher source.
  ///
  /// - returns: A publisher containing the latest value from the second, third and forth publisher, if any.
  func withLatestFrom<Other: Publisher, Other1: Publisher, Other2: Publisher>(_ other: Other,
                                                                              _ other1: Other1,
                                                                              _ other2: Other2)
    -> Publishers.WithLatestFrom<Self, AnyPublisher<(Other.Output, Other1.Output, Other2.Output), Self.Failure>, (Other.Output, Other1.Output, Other2.Output)>
    where Other.Failure == Failure, Other1.Failure == Failure, Other2.Failure == Failure {
     withLatestFrom(other, other1, other2) { $1 }
  }
}

// MARK: - Publisher
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publishers {
  struct WithLatestFrom<Upstream: Publisher,
                        Other: Publisher,
                        Output>: Publisher where Upstream.Failure == Other.Failure {
    public typealias Failure = Upstream.Failure
    public typealias ResultSelector = (Upstream.Output, Other.Output) -> Output

    private let upstream: Upstream
    private let second: Other
    private let resultSelector: ResultSelector
    private var latestValue: Other.Output?

    init(upstream: Upstream,
         second: Other,
         resultSelector: @escaping ResultSelector) {
      self.upstream = upstream
      self.second = second
      self.resultSelector = resultSelector
    }

    public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        subscriber.receive(subscription: Subscription(upstream: upstream,
                                                      downstream: subscriber,
                                                      second: second,
                                                      resultSelector: resultSelector))
    }
  }
}

// MARK: - Subscription
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private extension Publishers.WithLatestFrom {
  class Subscription<Downstream: Subscriber>: Combine.Subscription, CustomStringConvertible where Downstream.Input == Output, Downstream.Failure == Failure {
    private let resultSelector: ResultSelector
    private var sink: Sink<Upstream, Downstream>?

    private let upstream: Upstream
    private let downstream: Downstream
    private let second: Other

    // Secondary (other) publisher
    private var latestValue: Other.Output?
    private var otherSubscription: Cancellable?
    private var preInitialDemand = Subscribers.Demand.none

    init(upstream: Upstream,
         downstream: Downstream,
         second: Other,
         resultSelector: @escaping ResultSelector) {
        self.upstream = upstream
        self.second = second
        self.downstream = downstream
        self.resultSelector = resultSelector

        trackLatestFromSecond { [weak self] in
            guard let self = self else { return }
            self.request(self.preInitialDemand)
            self.preInitialDemand = .none
        }
    }

    func request(_ demand: Subscribers.Demand) {
        guard latestValue != nil else {
            preInitialDemand += demand
            return
        }

        self.sink?.demand(demand)
    }

    // Create an internal subscription to the `Other` publisher,
    // constantly tracking its latest value
    private func trackLatestFromSecond(onInitialValue: @escaping () -> Void) {
      var gotInitialValue = false

      let subscriber = AnySubscriber<Other.Output, Other.Failure>(
        receiveSubscription: { [weak self] subscription in
            self?.otherSubscription = subscription
            subscription.request(.unlimited)
        },
        receiveValue: { [weak self] value in
            guard let self = self else { return .none }
            self.latestValue = value

            if !gotInitialValue {
                // When getting initial value, start pulling values
                // from upstream in the main sink
                self.sink = Sink(upstream: self.upstream,
                                 downstream: self.downstream,
                                 transformOutput: { [weak self] value in
                                    guard let self = self,
                                          let other = self.latestValue else { return nil }

                                    return self.resultSelector(value, other)
                                 },
                                 transformFailure: { $0 })

                // Signal initial value to start fulfilling downstream demand
                gotInitialValue = true
                onInitialValue()
            }

            return .unlimited
        },
        receiveCompletion: nil)

      self.second.subscribe(subscriber)
    }

    var description: String {
        return "WithLatestFrom.Subscription<\(Output.self), \(Failure.self)>"
    }

    func cancel() {
        sink?.cancelUpstream()
        sink = nil
        otherSubscription?.cancel()
    }
  }
}

// MARK: Sink
//
//  CombineExt
//
//  Created by Shai Mishali on 14/03/2020.
//  Copyright © 2020 Combine Community. All rights reserved.
//

/// A generic sink using an underlying demand buffer to balance
/// the demand of a downstream subscriber for the events of an
/// upstream publisher
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class Sink<Upstream: Publisher, Downstream: Subscriber>: Subscriber {
    typealias TransformFailure = (Upstream.Failure) -> Downstream.Failure?
    typealias TransformOutput = (Upstream.Output) -> Downstream.Input?

    private(set) var buffer: DemandBuffer<Downstream>
    private var upstreamSubscription: Subscription?
    private let transformOutput: TransformOutput?
    private let transformFailure: TransformFailure?

    /// Initialize a new sink subscribing to the upstream publisher and
    /// fulfilling the demand of the downstream subscriber using a backpresurre
    /// demand-maintaining buffer.
    ///
    /// - parameter upstream: The upstream publisher
    /// - parameter downstream: The downstream subscriber
    /// - parameter transformOutput: Transform the upstream publisher's output type to the downstream's input type
    /// - parameter transformFailure: Transform the upstream failure type to the downstream's failure type
    ///
    /// - note: You **must** provide the two transformation functions above if you're using
    ///         the default `Sink` implementation. Otherwise, you must subclass `Sink` with your own
    ///         publisher's sink and manage the buffer accordingly.
    init(upstream: Upstream,
         downstream: Downstream,
         transformOutput: TransformOutput? = nil,
         transformFailure: TransformFailure? = nil) {
        self.buffer = DemandBuffer(subscriber: downstream)
        self.transformOutput = transformOutput
        self.transformFailure = transformFailure
        upstream.subscribe(self)
    }

    func demand(_ demand: Subscribers.Demand) {
        let newDemand = buffer.demand(demand)
        upstreamSubscription?.requestIfNeeded(newDemand)
    }

    func receive(subscription: Subscription) {
        upstreamSubscription = subscription
    }

    func receive(_ input: Upstream.Output) -> Subscribers.Demand {
        guard let transform = transformOutput else {
            fatalError("""
                ❌ Missing output transformation
                =========================

                You must either:
                    - Provide a transformation function from the upstream's output to the downstream's input; or
                    - Subclass `Sink` with your own publisher's Sink and manage the buffer yourself
            """)
        }

        guard let input = transform(input) else { return .none }
        return buffer.buffer(value: input)
    }

    func receive(completion: Subscribers.Completion<Upstream.Failure>) {
        switch completion {
        case .finished:
            buffer.complete(completion: .finished)
        case .failure(let error):
            guard let transform = transformFailure else {
                fatalError("""
                    ❌ Missing failure transformation
                    =========================

                    You must either:
                        - Provide a transformation function from the upstream's failure to the downstream's failuer; or
                        - Subclass `Sink` with your own publisher's Sink and manage the buffer yourself
                """)
            }

            guard let error = transform(error) else { return }
            buffer.complete(completion: .failure(error))
        }

        cancelUpstream()
    }

    func cancelUpstream() {
        upstreamSubscription.kill()
    }

    deinit { cancelUpstream() }
}

// MARK: DemandBuffer

/// A buffer responsible for managing the demand of a downstream
/// subscriber for an upstream publisher
///
/// It buffers values and completion events and forwards them dynamically
/// according to the demand requested by the downstream
///
/// In a sense, the subscription only relays the requests for demand, as well
/// the events emitted by the upstream — to this buffer, which manages
/// the entire behavior and backpressure contract
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class DemandBuffer<S: Subscriber> {
    private let lock = NSRecursiveLock()
    private var buffer = [S.Input]()
    private let subscriber: S
    private var completion: Subscribers.Completion<S.Failure>?
    private var demandState = Demand()

    /// Initialize a new demand buffer for a provided downstream subscriber
    ///
    /// - parameter subscriber: The downstream subscriber demanding events
    init(subscriber: S) {
        self.subscriber = subscriber
    }

    /// Buffer an upstream value to later be forwarded to
    /// the downstream subscriber, once it demands it
    ///
    /// - parameter value: Upstream value to buffer
    ///
    /// - returns: The demand fulfilled by the bufferr
    func buffer(value: S.Input) -> Subscribers.Demand {
        precondition(self.completion == nil,
                     "How could a completed publisher sent values?! Beats me 🤷‍♂️")
        lock.lock()
        defer { lock.unlock() }

        switch demandState.requested {
        case .unlimited:
            return subscriber.receive(value)
        default:
            buffer.append(value)
            return flush()
        }
    }

    /// Complete the demand buffer with an upstream completion event
    ///
    /// This method will deplete the buffer immediately,
    /// based on the currently accumulated demand, and relay the
    /// completion event down as soon as demand is fulfilled
    ///
    /// - parameter completion: Completion event
    func complete(completion: Subscribers.Completion<S.Failure>) {
        precondition(self.completion == nil,
                     "Completion have already occured, which is quite awkward 🥺")

        self.completion = completion
        _ = flush()
    }

    /// Signal to the buffer that the downstream requested new demand
    ///
    /// - note: The buffer will attempt to flush as many events rqeuested
    ///         by the downstream at this point
    func demand(_ demand: Subscribers.Demand) -> Subscribers.Demand {
        flush(adding: demand)
    }

    /// Flush buffered events to the downstream based on the current
    /// state of the downstream's demand
    ///
    /// - parameter newDemand: The new demand to add. If `nil`, the flush isn't the
    ///                        result of an explicit demand change
    ///
    /// - note: After fulfilling the downstream's request, if completion
    ///         has already occured, the buffer will be cleared and the
    ///         completion event will be sent to the downstream subscriber
    private func flush(adding newDemand: Subscribers.Demand? = nil) -> Subscribers.Demand {
        lock.lock()
        defer { lock.unlock() }

        if let newDemand = newDemand {
            demandState.requested += newDemand
        }

        // If buffer isn't ready for flushing, return immediately
        guard demandState.requested > 0 || newDemand == Subscribers.Demand.none else { return .none }

        while !buffer.isEmpty && demandState.processed < demandState.requested {
            demandState.requested += subscriber.receive(buffer.remove(at: 0))
            demandState.processed += 1
        }

        if let completion = completion {
            // Completion event was already sent
            buffer = []
            demandState = .init()
            self.completion = nil
            subscriber.receive(completion: completion)
            return .none
        }

        let sentDemand = demandState.requested - demandState.sent
        demandState.sent += sentDemand
        return sentDemand
    }
}

// MARK: - Private Helpers
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private extension DemandBuffer {
    /// A model that tracks the downstream's
    /// accumulated demand state
    struct Demand {
        var processed: Subscribers.Demand = .none
        var requested: Subscribers.Demand = .none
        var sent: Subscribers.Demand = .none
    }
}

// MARK: - Internally-scoped helpers
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Subscription {
    /// Reqeust demand if it's not empty
    ///
    /// - parameter demand: Requested demand
    func requestIfNeeded(_ demand: Subscribers.Demand) {
        guard demand > .none else { return }
        request(demand)
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Optional where Wrapped == Subscription {
    /// Cancel the Optional subscription and nullify it
    mutating func kill() {
        self?.cancel()
        self = nil
    }
}
#endif
