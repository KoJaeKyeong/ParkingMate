//
//  AppView.swift
//  ParkingMate
//
//  Created by 고재경 on 7/25/26.
//

import SwiftUI

import FeatureForm
import FeatureHome
import FeatureMap
import ComposableArchitecture

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        HomeView(store: store.scope(state: \.home, action: \.home))
            .sheet(
                item: $store.scope(state: \.destination?.form, action: \.destination.form)
            ) { store in
                FormView(store: store)
            }
            .sheet(
                item: $store.scope(state: \.destination?.map, action: \.destination.map)
            ) { store in
                MapView(store: store)
            }
    }
}
