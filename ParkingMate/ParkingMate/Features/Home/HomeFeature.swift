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
        @Presents var destination: Destination.State?
        @Shared(.fileStorage(.parkingInfo)) var parkingInfo: ParkingInfo?
        
        var parkingState: ParkingState {
            get {
                parkingInfo != nil ? .parking : .idle
            }
        }
        var elapsedTime = ""
    }
    
    enum Action {
        case onAppear
        case startParkingButtonTapped
        case finishParkingButtonTapped
        case editInfoButtonTapped
        case showMapButtonTapped
        case timerTick
        case updateElapsedTime
        case locationReceived(GPSCoordinate)
        case locationFailed

        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.locationClient) var locationClient
    
    private enum CancelID {
        case timer
    }
    
    var body: some ReducerOf<Self> {        
        Reduce { state, action in
            switch action {
            case .onAppear:
                let isParking = state.parkingInfo != nil
                return .merge(
                    .run { _ in
                        await self.locationClient.requestAuthorization()
                    },
                    isParking
                        ? .run { send in
                            for await _ in self.clock.timer(interval: .seconds(1)) {
                                await send(.timerTick)
                            }
                        }
                        .cancellable(id: CancelID.timer)
                        : .none
                )
                
            case .startParkingButtonTapped:
                state.$parkingInfo.withLock { parkingInfo in
                    parkingInfo = ParkingInfo()
                }
                state.destination = .form(
                    FormFeature.State()
                )

                return .merge(
                    .run { send in
                        for await _ in self.clock.timer(interval: .seconds(1)) {
                            await send(.timerTick)
                        }
                    }
                    .cancellable(id: CancelID.timer),
                    .run { send in
                        do {
                            let coordinate = try await self.locationClient.requestLocation()
                            await send(.locationReceived(coordinate))
                        } catch {
                            await send(.locationFailed)
                        }
                    }
                )
                
            case .finishParkingButtonTapped:
                state.elapsedTime = ""
                state.$parkingInfo.withLock { parkingInfo in
                    parkingInfo = nil
                }
                
                return .cancel(id: CancelID.timer)
                
            case .editInfoButtonTapped:
                state.destination = .form(
                    FormFeature.State()
                )
                return .none
                
            case .showMapButtonTapped:
                state.destination = .map(
                    MapFeature.State()
                )
                return .none
                
            case .timerTick:
                return .send(.updateElapsedTime)
                
            case .updateElapsedTime:
                guard let startTime = state.parkingInfo?.startTime else { return .none }
                let elapsed = Date().timeIntervalSince(startTime)
                let hours = Int(elapsed) / 3600
                let minutes = (Int(elapsed) % 3600) / 60
                state.elapsedTime = "\(hours)시간 \(minutes)분"
                return .none
                
            case let .locationReceived(coordinate):
                state.$parkingInfo.withLock { parkingInfo in
                    parkingInfo?.gpsCoords = coordinate
                }
                return .none

            case .locationFailed:
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination.body
        }
    }
}

extension HomeFeature {
    @Reducer
    enum Destination {
        case form(FormFeature)
        case map(MapFeature)
    }
}

extension HomeFeature.Destination.State: Equatable { }
