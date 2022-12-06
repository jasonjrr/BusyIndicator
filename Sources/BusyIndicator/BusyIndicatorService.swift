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

class BusyIndicatorService: BusyIndicatorServiceProtocol {
    private var _queue: CurrentValueSubject<Int, Never> = CurrentValueSubject(0)
    var queue: AnyPublisher<Int, Never> { self._queue.eraseToAnyPublisher() }
    
    private let busyValueSubject: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    private(set) lazy var busyIndicator: BusyIndicator = BusyIndicator(
        busy: self._queue
            .map { queue -> AnyPublisher<Bool, Never> in
                if queue == 0 {
                    return Just(false).eraseToAnyPublisher()
                } else {
                    return Just(true)
                        .delay(for: 0.85, scheduler: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive))
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .removeDuplicates()
            .multicast(subject: self.busyValueSubject)
            .eraseToAnyPublisher()
    )
    
    private let queueDispatchQueue: DispatchQueue = DispatchQueue(label: "BusyIndicatorService-\(UUID().uuidString)")
    private let _enqueue: PassthroughSubject<Void, Never> = PassthroughSubject()
    private let _dequeue: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    private var cancelBag = Set<AnyCancellable>()
    
    init() {
        bind()
    }
    
    private func bind() {
        let queue = self._queue
        
        self._enqueue
            .receive(on: self.queueDispatchQueue)
            .map { queue.value + 1 }
            .sink(receiveValue: { queue.send($0) })
            .store(in: &self.cancelBag)

        self._dequeue
            .receive(on: self.queueDispatchQueue)
            .map { max(0, queue.value - 1) }
            .sink(receiveValue: { queue.send($0) })
            .store(in: &self.cancelBag)
    }
    
    func enqueue() -> BusySubject {
        self._enqueue.send()
        return BusySubject(delegate: self)
    }
}

extension BusyIndicatorService: BusySubjectDelegate {
    func busySubjectDidDequeue(_ source: BusySubject) {
        self._dequeue.send()
    }
}
