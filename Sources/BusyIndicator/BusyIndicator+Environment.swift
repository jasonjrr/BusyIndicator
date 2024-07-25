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

/// An extension on `View` that allows setting a busy indicator in the `Environment`.
extension View {
    
    /// Sets the busy indicator for the view.
    ///
    /// - Parameters:
    ///   - busyIndicator: The `BusyIndicator` to be displayed.
    /// - Returns: A modified view with the specified `BusyIndicator`.
    @inlinable
    public func busyIndicator(_ busyIndicator: BusyIndicator) -> some View {
        environment(\.busyIndicator, busyIndicator)
    }
}
