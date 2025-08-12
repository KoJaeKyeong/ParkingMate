import Foundation
import UIKit

struct ParkingInfo: Equatable {
    var startTime: Date?
    var location: String = ""
    var photos: [PhotoItem] = []
    var gpsCoords: GPSCoordinate?
}

struct GPSCoordinate: Equatable {
    let latitude: Double
    let longitude: Double
}

struct PhotoItem: Identifiable, Equatable {
    let id = UUID()
    let image: UIImage?
    
    static func == (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        lhs.id == rhs.id
    }
}
