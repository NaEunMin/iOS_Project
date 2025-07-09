//
//  ContentView.swift
//  getSwipeSpeedData
//
//  Created by 나은민 on 7/9/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isTracking = false
    @State private var timer: Timer? = nil
    @State private var remainingTime = 5
    
    var body: some View {
        ZStack {
            SwipeTrackingViewRepresentable(isTracking: $isTracking)
        }
        
        VStack{
            if isTracking {
                Text("\(remainingTime)초 동안 화면을 스와이프 해주세요!!!")
                    .font(.title2)
                    .padding()
            }
            else{
                Text("버튼을 눌러 측정을 시작하세요!")
                    .font(.title2)
                    .padding()
            }
            Spacer()
            
            Button(action:{
                toggleTracking()
            }){
                Text(isTracking ? "측정 중지" : "측정 시작")
                    .font(.title)
                    .padding()
                    .background(isTracking ? Color.red: Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom,30)
        }
    }
    private func toggleTracking() {
        isTracking.toggle()
        
        if isTracking {
            //타이머 시작
            remainingTime = 5
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ _ in
                if self.remainingTime > 1{
                    self.remainingTime -= 1
                }
                else{
                    //5초종료
                    self.isTracking = false
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
        }
        else{
            //타이머 중지
            timer?.invalidate()
            timer = nil
        }
    }
}


    
//    #Preview {
//        ContentView()
//    }

