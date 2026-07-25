import AVFoundation
import Speech
import ComposableArchitecture

actor SpeechRecognitionManager {
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var inputNode: AVAudioInputNode?
    private var silenceTimer: Task<Void, Never>?
    private let silenceTimeout: TimeInterval = 1.0 // 1초간 침묵 시 자동 종료
    
    func startRecognition() async throws -> AsyncThrowingStream<String, Error> {
        // 오디오 세션 설정
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // 기기 언어에 맞춰 인식 (미지원 로케일이면 nil → recognizerNotAvailable 처리)
        let recognizer = SFSpeechRecognizer(locale: .current)
        
        guard let recognizer = recognizer else {
            throw SpeechRecognitionError.recognizerNotAvailable
        }
        
        guard recognizer.isAvailable else {
            throw SpeechRecognitionError.recognizerNotAvailable
        }
        
        // 이전 세션 정리
        await stopRecognition()
        
        let audioEngine = AVAudioEngine()
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = false
        
        self.audioEngine = audioEngine
        self.recognitionRequest = request
        
        let inputNode = audioEngine.inputNode
        self.inputNode = inputNode
        
        return AsyncThrowingStream { continuation in
            var hasDetectedSpeech = false
            
            // 인식 태스크 생성
            let recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Speech recognition error: \(error)")
                    continuation.finish(throwing: error)
                    return
                }
                
                if let result = result {
                    let transcription = result.bestTranscription.formattedString
                    
                    // 텍스트가 있으면 음성이 감지된 것으로 판단
                    if !transcription.isEmpty {
                        hasDetectedSpeech = true
                        continuation.yield(transcription)
                        
                        // 기존 타이머 취소하고 새로운 타이머 시작
                        Task {
                            await self.resetSilenceTimer {
                                if hasDetectedSpeech {
                                    print("Silence detected, stopping recognition...")
                                    continuation.finish()
                                    Task {
                                        await self.stopRecognition()
                                    }
                                }
                            }
                        }
                    }
                    
                    if result.isFinal {
                        continuation.finish()
                    }
                }
            }
            
            self.recognitionTask = recognitionTask
            
            // 오디오 포맷 확인
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            // 입력 노드에 탭 설치
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                request.append(buffer)
            }
            
            // 오디오 엔진 준비 및 시작
            audioEngine.prepare()
            
            do {
                try audioEngine.start()
                print("Audio engine started successfully")
                
                // 초기 타이머 시작 (5초 이내에 음성이 없으면 종료)
                Task {
                    await self.resetSilenceTimer(timeout: 5.0) {
                        if !hasDetectedSpeech {
                            print("No speech detected, stopping recognition...")
                            continuation.finish()
                            Task {
                                await self.stopRecognition()
                            }
                        }
                    }
                }
            } catch {
                print("Failed to start audio engine: \(error)")
                continuation.finish(throwing: error)
                return
            }
            
            // 스트림 종료 시 정리
            continuation.onTermination = { @Sendable _ in
                Task {
                    await self.stopRecognition()
                }
            }
        }
    }
    
    private func resetSilenceTimer(timeout: TimeInterval? = nil, onSilence: @escaping () -> Void) async {
        // 기존 타이머 취소
        silenceTimer?.cancel()
        
        // 새 타이머 시작
        let timeoutDuration = timeout ?? silenceTimeout
        silenceTimer = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(timeoutDuration * 1_000_000_000))
                if !Task.isCancelled {
                    onSilence()
                }
            } catch {
                // 취소됨
            }
        }
    }
    
    func stopRecognition() async {
        print("Stopping speech recognition...")
        
        // 타이머 취소
        silenceTimer?.cancel()
        silenceTimer = nil
        
        // 오디오 엔진 정지
        if let audioEngine = audioEngine {
            audioEngine.stop()
            
            // 입력 노드에서 탭 제거
            if let inputNode = inputNode {
                inputNode.removeTap(onBus: 0)
            }
        }
        
        // 인식 요청 종료
        recognitionRequest?.endAudio()
        
        // 인식 태스크 취소
        recognitionTask?.cancel()
        
        // 오디오 세션 비활성화
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
        
        // 참조 정리
        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
        inputNode = nil
        
        print("Speech recognition stopped")
    }
}

struct SpeechRecognitionClient {
    var requestAuthorization: @Sendable () async -> SFSpeechRecognizerAuthorizationStatus
    var startRecognition: @Sendable () async throws -> AsyncThrowingStream<String, Error>
    var stopRecognition: @Sendable () async -> Void
}

extension SpeechRecognitionClient: DependencyKey {
    private static let manager = SpeechRecognitionManager()
    
    static let liveValue = Self(
        requestAuthorization: {
            await withCheckedContinuation { continuation in
                Task { @MainActor in
                    SFSpeechRecognizer.requestAuthorization { status in
                        continuation.resume(returning: status)
                    }
                }
            }
        },
        startRecognition: {
            try await manager.startRecognition()
        },
        stopRecognition: {
            await manager.stopRecognition()
        }
    )
    
    static let testValue = Self(
        requestAuthorization: { .authorized },
        startRecognition: { 
            AsyncThrowingStream { continuation in
                continuation.yield("테스트 음성 입력")
                continuation.finish()
            }
        },
        stopRecognition: { }
    )
}

enum SpeechRecognitionError: LocalizedError {
    case recognizerNotAvailable
    case notAuthorized
    case audioSessionError
    
    var errorDescription: String? {
        switch self {
        case .recognizerNotAvailable:
            return String(localized: "음성 인식을 사용할 수 없습니다.")
        case .notAuthorized:
            return String(localized: "음성 인식 권한이 없습니다.")
        case .audioSessionError:
            return String(localized: "오디오 세션 설정에 실패했습니다.")
        }
    }
}

extension DependencyValues {
    var speechRecognition: SpeechRecognitionClient {
        get { self[SpeechRecognitionClient.self] }
        set { self[SpeechRecognitionClient.self] = newValue }
    }
}
