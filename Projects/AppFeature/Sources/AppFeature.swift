//
//  AppFeature.swift
//  ParkingMate
//
//  Created by 고재경 on 7/25/26.
//

import Foundation

import FeatureHome
import FeatureForm
import FeatureMap
import ComposableArchitecture

@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
        var home = HomeFeature.State()
        @Presents var destination: Destination.State?
        
        public init() { }
    }
    
    public enum Action {
        case home(HomeFeature.Action)
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Reducer
    public enum Destination {
        case form(FormFeature)
        case map(MapFeature)
    }
    
    public init() { }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .home(.delegate(.parkingStarted)), .home(.delegate(.editInfoRequested)):
                state.destination = .form(FormFeature.State())
                return .none
            case .home(.delegate(.mapRequested)):
                state.destination = .map(MapFeature.State())
                return .none
            case .home, .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination.body
        }
    }
}

extension AppFeature.Destination.State: Equatable { }
