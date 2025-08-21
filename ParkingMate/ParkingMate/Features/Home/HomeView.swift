import SwiftUI

import ComposableArchitecture

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>

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
                    VStack(spacing: 24) {
                        headerSection
                        
                        if store.parkingState == .idle {
                            idleStateView
                        } else {
                            parkingStateView
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.form,
                action: \.destination.form
            )
        ) { form in
            FormView(store: form)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 64, height: 64)
                
                Image(systemName: "car.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
            .padding(.top, 40)
            
            Text("ParkingMate")
                .font(.title.bold())
                .foregroundColor(.primary)
            
            Text("주차 위치를 쉽게 기억하세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var idleStateView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                    
                    Text("주차를 시작하세요")
                        .font(.title3.bold())
                    
                    Text("버튼을 눌러 현재 위치를 저장합니다")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 8)
                
                Button(
                    action: {
                        store.send(.startParkingButtonTapped)
                    },
                    label: {
                        HStack {
                            Image(systemName: "car.fill")
                            Text("주차 시작")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                )
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            
            featuresSection
        }
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("주요 기능")
                .font(.headline)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                FeatureRow(
                    icon: "location.fill",
                    title: "GPS 위치 자동 저장",
                    subtitle: "정확한 주차 위치를 기록합니다"
                )
                
                FeatureRow(
                    icon: "camera.fill",
                    title: "사진 및 메모 추가",
                    subtitle: "주변 환경을 기록해 더 쉽게 찾으세요"
                )
                
                FeatureRow(
                    icon: "location.north.fill",
                    title: "네비게이션 연동",
                    subtitle: "외부 지도앱으로 쉽게 길찾기"
                )
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
    
    private var parkingStateView: some View {
        VStack(spacing: 20) {
            parkingInfoCard
            actionButtons
        }
    }
    
    private var parkingInfoCard: some View {
        VStack(spacing: 20) {
            parkingStatusHeader
            parkingInfoDetails
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
    
    private var parkingStatusHeader: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                    .overlay(animatedPulse)
                
                Text("주차 중")
                    .font(.subheadline.bold())
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            if let startTime = store.parkingInfo?.startTime {
                Text(formatTime(startTime))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var animatedPulse: some View {
        Circle()
            .fill(Color.green.opacity(0.5))
            .frame(width: 12, height: 12)
            .scaleEffect(1.5)
            .opacity(0.5)
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: store.parkingState)
    }
    
    private var parkingInfoDetails: some View {
        VStack(spacing: 16) {
            elapsedTimeRow
            
            if let parkingInfo = store.parkingInfo {
                if !parkingInfo.location.isEmpty {
                    locationInfoRow
                }
                
                if !parkingInfo.photos.isEmpty {
                    photosRow(parkingInfo: parkingInfo)
                }
                
                if parkingInfo.location.isEmpty && parkingInfo.photos.isEmpty {
                    emptyInfoPrompt
                }
            }
        }
    }
    
    private var elapsedTimeRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("경과 시간")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(store.elapsedTime)
                    .font(.headline)
            }
            
            Spacer()
        }
    }
    
    private var locationInfoRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("위치 정보")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(store.parkingInfo?.location ?? "")
                    .font(.headline)
            }
            
            Spacer()
        }
    }
    
    private func photosRow(parkingInfo: ParkingInfo) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "camera.fill")
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("저장된 사진")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(parkingInfo.photos) { photo in
                            if let uiImage = UIImage(data: photo.imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 64, height: 64)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
    }
    
    private var emptyInfoPrompt: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text("추가 정보를 입력해보세요")
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
            }
            
            Text("위치 메모나 사진을 추가하면 나중에 더 쉽게 찾을 수 있어요!")
                .font(.caption)
                .foregroundColor(.blue.opacity(0.8))
            
            Button(action: { store.send(.editInfoButtonTapped) }) {
                Text("정보 추가하기")
                    .font(.caption.bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: { store.send(.editInfoButtonTapped) }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("정보 수정")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.gray.opacity(0.15))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }
            
            Button(action: { store.send(.showMapButtonTapped) }) {
                HStack {
                    Image(systemName: "location.north.fill")
                    Text("위치 확인")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            Button(action: { store.send(.finishParkingButtonTapped) }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("출차 완료")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(12)
    }
}

#Preview {
    HomeView(
        store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
        }
    )
}
