//
//  HomeFeature.swift
//  ParkingMate
//
//  Created by 고재경 on 8/12/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct HomeFeature {
    enum ParkingState {
        case idle
        case parking
    }
    
    @ObservableState
    struct State: Equatable {
        var parkingState: ParkingState = .idle
        var parkingInfo = ParkingInfo()
        var showInputSheet = false
        var showMapView = false
        var elapsedTime = ""
    }
    
    enum Action {
        case startParkingButtonTapped
        case finishParkingButtonTapped
        case editInfoButtonTapped
        case showMapButtonTapped
        case timerTick
        case updateElapsedTime
    }
    
    @Dependency(\.continuousClock) var clock
    
    private enum CancelID {
        case timer
    }
    
    var body: some ReducerOf<Self> {        
        Reduce { state, action in
            switch action {
            case .startParkingButtonTapped:
                state.parkingState = .parking
                state.parkingInfo.startTime = Date()
                state.parkingInfo.gpsCoords = GPSCoordinate(latitude: 37.5665, longitude: 126.9780)
                state.showInputSheet = true
                
                return .run { send in
                    for await _ in self.clock.timer(interval: .seconds(1)) {
                        await send(.timerTick)
                    }
                }
                .cancellable(id: CancelID.timer)
                
            case .finishParkingButtonTapped:
                state.parkingState = .idle
                state.parkingInfo = ParkingInfo()
                state.elapsedTime = ""
                
                return .cancel(id: CancelID.timer)
                
            case .editInfoButtonTapped:
                state.showInputSheet = true
                return .none
                
            case .showMapButtonTapped:
                state.showMapView = true
                return .none
                
            case .timerTick:
                return .send(.updateElapsedTime)
                
            case .updateElapsedTime:
                guard let startTime = state.parkingInfo.startTime else { return .none }
                let elapsed = Date().timeIntervalSince(startTime)
                let hours = Int(elapsed) / 3600
                let minutes = (Int(elapsed) % 3600) / 60
                state.elapsedTime = "\(hours)시간 \(minutes)분"
                return .none
            }
        }
    }
}
