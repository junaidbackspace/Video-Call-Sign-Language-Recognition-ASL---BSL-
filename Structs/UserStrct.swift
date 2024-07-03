
import Foundation
struct User : Codable {
    
    
    var Username = " "
    var DateOfBirth = Date()
    var DOB = Date()
    var Password = " "
    var ProfilePicture = ""
    var Email = ""
    var UserType = ""
    var Fname = ""
    var Lname = ""
    var BioStatus = ""
    var OnlineStatus = 0
    var RegistrationDate = Date()
    var RegDate = Date()
    var isfriend = false
    var UserId = 0
    var Call_StartTime = ""
    var Call_EndTime: String? = nil

    var CallId = 0
    var isCaller = 0
    var Callparticipant_Id = 0
    var IsBlocked = 0
    var IsMutted = 0
    var IsPinned = 0
    var Les_id = 0
    var Les_Des = ""
    var Les_Res = ""
    var Gesture_id = 0

}
struct ContactsUser: Codable {
    let fname: String
    let lname: String
    let profile_picture: String
    let account_status: String
    let bio_status: String
    let online_status: Int
    let user_id: Int
    let user_name : String
    let is_blocked : Int
    let disability : String
    
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

//Call History
struct CallLogs : Codable {
    let VideoCallId: Int
    let OtherParticipantFname: String
    let OtherParticipantLname: String
    let ProfilePicture: String
    let OnlineStatus: Int
    let AccountStatus: String
    let isCaller: Int
    let EndTime: String?
    let StartTime: String
    let user_id: Int
    let user_name : String
   
}

struct Lesson: Codable {
    let Id: Int
    let LessonId: Int
    let Description: String
    let Resource: String
    
    
}
struct OnlineStatusRequestBody: Codable {
    let online_status: Int
}


struct singleUserInfo : Codable{
   
    let fname : String
    let lname : String
    let DateOfBirth : String
    let password : String
    let profile_picture : String
    let email : String
    let disability_type : String
    let account_status : String
    let bio_status : String
    let registration_date : String
    let online_status : Int
    
}

struct updateUserProfile : Codable {
    
    let user_id: Int
    let current_password: String
    let new_password: String
    let new_fname : String
    let new_lname : String
    let new_bio_status : String
    let new_disability_type : String
}

struct UserFavouriteLessons : Codable{
    
    let UserId:  Int
    let GestureId : Int
}


struct TranscriptSegment: Codable {
    let UserId: Int
    let VideoCallId: String
    let StartTime: String
    let EndTime: String
    let Content: String
}


struct CreateTranscriptSegmentResponse: Codable {
    
    let UserId: Int
    let VideoCallId: String
    let StartTime: String
    let EndTime: String
    let Content: String
    let Id: Int
    let SegmentNumber: Int
}

import Foundation

struct TranscriptResponseSegment: Codable {
    let id: Int
    let userId: Int
    let videoCallId: Int
    let segmentNumber: Int
    let startTime: String
    let endTime: String
    let content: String
    let fullname: String

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case userId = "UserId"
        case videoCallId = "VideoCallId"
        case segmentNumber = "SegmentNumber"
        case startTime = "StartTime"
        case endTime = "EndTime"
        case content = "Content"
        case fullname = "Fullname"
    }
}

struct TranscriptResponse: Codable {
    let transcriptSegments: [TranscriptResponseSegment]

    enum CodingKeys: String, CodingKey {
        case transcriptSegments = "transcript_segments"
    }
}
