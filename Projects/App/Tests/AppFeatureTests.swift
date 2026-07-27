//
//  AppFeatureTests.swift
//  ParkingMateTests
//
//  Created by 고재경 on 7/25/26.
//

import Foundation
import Testing
import ComposableArchitecture

@testable import ParkingMate

@MainActor
struct AppFeatureTests {
    @Test func test_정보수정_요청시_폼시트_표시() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(.home(.editInfoButtonTapped))
        await store.receive(\.home.delegate.editInfoRequested) {
            $0.destination = .form(FormFeature.State())
        }
    }

    @Test func test_지도_요청시_지도시트_표시() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(.home(.showMapButtonTapped))
        await store.receive(\.home.delegate.mapRequested) {
            $0.destination = .map(MapFeature.State())
        }
    }

    // 주차 시작은 타이머·위치 효과가 함께 돌아 홈에서 별도 검증하므로,
    // 여기서는 delegate 를 받았을 때의 시트 전환만 본다.
    @Test func test_주차시작_요청시_폼시트_표시() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }

        await store.send(.home(.delegate(.parkingStarted))) {
            $0.destination = .form(FormFeature.State())
        }
    }

    @Test func test_시트_닫히면_destination_해제() async {
        var initial = AppFeature.State()
        initial.destination = .map(MapFeature.State())

        let store = TestStore(initialState: initial) {
            AppFeature()
        }

        await store.send(.destination(.dismiss)) {
            $0.destination = nil
        }
    }
}
