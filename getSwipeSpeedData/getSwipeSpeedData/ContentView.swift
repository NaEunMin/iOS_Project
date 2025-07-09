//
//  ContentView.swift
//  getSwipeSpeedData
//
//  Created by 나은민 on 7/9/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            SwipeTrackingViewRepresentable()
        }
        
        VStack{
            Text("5초동안 화면을 스와이프 해주세요!!!")
                .font(.title2)
                .padding()
            Spacer()
        }
    }
    
//    #Preview {
//        ContentView()
//    }
}
