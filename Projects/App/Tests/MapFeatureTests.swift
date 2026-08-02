//
//  MapFeatureTests.swift
//  ParkingMateTests
//
//  Created by 고재경 on 5/7/26.
//

import Foundation
import Testing

import ComposableArchitecture

@testable import FeatureMap

@MainActor
struct MapFeatureTests {
    @Test func test_닫기버튼_시트_종료() async {
        let store = TestStore(initialState: MapFeature.State()) {
            MapFeature()
        }

        await store.send(.closeButtonTapped)
        await store.finish()
    }
}
