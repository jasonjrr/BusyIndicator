//
//  BusyIndicator+Environment.swift
//
//  Created by Jason Lew-Rapai on 12/5/22.
//

import SwiftUI

private struct BusyIndicatorKey: EnvironmentKey {
  static let defaultValue: BusyIndicator = .constant(false)
}

extension EnvironmentValues {
  public var busyIndicator: BusyIndicator {
    get { self[BusyIndicatorKey.self] }
    set { self[BusyIndicatorKey.self] = newValue }
  }
}

extension View {
  @inlinable
  public func busyIndicator(_ busyIndicator: BusyIndicator) -> some View {
    environment(\.busyIndicator, busyIndicator)
  }
}
