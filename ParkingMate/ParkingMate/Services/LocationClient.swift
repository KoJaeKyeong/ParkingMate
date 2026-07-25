import CoreLocation
import ComposableArchitecture

struct LocationClient {
    var requestAuthorization: @Sendable () async -> Void
    var requestLocation: @Sendable () async throws -> GPSCoordinate
}

extension LocationClient: DependencyKey {
    static let liveValue = Self(
        requestAuthorization: {
            await MainActor.run {
                LocationManager.shared.requestAuthorization()
            }
        },
        requestLocation: {
            try await LocationManager.shared.requestCurrentLocation()
        }
    )

    static let testValue = Self(
        requestAuthorization: { },
        requestLocation: {
            GPSCoordinate(latitude: 37.5665, longitude: 126.9780)
        }
    )
}

extension DependencyValues {
    var locationClient: LocationClient {
        get { self[LocationClient.self] }
        set { self[LocationClient.self] = newValue }
    }
}

// MARK: - LocationManager

private final class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared: LocationManager = {
        let instance = LocationManager()
        return instance
    }()

    private let manager: CLLocationManager
    private var continuation: CheckedContinuation<GPSCoordinate, Error>?

    override init() {
        self.manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // 앱 시작 시 권한만 요청
    func requestAuthorization() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestAlwaysAuthorization()
        }
    }

    func requestCurrentLocation() async throws -> GPSCoordinate {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(throwing: LocationError.notAuthorized)
                return
            }

            self.continuation = continuation

            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            default:
                self.continuation = nil
                continuation.resume(throwing: LocationError.notAuthorized)
            }
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        continuation?.resume(returning: GPSCoordinate(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        ))
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // requestCurrentLocation 중 권한 변경 시 처리
        guard continuation != nil else { return }

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            continuation?.resume(throwing: LocationError.notAuthorized)
            continuation = nil
        default:
            break
        }
    }
}

enum LocationError: LocalizedError {
    case notAuthorized

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return String(localized: "위치 권한이 없습니다. 설정에서 권한을 허용해주세요.")
        }
    }
}
