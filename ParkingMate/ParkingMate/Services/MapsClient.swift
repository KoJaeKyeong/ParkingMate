import MapKit
import ComposableArchitecture

struct MapsClient {
    var openDirections: @Sendable (GPSCoordinate) async -> Void
}

extension MapsClient: DependencyKey {
    static let liveValue = Self(
        openDirections: { coordinate in
            await MainActor.run {
                let placemark = MKPlacemark(
                    coordinate: CLLocationCoordinate2D(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )
                )
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = String(localized: "주차 위치")
                // 차로 돌아가는 상황이므로 도보 경로로 안내
                mapItem.openInMaps(launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
                ])
            }
        }
    )

    static let testValue = Self(
        openDirections: { _ in }
    )
}

extension DependencyValues {
    var mapsClient: MapsClient {
        get { self[MapsClient.self] }
        set { self[MapsClient.self] = newValue }
    }
}
