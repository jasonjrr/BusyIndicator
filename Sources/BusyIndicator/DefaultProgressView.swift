//
//  DefaultProgressView.swift
//  
//
//  Created by Jason Lew-Rapai on 8/14/24.
//

import SwiftUI

struct DefaultProgressView: View {
    var body: some View {
        if #available(iOS 15.0, *) {
            ZStack {
                Color.clear
                ProgressView()
            }
            .background(.ultraThinMaterial)
        } else {
            ZStack {
                Color.clear
                ProgressView()
            }
        }
    }
}
