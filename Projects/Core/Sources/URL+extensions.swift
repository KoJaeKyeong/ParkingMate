//
//  URL+extensions.swift
//  ParkingMate
//
//  Created by 고재경 on 8/14/25.
//

import Foundation

extension URL {
  public static let parkingInfo = Self.documentsDirectory.appending(component: "parking-info.json")
}
