//
//  SwipeTrackingView.swift
//  getSwipeSpeedData
//
//  Created by 나은민 on 7/9/25.
//

import UIKit

//UIView를 상속받아 터치 추적 및 속도 측정을 위한 사용자 정의 뷰
class SwipeTrackingView: UIView {

    //이전 터치 위치를 저장하는 변수 (다음 터치와 비교해 이동 거리 계산)
    private var previousTouchPoint: CGPoint?
    
    //이전 터치 시간 저장(속도 계산을 위한 시간 간격 측정)
    private var previousTimestamp: TimeInterval?
    
    //사용자의 스와이프 궤적을 저장하는 배열
    private var pathPoints: [CGPoint] = []
    
    //스와이프 속도를 저장하는 배열 (단위 : pt/sec)
    private var velocities: [CGFloat] = []

    //초기화 메서드 -> 배경을 흰색으로 설정한다.
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //사용자가 화면을 터치하고 손가락을 움직일 때마다 호출
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //첫 번째 터치 이벤트
        guard let touch = touches.first else { return }

        //현재 위치와 시간 데이터 저장
        let currentPoint = touch.location(in: self)
        let currentTime = touch.timestamp

        //현재 터치 위치 저장
        pathPoints.append(currentPoint)

        //이전 위치와 시간이 있다면 속도를 계산한다.
        if let prevPoint = previousTouchPoint,
           let prevTime = previousTimestamp {
            
            //두 좌표간 거리 계산 -> 피타고라스 사용
            let dx = currentPoint.x - prevPoint.x
            let dy = currentPoint.y - prevPoint.y
            let distance = sqrt(dx * dx + dy * dy)
            
            //시간 간격 계산
            let dt = currentTime - prevTime
            
            //시간 차가 0보다 크다면 속도를 계산한다.
            if dt > 0 {
                let velocity = distance / CGFloat(dt)
                velocities.append(velocity)
                
                //속도 및 현재 위치 콘솔 출력용
                print("Velocity: \(velocity) pts/sec at point: \(currentPoint)")
            }
        }

        //이번 터치를 다음 계산을 위한 기준점으로 저장
        previousTouchPoint = currentPoint
        previousTimestamp = currentTime
    }

    //측정 시작 함수
    func startTracking(){
        pathPoints.removeAll()
        velocities.removeAll()
        previousTouchPoint = nil
        previousTimestamp = nil
        print("---- 5초간 속도 측정 시작 ----")
    }
    //외부 호출 함수 -> 측정을 종료하고 결과 출력
    func endTracking() {
        print("---- 5초간 측정 종료 ----")
        
        //궤적 좌표 전체 출력
        print("Path Points (\(pathPoints.count)):", pathPoints)
        
        //측정된 속도 전체 출력
        print("순간 마다 속도 (\(velocities.count)):", velocities)
        
        //평균 속도 출력
        if !velocities.isEmpty {
            let average = velocities.reduce(0, +) / CGFloat(velocities.count)
            print("평균 속도 :\(average) pt/s")
        }
    }
}

