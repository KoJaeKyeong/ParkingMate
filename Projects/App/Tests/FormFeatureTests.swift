//
//  FormFeatureTests.swift
//  ParkingMateTests
//
//  Created by 고재경 on 5/7/26.
//

import Foundation
import Testing
import UIKit
import Speech
import ComposableArchitecture
import Services

@testable import ParkingMate

@MainActor
struct FormFeatureTests {
    @Test func test_위치_입력_갱신() async {
        let store = TestStore(initialState: FormFeature.State()) {
            FormFeature()
        }

        await store.send(.setLocation("지하 1층 A12")) {
            $0.locationInput = "지하 1층 A12"
        }
    }

    @Test func test_카메라_열기() async {
        let store = TestStore(initialState: FormFeature.State()) {
            FormFeature()
        }

        await store.send(.takePictureButtonTapped) {
            $0.showCamera = true
        }
    }

    @Test func test_카메라_닫기() async {
        var initial = FormFeature.State()
        initial.showCamera = true

        let store = TestStore(initialState: initial) {
            FormFeature()
        }

        await store.send(.cameraDismissed) {
            $0.showCamera = false
        }
    }

    @Test func test_사진_삭제() async {
        let imageA = UIImage()
        let imageB = UIImage()

        var initial = FormFeature.State()
        initial.photoImages = [imageA, imageB]

        let store = TestStore(initialState: initial) {
            FormFeature()
        }
        store.exhaustivity = .off

        await store.send(.removeImage(at: 0))

        #expect(store.state.photoImages.count == 1)
        #expect(store.state.photoImages.first === imageB)
    }

    @Test func test_촬영사진_추가() async {
        let captured = UIImage()
        let store = TestStore(initialState: FormFeature.State()) {
            FormFeature()
        }
        store.exhaustivity = .off

        await store.send(.binding(.set(\.capturedImage, captured)))

        #expect(store.state.photoImages.count == 1)
        #expect(store.state.photoImages.first === captured)
        #expect(store.state.capturedImage == nil)
    }

    @Test func test_음성입력_권한허용_위치_갱신() async {
        let store = TestStore(initialState: FormFeature.State()) {
            FormFeature()
        } withDependencies: {
            $0.speechRecognition = .testValue
        }

        await store.send(.voiceInputButtonTapped)

        await store.receive(\.speechAuthorizationResponse) {
            $0.speechAuthorizationStatus = .authorized
            $0.isRecording = true
        }

        await store.receive(\.speechRecognitionResult) {
            $0.locationInput = "테스트 음성 입력"
        }

        await store.receive(\.speechRecognitionCompleted) {
            $0.isRecording = false
        }
    }

    @Test func test_음성인식_실패_에러메시지() async {
        var initial = FormFeature.State()
        initial.isRecording = true

        let store = TestStore(initialState: initial) {
            FormFeature()
        }

        await store.send(.speechRecognitionFailed) {
            $0.isRecording = false
            $0.speechErrorMessage = "음성 인식에 실패했습니다. 다시 시도해주세요."
        }
    }

    @Test func test_녹음중_음성입력_무시() async {
        var initial = FormFeature.State()
        initial.isRecording = true

        let store = TestStore(initialState: initial) {
            FormFeature()
        } withDependencies: {
            $0.speechRecognition = .testValue
        }

        // 이미 녹음 중이면 권한 요청을 다시 보내지 않고 종료한다.
        await store.send(.voiceInputButtonTapped)
    }

}
