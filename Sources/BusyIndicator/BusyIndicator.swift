//
//  BusyIndicatorService.swift
//
//  Created by Jason Lew-Rapai on 12/5/22.
//

import Foundation
import Combine

/// Publishes the busy state of a `BusyIndicatorService`.
public class BusyIndicator {
    private let _busy: AnyPublisher<Bool, Never>
    /// The state of the busy signal. When `true` the indicatator is busy. When `false` the indicator is not busy.
    public var busy: AnyPublisher<Bool, Never> { self._busy }
    
    init(isBusy: Bool) {
        self._busy = Just(isBusy).eraseToAnyPublisher()
    }
    
    init(busy: AnyPublisher<Bool, Never>) {
        self._busy = busy
    }
}

extension BusyIndicator {
    /// Creates a `BusyIndicator` that emits a constant value of `isBusy`
    public static func constant(_ isBusy: Bool) -> BusyIndicator {
        BusyIndicator(isBusy: isBusy)
    }
}
