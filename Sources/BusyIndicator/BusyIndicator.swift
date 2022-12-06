//
//  BusyIndicatorService.swift
//
//  Created by Jason Lew-Rapai on 12/5/22.
//

import Foundation
import Combine

public class BusyIndicator {
  private let _busy: AnyPublisher<Bool, Never>
  public var busy: AnyPublisher<Bool, Never> { self._busy }
  
  init(isBusy: Bool) {
    self._busy = Just(isBusy).eraseToAnyPublisher()
  }
  
  init(busy: AnyPublisher<Bool, Never>) {
    self._busy = busy
  }
}

extension BusyIndicator {
  public static func constant(_ isBusy: Bool) -> BusyIndicator {
    BusyIndicator(isBusy: isBusy)
  }
}
