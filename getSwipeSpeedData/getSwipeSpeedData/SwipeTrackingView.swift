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
    private var velocities: [CGVector] = []
    
    //측정 활성화 상태 변수
    private var isTrackingEnabled = false

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
        
        //측정 활성화 상태가 아니면 아무것도 하지 않게함
        guard isTrackingEnabled else { return }
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
            
            //시간 간격 계산
            let dt = currentTime - prevTime
            
            //시간 차가 0보다 크다면 속도를 계산한다.
            if dt > 0 {
                let vx = dx / CGFloat(dt)
                let vy = dy / CGFloat(dt)
                let velocity = CGVector(dx: vx, dy: vy)
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
        
        //측정 활성화
        isTrackingEnabled = true
        print("---- 5초간 속도 측정 시작 ----")
    }
    //외부 호출 함수 -> 측정을 종료하고 결과 출력
    func endTracking() {
        //velocities -> 속도 벡터 배열(각 순간의 속도 벡터(x,y))
        //pt/s -> 픽셀 단위로 측정된 속도 (1초에 몇 포인트만큼 이동했는지 나타내는 단위)
        
        
        //측정 비활성화
        isTrackingEnabled = false
        print("---- 5초간 측정 종료 ----")
        
        //궤적 좌표 전체 출력
        print("Path Points (\(pathPoints.count)):", pathPoints)
        
        //측정된 속도 전체 출력
        print("순간 마다 속도 (\(velocities.count)):", velocities)
        
        //평균 속도 출력
        if !velocities.isEmpty {
            let totalVelocity = velocities.reduce(CGVector.zero) { CGVector(dx: $0.dx + $1.dx, dy: $0.dy + $1.dy) }
            let averageVelocity = CGVector(dx: totalVelocity.dx / CGFloat(velocities.count), dy: totalVelocity.dy / CGFloat(velocities.count))
            print("평균 속도 :\(averageVelocity) pt/s")
        }

        //속도의 크기인 속력 출력
        if !velocities.isEmpty {
            let totalSpeed = velocities.reduce(0) { $0 + sqrt($1.dx * $1.dx + $1.dy * $1.dy) }
            let averageSpeed = totalSpeed / CGFloat(velocities.count)
            print("평균 속력 : \(averageSpeed) pt/s")
        }

        //터치가 실제로 발생하지 않았거나
        //터치가 너무 짧거나, 너무 빠르면 endTracking() 함수가 정상작동하지 않을 수 있다.

        //속도를 측정할 때 음수가 나오는 경우는 속도는 방향을 가지는 물리량이기 때문이다.
        //x축 속도가 음수인 경우 -> 왼쪽으로 움직이는 것 (currentPoint.x < previousPoint.x) 즉 vx가 음수가 된다.
        //y축 속도가 음수인 경우 -> 위쪽으로 움직이는 것 (currentPoint.y < previousPoint.y) 즉 vy가 음수가 된다.
        //UIKit 좌표계에서 y축은 아래로 갈수록 값이 커진다.
        //평균속도 또한 마찬가지라고 한다.
    }
}

