//
//  FormFeature.swift
//  ParkingMate
//
//  Created by 고재경 on 8/14/25.
//

import UIKit 
import Speech

import ComposableArchitecture
import Core
import Services

@Reducer
public struct FormFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.fileStorage(.parkingInfo)) var parkingInfo: ParkingInfo?

        var locationInput: String = ""
        var photoImages: [UIImage] = []
        var isRecording: Bool = false
        var speechAuthorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
        var showCamera: Bool = false
        var capturedImage: UIImage?
        var speechErrorMessage: String?

        public init() {
            // 기존 정보가 있으면 로드
            self.locationInput = parkingInfo?.location ?? ""
            self.photoImages = parkingInfo?.photos.compactMap { photoItem in
                UIImage(data: photoItem.imageData)
            } ?? []
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)  // binding action 추가

        case cancelButtonTapped
        case setLocation(String)
        case removeImage(at: Int)
        case saveButtonTapped
        case takePictureButtonTapped
        case cameraDismissed
        case voiceInputButtonTapped
        case speechAuthorizationResponse(SFSpeechRecognizerAuthorizationStatus)
        case speechRecognitionResult(String)
        case speechRecognitionCompleted
        case speechRecognitionFailed
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.speechRecognition) var speechRecognition
    
    public init() { }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.capturedImage):
                if let image = state.capturedImage {
                    state.photoImages.append(image)
                    state.capturedImage = nil
                }
                return .none
                
            case .binding:  // 다른 binding actions 처리
                return .none
                
            case .cancelButtonTapped:
                return .run { _ in
                    await dismiss()
                }
                
            case let .setLocation(location):
                state.locationInput = location
                return .none
                
            case let .removeImage(index):
                state.photoImages.remove(at: index)
                return .none
                
            case .saveButtonTapped:
                state.$parkingInfo.withLock { parkingInfo in
                    if parkingInfo == nil {
                        parkingInfo = ParkingInfo()
                    }
                    parkingInfo?.location = state.locationInput
                    parkingInfo?.photos = state.photoImages.map { image in
                        PhotoItem(id: UUID(), imageData: image.jpegData(compressionQuality: 0.8) ?? Data())
                    }
                }
                return .run { _ in
                    await dismiss()
                }
                
            case .takePictureButtonTapped:
                state.showCamera = true
                return .none
                
            case .cameraDismissed:
                state.showCamera = false
                return .none
                
            case .voiceInputButtonTapped:
                guard !state.isRecording else { return .none }
                state.speechErrorMessage = nil

                return .run { send in
                    let status = await speechRecognition.requestAuthorization()
                    await send(.speechAuthorizationResponse(status))
                    
                    if status == .authorized {
                        do {
                            let stream = try await speechRecognition.startRecognition()
                            for try await result in stream {
                                await send(.speechRecognitionResult(result))
                            }
                            await send(.speechRecognitionCompleted)
                        } catch {
                            print("Speech recognition failed: \(error)")
                            await send(.speechRecognitionFailed)
                        }
                    }
                }
                
            case let .speechAuthorizationResponse(status):
                state.speechAuthorizationStatus = status
                if status == .authorized {
                    state.isRecording = true
                }
                return .none
                
            case let .speechRecognitionResult(text):
                state.locationInput = text
                return .none
                
            case .speechRecognitionCompleted:
                state.isRecording = false
                return .none

            case .speechRecognitionFailed:
                state.isRecording = false
                state.speechErrorMessage = "음성 인식에 실패했습니다. 다시 시도해주세요."
                return .none
            }
        }
    }
}
