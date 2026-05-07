import SwiftUI
import MapKit

import ComposableArchitecture

struct MapView: View {
    @Bindable var store: StoreOf<MapFeature>

    @Namespace private var mapScope
    @State private var position: MapCameraPosition = .automatic
    @State private var isFollowingHeading = false
    private let headingManager = CLLocationManager()

    var body: some View {
        ZStack {
            // 전체 화면 지도
            mapSection
                .ignoresSafeArea()

            // 오버레이 버튼들
            VStack {
                // 닫기 버튼 (우측 상단)
                HStack {
                    Spacer()

                    Button(action: { store.send(.closeButtonTapped) }) {
                        ZStack {
                            Circle()
                                .fill(Color.cardBackground)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle().stroke(Color.divider, lineWidth: 0.5)
                                )
                                .shadow(color: .black.opacity(0.2), radius: 8, y: 2)

                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.textPrimary)
                        }
                    }
                    .padding(.top, 60)
                    .padding(.trailing, 20)
                }

                Spacer()

                // 지도 컨트롤 (우측 하단)
                HStack {
                    Spacer()

                    VStack(spacing: 12) {
                        MapUserLocationButton(scope: mapScope)

                        Button {
                            isFollowingHeading.toggle()
                            if isFollowingHeading {
                                position = .userLocation(followsHeading: true, fallback: .automatic)
                            } else {
                                if let coord = store.parkingCoordinate {
                                    position = .region(MKCoordinateRegion(
                                        center: coord,
                                        span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                                    ))
                                } else {
                                    position = .automatic
                                }
                            }
                        } label: {
                            Image(systemName: isFollowingHeading ? "location.north.fill" : "location.north.line")
                                .font(.system(size: 18))
                                .foregroundColor(isFollowingHeading ? .brandPrimary : .textPrimary)
                                .frame(width: 44, height: 44)
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private var mapSection: some View {
        Group {
            if let parkingCoordinate = store.parkingCoordinate {
                Map(position: $position) {
                    // 주차 위치 마커
                    Marker(
                        "주차 위치",
                        systemImage: "car.fill",
                        coordinate: parkingCoordinate
                    )
                    .tint(.red)

                    
                    // 현재 위치는 자동으로 표시됨
                    UserAnnotation()
                }
                .mapScope(mapScope)
                .mapControls {
                    MapScaleView()
                }
                .onAppear {
                    position = .region(MKCoordinateRegion(
                        center: parkingCoordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                    ))
                    headingManager.startUpdatingHeading()
                }
                .onDisappear {
                    headingManager.stopUpdatingHeading()
                }
            } else {
                // GPS 좌표가 없을 때
                ZStack {
                    LinearGradient(
                        colors: [.backgroundStart, .backgroundEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    VStack(spacing: 20) {
                        Image(systemName: "mappin.slash")
                            .font(.system(size: 64))
                            .foregroundColor(.textSecondary.opacity(0.6))

                        Text("GPS 위치 정보가 없습니다")
                            .font(.headline)
                            .foregroundColor(.textPrimary)

                        Text("주차 시작 시 위치를 저장해주세요")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
    }
}

#Preview {
    MapView(
        store: Store(initialState: MapFeature.State()) {
            MapFeature()
        }
    )
}
