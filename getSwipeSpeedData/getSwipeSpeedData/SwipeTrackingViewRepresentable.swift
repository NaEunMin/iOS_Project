
//
//  SwipeTrackingViewRepresentable.swift
//  getSwipeSpeedData
//
//  Created by 나은민 on 7/9/25.
//

import SwiftUI
import UIKit

struct SwipeTrackingViewRepresentable: UIViewRepresentable {
    
    var view: SwipeTrackingView
    @Binding var state: ContentView.TrackingState
    @Binding var currentSpeed: CGFloat

    func makeUIView(context: Context) -> SwipeTrackingView {
        // Coordinator를 view의 delegate로 설정
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: SwipeTrackingView, context: Context) {
        switch state {
        case .tracking:
            if !uiView.isTrackingEnabled {
                uiView.startTracking()
            }
        case .finished, .idle:
            if uiView.isTrackingEnabled {
                uiView.endTracking()
            }
        }
    }
    
    // Coordinator 생성
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator 클래스 정의
    class Coordinator: NSObject, SwipeTrackingViewDelegate {
        var parent: SwipeTrackingViewRepresentable

        init(_ parent: SwipeTrackingViewRepresentable) {
            self.parent = parent
        }

        // SwipeTrackingViewDelegate의 메소드 구현
        func didUpdate(speed: CGFloat) {
            // 전달받은 속력을 ContentView의 @State 변수에 업데이트
            parent.currentSpeed = speed
        }
        
        func didFinish(with data: [SwipeDataPoint]) {
            // 데이터는 SwipeTrackingView가 직접 관리하므로 여기서는 아무것도 하지 않음
        }
    }
}

