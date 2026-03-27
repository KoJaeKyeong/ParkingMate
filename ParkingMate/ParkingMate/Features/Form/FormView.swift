import SwiftUI

import ComposableArchitecture

struct FormView: View {
    @Bindable var store: StoreOf<FormFeature>
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.indigo.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        locationSection
                        photoSection
                        saveButton
                    }
                    .padding()
                }
            }
            .navigationTitle("주차 정보 입력")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("취소") {
                        store.send(.cancelButtonTapped)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $store.showCamera) {
            CameraView(capturedImage: $store.capturedImage)
                .ignoresSafeArea()
                .onDisappear {
                    store.send(.cameraDismissed)
                }
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(.blue)
                Text("위치 메모")
                    .font(.headline)
                Text("(선택사항)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                TextField("예: 지하 3층 B4, 2층 A구역 12번", text: $store.locationInput.sending(\.setLocation))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                
                HStack {
                    Button(
                        action: {
                            if !store.isRecording {
                                store.send(.voiceInputButtonTapped)
                            }
                        },
                        label: {
                            HStack(spacing: 8) {
                                if store.isRecording {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                                } else {
                                    Image(systemName: "mic.fill")
                                        .font(.caption)
                                }
                                Text(store.isRecording ? "듣는 중..." : "음성 입력")
                                    .font(.subheadline)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(store.isRecording ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                            .foregroundColor(store.isRecording ? .red : .blue)
                            .cornerRadius(8)
                        }
                    )
                    .disabled(store.isRecording)
                    
                    Spacer()
                    
                    if store.isRecording {
                        Text("말씀이 끝나면 자동으로 인식됩니다")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                if let errorMessage = store.speechErrorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
    
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "camera.fill")
                    .foregroundColor(.blue)
                Text("사진 촬영")
                    .font(.headline)
                Text("(선택사항)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                if !store.photoImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(store.photoImages.enumerated()), id: \.offset) { index, image in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    Button(
                                        action: {
                                            store.send(.removeImage(at: index))
                                        }, label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .background(Circle().fill(Color.red))
                                        }
                                    )
                                    .offset(x: 8, y: -8)
                                }
                            }
                        }
                    }
                }
                
                if store.photoImages.count < 3 {
                    Button(action: {
                        store.send(.takePictureButtonTapped)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("사진 촬영 (\(store.photoImages.count)/3)")
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                .foregroundColor(.blue.opacity(0.5))
                        )
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
                
                Text("주차 위치나 주변 특징을 촬영하면 나중에 찾기 쉬워집니다.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
    
    private var saveButton: some View {
        Button(action: {
            store.send(.saveButtonTapped)
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("저장하기")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

#Preview("Empty Form") {
    FormView(
        store: Store(initialState: FormFeature.State()) {
            FormFeature()
        }
    )
}

#Preview("Form with Data") {
    @Shared(.fileStorage(.parkingInfo)) var parkingInfo: ParkingInfo? = ParkingInfo(
        startTime: Date(),
        location: "지하 2층 B구역 25번",
        photos: [],
        gpsCoords: nil
    )
    
    return FormView(
        store: Store(initialState: FormFeature.State()) {
            FormFeature()
        }
    )
}
