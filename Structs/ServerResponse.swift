//
//  ServerResponse.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 06/03/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import Foundation
struct ServerResponse: Decodable {
    let message: String
    let userId: Int
}
struct Constants {
    static let serverURL = "http://192.168.31.105:5000"
}
