//
//  ContentView.swift
//  getSwipeSpeedData
//
//  Created by 나은민 on 7/9/25.
//

import SwiftUI

struct ContentView: View {
    
    //3가지 상태 정의
    enum TrackingState { case idle, tracking, finished}
    
    @State private var trackingState: TrackingState = .idle
    @State private var timer: Timer? = nil
    @State private var remainingTime = 5
    
    var body: some View {
        ZStack {
            //변경된 상태를 바인딩
            SwipeTrackingViewRepresentable(state: $trackingState)
            
            VStack{
                //상태에 따라 다른 텍스트 표시
                switch trackingState {
                case .idle:
                    Text("버튼을 눌러 측정을 시작하세요")
                        .font(.title2)
                        .padding()
                case .tracking:
                    Text("\(remainingTime)초 동안 화면을 스와이프 해주세요!!!")
                        .font(.title2)
                        .padding()
                case .finished:
                    Text("측정이 완료되었습니다.")
                        .font(.title2)
                        .padding()
                }
                
                Spacer()
                
                //측정중일 때는 버튼 숨기기
                if trackingState != .tracking{
                    Button(action:{
                        //버튼을 누르면 무조건 측정을 새로 시작
                        startNewTracking()
                    }){
                        Text("측정 시작")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.bottom,30)
                    }
                }
            }
        }
    }
    
    private func startNewTracking(){
        //상태를 .tracking으로 변경
        trackingState = .tracking
        
        //타이머 시작
        remainingTime = 5
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ _ in
            if self.remainingTime > 1{
                self.remainingTime -= 1
            }
            else{
                //5초 종료 시 .finished로 상태 변경
                self.trackingState = .finished
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
}


    
//    #Preview {
//        ContentView()
//    }

