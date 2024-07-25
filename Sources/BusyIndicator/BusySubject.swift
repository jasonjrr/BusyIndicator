//
//  BusySubject.swift
//  
//
//  Created by Jason Lew-Rapai on 12/5/22.
//

import Foundation

protocol BusySubjectDelegate: AnyObject {
    func busySubjectDidDequeue(_ source: BusySubject)
}

/// A class representing a subject for managing the busy indicator state of a task.
public final class BusySubject {
    private weak var delegate: BusySubjectDelegate?
    
    private var isDequeued: Bool = false
    
    /// Initializes a `BusySubject` with the specified delegate.
    ///
    /// - Parameter delegate: The delegate conforming to `BusySubjectDelegate`.
    init(delegate: BusySubjectDelegate) {
        self.delegate = delegate
    }
    
    /// Deinitializes the `BusySubject` and triggers the dequeue operation.
    deinit {
        dequeue()
    }
    
    /// Dequeues the task associated with the `BusySubject`.
    public func dequeue() {
        if self.isDequeued { return }
        
        self.isDequeued = true
        self.delegate?.busySubjectDidDequeue(self)
    }
}
