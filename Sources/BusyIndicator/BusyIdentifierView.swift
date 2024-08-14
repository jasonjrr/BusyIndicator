//
//  BusyIdentifierView.swift
//
//
//  Created by Jason Lew-Rapai on 8/14/24.
//

import SwiftUI
import Combine

public struct BusyIdentifierView<Content>: View where Content : View {
    @Environment(\.busyIndicator) var busyIndicator: BusyIndicator
    
    private let identifier: String
    private let content: () -> Content
    
    @State private var isBusy: Bool = false
    
    init(_ identifier: String, @ViewBuilder content: @escaping () -> Content) {
        self.identifier = identifier
        self.content = content
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            Color.clear.zIndex(0.0)
            if self.isBusy {
                self.content()
                    .transition(.opacity.animation(.easeInOut))
            }
        }
        .allowsHitTesting(self.isBusy)
        .onReceive(self.busyIndicator.busy(for: self.identifier).receive(on: DispatchQueue.main)) { isBusy in
            self.isBusy = isBusy
        }
    }
}

extension View {
    /// Layers a secondary view to indicate a busy state in front of this view.
    ///
    /// When you apply a busyOverlay to a view, the original view continues to
    /// provide the layout characteristics for the resulting view. In the
    /// following example, the Content view is shown overlaid in front of, and
    /// aligned to the bottom of the folder image.
    ///
    ///     Image(systemName: "folder")
    ///         .font(.system(size: 55, weight: .thin))
    ///         .busyOverlay {
    ///             CustomContentView()
    ///         }
    ///
    /// - Parameters:
    ///   - identifier: The identifier used to filter the busy signal.
    ///   - edges: The edges of the view that may be outset, any edges
    ///     not in this set will be unchanged, even if that edge is
    ///     abutting a safe area listed in `regions`.
    ///   - content: The view to layer in front of the modified view.
    ///
    /// - Returns: A view that layers `content` in front of the modified view.
    public func busyOverlay<Content>(identifier: String, edgesIgnoringSafeArea edges: Edge.Set = .all, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        self.overlay(
            BusyIdentifierView(identifier) {
                content()
            }
            .edgesIgnoringSafeArea(edges)
        )
    }

    /// Layers a secondary view to indicate a busy state in front of this view.
    ///
    /// When you apply a busyOverlay to a view, the original view continues to
    /// provide the layout characteristics for the resulting view. In the
    /// following example, the Content view is shown overlaid in front of, and
    /// aligned to the bottom of the folder image.
    ///
    ///     Image(systemName: "folder")
    ///         .font(.system(size: 55, weight: .thin))
    ///         .busyOverlay()
    ///
    /// - Parameters:
    ///   - identifier: The identifier used to filter the busy signal.
    ///   - edges: The edges of the view that may be outset, any edges
    ///     not in this set will be unchanged, even if that edge is
    ///     abutting a safe area listed in `regions`.
    ///
    /// - Returns: A view that layers a default progress view in front of the
    ///   modified view.
    public func busyOverlay(identifier: String, edgesIgnoringSafeArea edges: Edge.Set = .all) -> some View {
        self.busyOverlay(identifier: identifier, edgesIgnoringSafeArea: edges) {
            DefaultProgressView()
        }
    }
}
