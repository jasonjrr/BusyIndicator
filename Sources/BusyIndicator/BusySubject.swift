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

public class BusySubject {
    private weak var delegate: BusySubjectDelegate?
    
    private var isDequeued: Bool = false
    
    init(delegate: any BusySubjectDelegate) {
        self.delegate = delegate
    }
    
    deinit {
        dequeue()
    }
    
    public func dequeue() {
        if self.isDequeued { return }
        
        self.isDequeued = true
        self.delegate?.busySubjectDidDequeue(self)
    }
}
