//
//  SwipeTrackingViewRepresentable.swift
//  getSwipeSpeedData
//
//  Created by 나은민 on 7/9/25.
//

import SwiftUI

struct SwipeTrackingViewRepresentable: UIViewRepresentable {
    
    func makeUIView(context: Context) -> SwipeTrackingView {
        let view = SwipeTrackingView()
        
        //5초 후 측정 종료
        DispatchQueue.main.asyncAfter(deadline: .now() + 5){
            view.endTracking()
        }
        return view
    }
    
    func updateUIView(_ uiView: SwipeTrackingView, context: Context) {
        //업데이트 필요 없음
    }
}
