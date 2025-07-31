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
    
    // SwipeTrackingView의 인스턴스를 상태로 관리
    @State private var swipeView = SwipeTrackingView()
    
    @State private var trackingState: TrackingState = .idle
    @State private var timer: Timer? = nil
    @State private var remainingTime = 5
    @State private var showShareSheet = false
    @State private var csvFileURL: URL?
    
    // 실시간 속도를 저장할 상태 변수
    @State private var currentSpeed: CGFloat = 0

    var body: some View {
        ZStack {
            // SwipeTrackingView 인스턴스와 상태, 실시간 속도를 바인딩하여 전달
            SwipeTrackingViewRepresentable(view: swipeView, state: $trackingState, currentSpeed: $currentSpeed)
            
            VStack{
                //상태에 따라 다른 텍스트 표시
                switch trackingState {
                case .idle:
                    Text("버튼을 눌러 측정을 시작하세요")
                        .font(.title2)
                        .padding()
                case .tracking:
                    VStack {
                        Text("\(remainingTime)초 동안 화면을 스와이프 해주세요!!!")
                            .font(.title2)
                            .padding(.bottom, 20)
                        
                        // 실시간 속도 표시
                        Text("현재 속도: \(Int(currentSpeed)) pt/s")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding()

                case .finished:
                    Text("측정이 완료되었습니다.")
                        .font(.title2)
                        .padding()
                }
                
                Spacer()
                
                // 현재 상태에 따라 적절한 버튼들을 표시
                if trackingState == .idle {
                    Button(action: startNewTracking) {
                        Text("측정 시작")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 30)
                } else if trackingState == .finished {
                    HStack(spacing: 20) {
                        Button(action: resetTracking) {
                            Text("다시 측정")
                                .font(.title2)
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: saveAndShare) {
                            Text("저장 및 내보내기")
                                .font(.title2)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = self.csvFileURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    private func startNewTracking(){
        // 상태를 .tracking으로 변경하여 측정을 시작
        trackingState = .tracking
        
        //타이머 시작
        remainingTime = 5
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ _ in
            if self.remainingTime > 1{
                self.remainingTime -= 1
            }
            else{
                //5초 종료 시 .finished로 상태 변경
                self.timer?.invalidate()
                self.timer = nil
                self.trackingState = .finished
            }
        }
    }
    
    private func resetTracking() {
        // 모든 상태를 초기화하여 "다시 측정" 준비
        trackingState = .idle
        currentSpeed = 0
    }
    
    private func saveAndShare() {
        let csvData = swipeView.generateCSV()
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let fileName = "swipe_data_\(formatter.string(from: Date())).csv"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try csvData.write(to: fileURL, atomically: true, encoding: .utf8)
            print("CSV 파일 저장 성공: \(fileURL.path)")
            self.csvFileURL = fileURL
            self.showShareSheet = true
        } catch {
            print("CSV 파일 저장 실패: \(error.localizedDescription)")
        }
    }
}

// UIActivityViewController를 SwiftUI에서 사용하기 위한 래퍼
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

