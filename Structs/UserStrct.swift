
import Foundation
struct User : Codable {
    
    
    var Username = " "
    var DateOfBirth = Date()
    var Password = " "
    var ProfilePicture = ""
    var Email = ""
    var UserType = ""
    var Fname = ""
    var Lname = ""
    var BioStatus = ""
    var OnlineStatus = 0
    var RegistrationDate = Date()
    var isfriend = false
    var UserId = 0
    var Call_StartTime = ""
    var Call_EndTime = ""
    var isCaller = false
    var Callparticipant_Id = 0
    var IsBlocked = 0
    var IsMutted = 0
    var IsPinned = 0

}
struct ContactsUser: Codable {
    let fname: String
    let lname: String
    let profile_picture: String
    let account_status: String
    let bio_status: String
    let online_status: Int
    
}

struct addUser: Codable {
    let user_id: Int
    let username: String
    let fname: String
    let lname: String
    let account_status: String
    let profile_picture: String
    let is_friend: Bool
    let bio_status: String

    enum CodingKeys: String, CodingKey {
        case user_id
        case username
        case fname
        case lname
        case account_status
        case profile_picture
        case is_friend
        case bio_status
    }
}


