//
//  File.swift
//  
//
//  Created by Jason Lew-Rapai on 12/5/22.
//

import Foundation
import Combine
import SwiftUI

/// A protocol defining the behavior of a service responsible for managing busy indicators.
public protocol BusyIndicatorServiceProtocol: AnyObject {
    
    /// A publisher that emits the current queue size for the number of active `BusySubject`s.
    var queueCount: AnyPublisher<Int, Never> { get }
    
    /// The busy indicator object used to display loading states.
    var busyIndicator: BusyIndicator { get }
    
    /// Enqueues a task and returns a subject to manage its busy indicator state.
    ///
    /// - Returns: A `BusySubject` object to manage the busy indicator state of the enqueued task.
    func enqueue() -> BusySubject
    
    /// Enqueues a task and returns a subject to manage its busy indicator state.
    /// - Parameter identifier: The unique identifier within the queue.
    /// - Returns: A `BusySubject` object to manage the busy indicator state of the enqueued task.
    func enqueue(identifier: String) -> BusySubject
}

public class BusyIndicatorService: BusyIndicatorServiceProtocol {
    let configuration: BusyIndicatorConfiguration
    
    private let _queue: CurrentValueSubject<[String: WeakBox<BusySubject>], Never> = CurrentValueSubject([:])
    public var queueCount: AnyPublisher<Int, Never> {
        self._queue
            .map { $0.count }
            .eraseToAnyPublisher()
    }

    public private(set) lazy var busyIndicator: BusyIndicator = BusyIndicator(
        busy: getIsBusyPublisher(),
        busyForIdentifier: { [weak self] identifier in
            self?.getIsBusyPublisher(for: identifier) ?? Just(false).eraseToAnyPublisher()
        })
    
    private let queueDispatchQueue: DispatchQueue = DispatchQueue(label: "BusyIndicatorService-\(UUID().uuidString)")
    private let _enqueue: PassthroughSubject<BusySubject, Never> = PassthroughSubject()
    private let _dequeue: PassthroughSubject<String, Never> = PassthroughSubject()
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(configuration: BusyIndicatorConfiguration = BusyIndicatorConfiguration()) {
        self.configuration = configuration
        bind()
    }
    
    private func bind() {
        self._enqueue
            .receive(on: self.queueDispatchQueue)
            .withLatestFrom(self._queue) { ($0, $1) }
            .map { newSubject, queue in
                var queue = queue
                queue[newSubject.identifier]?.value?.markDequeued()
                queue[newSubject.identifier] = WeakBox(newSubject)
                return queue
            }
            .sink(receiveValue: { [_queue] in
                _queue.send($0)
            })
            .store(in: &self.cancellables)

        self._dequeue
            .receive(on: self.queueDispatchQueue)
            .withLatestFrom(self._queue) { ($0, $1) }
            .map { identifierToRemove, queue in
                var queue = queue
                queue[identifierToRemove] = nil
                return queue.filter { $0.value.value != nil }
            }
            .sink(receiveValue: { [_queue] in
                _queue.send($0)
            })
            .store(in: &self.cancellables)
    }
    
    public func enqueue() -> BusySubject {
        let subject = BusySubject(delegate: self)
        self._enqueue.send(subject)
        return subject
    }
    
    public func enqueue(identifier: String) -> BusySubject {
        let subject = BusySubject(delegate: self, identifier: identifier)
        self._enqueue.send(subject)
        return subject
    }
    
    private func getIsBusyPublisher() -> AnyPublisher<Bool, Never> {
        return self.queueCount
            .receive(on: self.queueDispatchQueue)
            .flatMapLatest { [configuration, queueDispatchQueue] queue -> AnyPublisher<Bool, Never> in
                if queue == 0 {
                    return Just(false).eraseToAnyPublisher()
                } else {
                    return Just(true)
                        .delay(for: .milliseconds(configuration.showBusyIndicatorDelay), scheduler: queueDispatchQueue)
                        .eraseToAnyPublisher()
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    private func getIsBusyPublisher(for identifier: String) -> AnyPublisher<Bool, Never> {
        self._queue
            .receive(on: self.queueDispatchQueue)
            .map { $0[identifier]?.value != nil }
            .eraseToAnyPublisher()
    }
}

// MARK: BusySubjectDelegate
extension BusyIndicatorService: BusySubjectDelegate {
    func busySubjectDidDequeue(_ source: BusySubject, for identifier: String) {
        self._dequeue.send(identifier)
    }
}

// MARK: WeakBox
private class WeakBox<T: AnyObject> {
    weak var value: T?
    
    init(_ value: T) {
        self.value = value
    }
}
