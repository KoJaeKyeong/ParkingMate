//
//  ParkingMateApp.swift
//  ParkingMate
//
//  Created by 고재경 on 7/26/25.
//

import SwiftUI

import AppFeature
import ComposableArchitecture

@main
struct ParkingMateApp: App {
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
            ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: Self.store)
        }
    }
}
