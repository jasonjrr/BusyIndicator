//
//  File.swift
//  
//
//  Created by Jason Lew-Rapai on 12/5/22.
//

import SwiftUI

public struct BusyView<Content>: View where Content : View {
    @Environment(\.busyIndicator) var busyIndicator: BusyIndicator
    
    private let content: (Bool) -> Content
    
    @State private var isBusy: Bool = false
    
    init(@ViewBuilder content: @escaping (Bool) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            Color.clear.zIndex(0.0)
            self.content(self.isBusy)
        }
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
    ///         .busyOverlay(true)
    ///
    ///
    /// - Parameters:
    ///   - busyOverlay: The view to layer in front of this view.
    ///   - isBusy: The flag indicating when the original view should have
    ///     present the busy overlay.
    ///   - edges: The edges of the view that may be outset, any edges
    ///     not in this set will be unchanged, even if that edge is
    ///     abutting a safe area listed in `regions`.
    ///
    /// - Returns: A view that layers `overlay` in front of the view.
    public func busyOverlay<Content>(_ isBusy: Bool, edgesIgnoringSafeArea edges: Edge.Set = .all, @ViewBuilder content: @escaping (Bool) -> Content) -> some View where Content : View {
        self.overlay(
            BusyView { isBusy in
                content(isBusy)
            }
            .environment(\.busyIndicator, .constant(isBusy))
            .edgesIgnoringSafeArea(edges)
        )
    }
    
    public func busyOverlay<Content>(edgesIgnoringSafeArea edges: Edge.Set = .all, @ViewBuilder content: @escaping (Bool) -> Content) -> some View where Content : View {
        self.overlay(
            BusyView { isBusy in
                content(isBusy)
            }
            .edgesIgnoringSafeArea(edges)
        )
    }
}

extension View {
    public func busyOverlay(_ isBusy: Bool, edgesIgnoringSafeArea edges: Edge.Set = .all) -> some View {
        self.busyOverlay(isBusy, edgesIgnoringSafeArea: edges) { isBusy in
            if isBusy {
                ProgressView()
                    .transition(.opacity.animation(.easeInOut))
            }
        }
    }
    
    public func busyOverlay(edgesIgnoringSafeArea edges: Edge.Set = .all) -> some View {
        self.busyOverlay(edgesIgnoringSafeArea: edges) { isBusy in
            if isBusy {
                ProgressView()
                    .transition(.opacity.animation(.easeInOut))
            }
        }
    }
}
