//
//  BusyIndicatorConfiguration.swift
//  
//
//  Created by Jason Lew-Rapai on 12/12/22.
//

import Foundation

/// A configuration class for customizing the behavior of a busy indicator.
public class BusyIndicatorConfiguration {
    /// Delay (in milliseconds) before showing the busy indicator's view once the queue is greater than or equal to 1.
    public var showBusyIndicatorDelay: Int = 850
    
    /// Initializes a `BusyIndicatorConfiguration` with default values.
    public init() {}
}
