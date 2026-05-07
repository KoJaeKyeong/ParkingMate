//
//  HomeFeatureTests.swift
//  ParkingMateTests
//
//  Created by 고재경 on 5/7/26.
//

import Foundation
import Testing
import ComposableArchitecture

@testable import ParkingMate

@MainActor
struct HomeFeatureTests {
    @Test func test_정보수정_시트_열기() async {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        }

        await store.send(.editInfoButtonTapped) {
            $0.destination = .form(FormFeature.State())
        }
    }

    @Test func test_위치확인_지도시트_열기() async {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        }

        await store.send(.showMapButtonTapped) {
            $0.destination = .map(MapFeature.State())
        }
    }

    @Test func test_타이머틱_경과시간_갱신요청() async {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        }

        await store.send(.timerTick)
        await store.receive(\.updateElapsedTime)
    }

    @Test func test_주차정보_없으면_경과시간_갱신_안함() async {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        }

        // parkingInfo 가 nil 이면 elapsedTime 은 갱신되지 않는다.
        await store.send(.updateElapsedTime)
    }

    // startParking 은 ParkingInfo() 의 startTime 이 호출 시점의 Date() 라
    // exhaustive 비교가 어려우므로 핵심 효과만 검증한다.
    @Test func test_주차_시작() async {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.continuousClock = TestClock()
            $0.locationClient = .testValue
        }
        store.exhaustivity = .off

        await store.send(.startParkingButtonTapped)

        #expect(store.state.parkingInfo != nil)
        if case .form = store.state.destination {
            // form destination 으로 전환 OK
        } else {
            Issue.record("destination 이 .form 이어야 함")
        }

        await store.send(.finishParkingButtonTapped)
        #expect(store.state.parkingInfo == nil)
        #expect(store.state.elapsedTime == "")
    }

    @Test func test_위치_수신시_GPS_저장() async {
        let clock = TestClock()
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.locationClient = .testValue
        }
        store.exhaustivity = .off

        await store.send(.startParkingButtonTapped)
        await store.receive(\.locationReceived)

        #expect(store.state.parkingInfo?.gpsCoords?.latitude == 37.5665)
        #expect(store.state.parkingInfo?.gpsCoords?.longitude == 126.9780)

        await store.send(.finishParkingButtonTapped)
    }

}
