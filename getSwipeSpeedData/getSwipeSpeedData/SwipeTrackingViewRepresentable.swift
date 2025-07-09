//
//  SwipeTrackingViewRepresentable.swift
//  getSwipeSpeedData
//
//  Created by 나은민 on 7/9/25.
//

import SwiftUI
import UIKit

struct SwipeTrackingViewRepresentable: UIViewRepresentable {
    
    @Binding var isTracking: Bool
    let view = SwipeTrackingView()
    func makeUIView(context: Context) -> SwipeTrackingView {
        return view
    }
    
    func updateUIView(_ uiView: SwipeTrackingView, context: Context) {
        if isTracking{
            uiView.startTracking()
        }
        else{
            uiView.endTracking()
        }
    }
}
