//
//  SwipeTrackingView.swift
//  getSwipeSpeedData
//
//  Created by 나은민 on 7/9/25.
//

import UIKit

// 각 터치 이벤트의 데이터를 저장하는 구조체
struct SwipeDataPoint {
    let timestamp: TimeInterval
    let position: CGPoint
    let velocity: CGVector
    var speed: CGFloat {
        return sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
    }
}

// 실시간 속도 및 최종 데이터 업데이트를 위한 프로토콜 정의
protocol SwipeTrackingViewDelegate: AnyObject {
    func didUpdate(speed: CGFloat)
    func didFinish(with data: [SwipeDataPoint])
}

//UIView를 상속받아 터치 추적 및 속도 측정을 위한 사용자 정의 뷰
class SwipeTrackingView: UIView {

    // Delegate 프로퍼티
    weak var delegate: SwipeTrackingViewDelegate?

    //이전 터치 위치를 저장하는 변수 (다음 터치와 비교해 이동 거리 계산)
    private var previousTouchPoint: CGPoint?
    
    //이전 터치 시간 저장(속도 계산을 위한 시간 간격 측정)
    private var previousTimestamp: TimeInterval?
    
    //스와이프 데이터를 저장하는 배열
    var swipeData: [SwipeDataPoint] = []
    
    //측정 활성화 상태 변수
    private(set) var isTrackingEnabled = false

    //초기화 메서드 -> 배경을 흰색으로 설정한다.
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        isMultipleTouchEnabled = false // 단일 터치만 처리
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    // 터치가 시작될 때 호출
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isTrackingEnabled, let touch = touches.first else { return }
        
        // 새 스와이프의 시작점이므로 이전 데이터 초기화
        previousTouchPoint = touch.location(in: self)
        previousTimestamp = touch.timestamp
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
        var currentVelocity = CGVector.zero

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
                currentVelocity = CGVector(dx: vx, dy: vy)
            }
        }
        
        //현재 스와이프 데이터 포인트 생성 및 저장
        let dataPoint = SwipeDataPoint(timestamp: currentTime, position: currentPoint, velocity: currentVelocity)
        swipeData.append(dataPoint)
        
        // Delegate를 통해 실시간 속력 전달
        delegate?.didUpdate(speed: dataPoint.speed)

        //이번 터치를 다음 계산을 위한 기준점으로 저장
        previousTouchPoint = currentPoint
        previousTimestamp = currentTime
    }
    
    // 터치가 끝났을 때 호출
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 스와이프가 끝나도 측정 시간 동안은 이전 데이터를 유지
    }
    
    // 터치가 취소됐을 때 (e.g. 시스템 인터럽트)
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 측정 시간 동안은 이전 데이터를 유지
    }


    //측정 시작 함수
    func startTracking(){
        swipeData.removeAll()
        previousTouchPoint = nil
        previousTimestamp = nil
        
        //측정 활성화
        isTrackingEnabled = true
        print("---- 5초간 속도 측정 시작 ----")
    }
    
    //외부 호출 함수 -> 측정을 종료
    func endTracking() {
        //측정 비활성화
        isTrackingEnabled = false
        // 측정 종료 시 속도를 0으로 리셋하여 전달
        delegate?.didUpdate(speed: 0)
        // 수집된 전체 데이터를 델리게이트로 전달
        delegate?.didFinish(with: swipeData)
        print("---- 5초간 측정 종료 ----")
        print("\(swipeData.count)개의 데이터 포인트가 수집되었습니다.")
    }
    
    //터치가 실제로 발생하지 않았거나
            //터치가 너무 짧거나, 너무 빠르면 endTracking() 함수가 정상작동하지 않을 수 있다.

            //속도를 측정할 때 음수가 나오는 경우는 속도는 방향을 가지는 물리량이기 때문이다.
            //x축 속도가 음수인 경우 -> 왼쪽으로 움직이는 것 (currentPoint.x < previousPoint.x) 즉 vx가 음수가 된다.
            //y축 속도가 음수인 경우 -> 위쪽으로 움직이는 것 (currentPoint.y < previousPoint.y) 즉 vy가 음수가 된다.
            //UIKit 좌표계에서 y축은 아래로 갈수록 값이 커진다.
            //평균속도 또한 마찬가지라고 한다.
    
    //7월31일 -> 화면에 나오는 값은 속력이다. 속도를 나타내려면 2가지 값을 출력해야한다. (dx, dy -> x,y의 방향이 추가된 속력값)
    //csv파일에는 정확하게 속도값, 속력이 저정되고 있다. (속도 -> dx,dy 속력 -> speed)
}

extension SwipeTrackingView {
    func generateCSV() -> String {
        var csvString = "timestamp,x,y,dx,dy,speed\n"
        for dataPoint in swipeData {
            let line = "\(dataPoint.timestamp),\(dataPoint.position.x),\(dataPoint.position.y),\(dataPoint.velocity.dx),\(dataPoint.velocity.dy),\(dataPoint.speed)\n"
            csvString.append(line)
        }
        return csvString
    }
}

