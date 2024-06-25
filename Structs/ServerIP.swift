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

//<<<<<<< HEAD
    static let serverURL = "http://192.168.255.118:5001"
    static let nodeserverIP = "192.168.255.119"
//=======
    static let serverURL = "http://192.168.169.141:5001"
    static let nodeserverIP = "192.168.31.106"
//>>>>>>> 340b6af (segment saving issue solved)

}
