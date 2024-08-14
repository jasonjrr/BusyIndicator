//
//  BusySubject.swift
//  
//
//  Created by Jason Lew-Rapai on 12/5/22.
//

import Foundation

protocol BusySubjectDelegate: AnyObject {
    func busySubjectDidDequeue(_ source: BusySubject, for identifier: String)
}

/// A class representing a subject for managing the busy indicator state of a task.
public final class BusySubject {
    let identifier: String
    private weak var delegate: BusySubjectDelegate?
    
    private var isDequeued: Bool = false
    
    /// Initializes a `BusySubject` with the specified delegate.
    ///
    /// - Parameters:
    ///   - delegate: The delegate conforming to `BusySubjectDelegate`.
    ///   - identifier: The unique identifier within the `BusyIndicatorService`'s queue.
    init(delegate: BusySubjectDelegate, identifier: String = UUID().uuidString) {
        self.delegate = delegate
        self.identifier = identifier
    }
    
    /// Deinitializes the `BusySubject` and triggers the dequeue operation.
    deinit {
        dequeue()
    }
    
    /// Marks the `BusySubject` as dequeued.
    func markDequeued() {
        self.isDequeued = true
    }

    /// Dequeues the task associated with the `BusySubject`.
    public func dequeue() {
        if self.isDequeued { return }
        
        self.isDequeued = true
        self.delegate?.busySubjectDidDequeue(self, for: self.identifier)
    }
}
