//
//  BusyIndicatorService.swift
//
//  Created by Jason Lew-Rapai on 12/5/22.
//

import Foundation
import Combine

/// Publishes the busy state of a `BusyIndicatorService`.
public final class BusyIndicator {
    private let _busy: AnyPublisher<Bool, Never>
    /// The state of the busy signal. When `true` the indicator is busy. When `false` the indicator is not busy.
    public var busy: AnyPublisher<Bool, Never> { self._busy }
    
    private let _busyForIdentifier: (String) -> AnyPublisher<Bool, Never>
    
    init(isBusy: Bool) {
        self._busy = Just(isBusy).eraseToAnyPublisher()
        self._busyForIdentifier = { _ in
            Just(isBusy).eraseToAnyPublisher()
        }
    }
    
    init(busy: AnyPublisher<Bool, Never>, busyForIdentifier: @escaping (String) -> AnyPublisher<Bool, Never>) {
        self._busy = busy
        self._busyForIdentifier = busyForIdentifier
    }
    
    public func busy(for identifier: String) -> AnyPublisher<Bool, Never> {
        self._busyForIdentifier(identifier)
    }
}

extension BusyIndicator {
    /// Creates a `BusyIndicator` that emits a constant value of `isBusy`
    public static func constant(_ isBusy: Bool) -> BusyIndicator {
        BusyIndicator(isBusy: isBusy)
    }
}
