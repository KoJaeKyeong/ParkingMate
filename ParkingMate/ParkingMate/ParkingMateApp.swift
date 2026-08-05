//
//  ParkingMateApp.swift
//  ParkingMate
//
//  Created by 고재경 on 7/26/25.
//

import SwiftUI

import ComposableArchitecture

@main
struct ParkingMateApp: App {
    static let store = Store(initialState: HomeFeature.State()) {
        HomeFeature()
            ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView(store: Self.store)
        }
    }
}
