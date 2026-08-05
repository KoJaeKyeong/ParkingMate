import Foundation

public struct ParkingInfo: Equatable, Codable {
    public var startTime: Date
    public var location: String
    public var photos: [PhotoItem]
    public var gpsCoords: GPSCoordinate?
    
    public init(
        startTime: Date = .init(),
        location: String = "",
        photos: [PhotoItem] = [],
        gpsCoords: GPSCoordinate? = nil
    ) {
        self.startTime = startTime
        self.location = location
        self.photos = photos
        self.gpsCoords = gpsCoords
    }
}

public struct GPSCoordinate: Equatable, Codable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct PhotoItem: Identifiable, Equatable, Codable {
    public let id: UUID
    public let imageData: Data
    
    public init(id: UUID, imageData: Data) {
        self.id = id
        self.imageData = imageData
    }
}
