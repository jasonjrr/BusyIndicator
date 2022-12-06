//
//  File.swift
//  
//
//  Created by Jason Lew-Rapai on 12/5/22.
//

import Foundation
import Combine
import SwiftUI

public protocol BusyIndicatorServiceProtocol: AnyObject {
    var queue: AnyPublisher<Int, Never> { get }
    var busyIndicator: BusyIndicator { get }
    func enqueue() -> BusySubject
}

public class BusyIndicatorService: BusyIndicatorServiceProtocol {
    private var _queue: CurrentValueSubject<Int, Never> = CurrentValueSubject(0)
    public var queue: AnyPublisher<Int, Never> { self._queue.eraseToAnyPublisher() }

    public private(set) lazy var busyIndicator: BusyIndicator = BusyIndicator(busy: getIsBusyPublisher())
    
    private let queueDispatchQueue: DispatchQueue = DispatchQueue(label: "BusyIndicatorService-\(UUID().uuidString)")
    private let _enqueue: PassthroughSubject<Void, Never> = PassthroughSubject()
    private let _dequeue: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    private var cancelBag = Set<AnyCancellable>()
    
    public init() {
        bind()
    }
    
    private func bind() {
        let queue = self._queue
        
        self._enqueue
            .receive(on: self.queueDispatchQueue)
            .withLatestFrom(queue)
            .map { $0 + 1 }
            .print("## enqueue")
            .sink(receiveValue: {
                queue.send($0)
            })
            .store(in: &self.cancelBag)

        self._dequeue
            .receive(on: self.queueDispatchQueue)
            .withLatestFrom(queue)
            .map { max(0, $0 - 1) }
            .print("## dequeue")
            .sink(receiveValue: {
                queue.send($0)
            })
            .store(in: &self.cancelBag)
    }
    
    public func enqueue() -> BusySubject {
        self._enqueue.send()
        return BusySubject(delegate: self)
    }
    
    private func getIsBusyPublisher() -> AnyPublisher<Bool, Never> {
        let dispatchQueue = self.queueDispatchQueue
        return self._queue
            .print("## queue")
            .receive(on: dispatchQueue)
            .flatMapLatest { queue -> AnyPublisher<Bool, Never> in
                if queue == 0 {
                    print("## busyIndicator false path")
                    return Just(false).eraseToAnyPublisher()
                } else {
                    print("## busyIndicator true path")
                    return Just(true)
                        .delay(for: 0.85, scheduler: dispatchQueue)
                        .eraseToAnyPublisher()
                }
            }
            .removeDuplicates()
            .print("## busyIndicator output")
            .eraseToAnyPublisher()
    }
}

extension BusyIndicatorService: BusySubjectDelegate {
    func busySubjectDidDequeue(_ source: BusySubject) {
        self._dequeue.send()
    }
}
