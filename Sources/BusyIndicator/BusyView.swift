//
//  BusyView.swift
//  
//
//  Created by Jason Lew-Rapai on 12/5/22.
//

import SwiftUI

public struct BusyView<Content>: View where Content : View {
    @Environment(\.busyIndicator) var busyIndicator: BusyIndicator
    
    private let content: () -> Content
    
    @State private var isBusy: Bool = false
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            Color.clear.zIndex(0.0)
            if self.isBusy {
                self.content()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: self.isBusy)
        .allowsHitTesting(self.isBusy)
        .onReceive(self.busyIndicator.busy.receive(on: DispatchQueue.main)) { isBusy in
            self.isBusy = isBusy
        }
    }
}

#if DEBUG
struct BusyView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Rectangle()
                .fill(Color.purple)
                .frame(width: .infinity, height: .infinity)
                .busyOverlay(true)
        }
    }
}
#endif

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
    ///         .busyOverlay(true) {
    ///             CustomContentView()
    ///         }
    ///
    /// - Parameters:
    ///   - isBusy: The flag indicating when the original view should have
    ///     present the busy overlay.
    ///   - edges: The edges of the view that may be outset, any edges
    ///     not in this set will be unchanged, even if that edge is
    ///     abutting a safe area listed in `regions`.
    ///   - content: The view to layer in front of the modified view.
    ///
    /// - Returns: A view that layers `content` in front of the modified view.
    public func busyOverlay<Content>(_ isBusy: Bool, edgesIgnoringSafeArea edges: Edge.Set = .all, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        self.overlay(
            BusyView {
                content()
            }
            .environment(\.busyIndicator, .constant(isBusy))
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
    ///         .busyOverlay {
    ///             CustomContentView()
    ///         }
    ///
    /// - Parameters:
    ///   - edges: The edges of the view that may be outset, any edges
    ///     not in this set will be unchanged, even if that edge is
    ///     abutting a safe area listed in `regions`.
    ///   - content: The view to layer in front of the modified view.
    ///
    /// - Returns: A view that layers `content` in front of the modified view.
    public func busyOverlay<Content>(edgesIgnoringSafeArea edges: Edge.Set = .all, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        self.overlay(
            BusyView {
                content()
            }
            .edgesIgnoringSafeArea(edges)
        )
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
    ///         .busyOverlay(true)
    ///
    /// - Parameters:
    ///   - isBusy: The flag indicating when the original view should have
    ///     present the busy overlay.
    ///   - edges: The edges of the view that may be outset, any edges
    ///     not in this set will be unchanged, even if that edge is
    ///     abutting a safe area listed in `regions`.
    ///
    /// - Returns: A view that layers a default progress view in front of the
    ///   modified view.
    public func busyOverlay(_ isBusy: Bool, edgesIgnoringSafeArea edges: Edge.Set = .all) -> some View {
        self.busyOverlay(isBusy, edgesIgnoringSafeArea: edges) {
            DefaultProgressView()
        }
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
    ///   - edges: The edges of the view that may be outset, any edges
    ///     not in this set will be unchanged, even if that edge is
    ///     abutting a safe area listed in `regions`.
    ///
    /// - Returns: A view that layers a default progress view in front of the
    ///   modified view.
    public func busyOverlay(edgesIgnoringSafeArea edges: Edge.Set = .all) -> some View {
        self.busyOverlay(edgesIgnoringSafeArea: edges) {
            DefaultProgressView()
        }
    }
}
