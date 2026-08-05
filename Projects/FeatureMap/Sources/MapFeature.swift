//
//  MapFeature.swift
//  ParkingMate
//
//  Created by 고재경 on 8/16/25.
//

import Foundation
import MapKit

import ComposableArchitecture
import Core
import Services

@Reducer
public struct MapFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.fileStorage(.parkingInfo)) var parkingInfo: ParkingInfo?

        var parkingCoordinate: CLLocationCoordinate2D? {
            guard let coords = parkingInfo?.gpsCoords else { return nil }
            return CLLocationCoordinate2D(
                latitude: coords.latitude,
                longitude: coords.longitude
            )
        }
        
        public init() { }
    }

    public enum Action {
        case closeButtonTapped
        case directionsButtonTapped
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.mapsClient) var mapsClient
    
    public init() { }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .closeButtonTapped:
                return .run { _ in
                    await dismiss()
                }

            case .directionsButtonTapped:
                guard let coordinate = state.parkingInfo?.gpsCoords else { return .none }
                return .run { _ in
                    await mapsClient.openDirections(coordinate)
                }
            }
        }
    }
}
