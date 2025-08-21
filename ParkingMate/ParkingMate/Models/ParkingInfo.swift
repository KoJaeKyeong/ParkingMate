import Foundation
import UIKit

struct ParkingInfo: Equatable, Codable {
    var startTime: Date = .init()
    var location: String = ""
    var photos: [PhotoItem] = []
    var gpsCoords: GPSCoordinate?
}

struct GPSCoordinate: Equatable, Codable {
    let latitude: Double
    let longitude: Double
}

struct PhotoItem: Identifiable, Equatable, Codable {
    let id: UUID
    let imageData: Data
    
    static func == (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        lhs.id == rhs.id
    }
}
