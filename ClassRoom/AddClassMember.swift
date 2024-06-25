//
//  AddFriendViewController.swift
//  CommFusion
//
//  Created by Umer Farooq on 04/06/2024.
//  Copyright © 2024 n0. All rights reserved.
//
import UIKit
import Kingfisher
import Starscream
import UIKit

class AddClassMemberViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{

    

   var serverWrapper = APIWrapper()

     var contacts = [User]()
     var filteredContacts = [User]()
     var dumylist = [User]()
    let sharedSockets = socketsClass.shared
 
       
     // iterate from i = 1 to i = 3
    
    
    @IBOutlet weak var tbNames: UITextField!
     @IBOutlet weak var tble: UITableView!
     
 
    
     override func viewDidLoad() {
         super.viewDidLoad()
     
        
                // Add right swipe gesture recognizer
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
                rightSwipe.direction = .right
                self.view.addGestureRecognizer(rightSwipe)
                
                // Add left swipe gesture recognizer
                let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
                leftSwipe.direction = .left
                self.view.addGestureRecognizer(leftSwipe)
        
        
         DispatchQueue.global().async {
                self.fetchContactsData()
         }
        
        
        
        
       //  MARK:-
         
         
       
     }
     func fetchContactsData() {
        
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
             print("User ID not found")
             return
         }
         
         let Url = "\(Constants.serverURL)/contacts/\(userID)/contacts"
         print("URL: "+Url)
       
         let url = URL(string: Url)!
         serverWrapper.fetchData(baseUrl: url, structure: [ContactsUser].self) { contactsUsers, error in
             if let error = error {
                 print("Error:", error.localizedDescription)
                
             } else if let jsonData = contactsUsers {
                 print("JSON Data:", jsonData)
                
                 self.processContactsData(jsonData)
             } else {
                 print("No data received from the server")
             }
         }
     
     }

     func processContactsData(_ jsonArray: [ContactsUser]) {
             for userObject in jsonArray {
                 let bioStatus = userObject.bio_status
                 let onlineStatus = userObject.online_status
                 let firstName = userObject.fname
                 let lastName = userObject.lname
                 let profilePicture = userObject.profile_picture
                 let userid = userObject.user_id
                 let username  = userObject.user_name
                 let isBlocked  = userObject.is_blocked
                 let distype = userObject.disability
                 // Now you can use these properties as needed
              

                 // Optionally, you can create a User object and append it to contacts array
                 var user = User()
                 user.BioStatus = bioStatus
                 user.Fname = firstName
                 user.Lname = lastName
                 user.ProfilePicture = profilePicture
                 user.OnlineStatus = onlineStatus
                 user.UserId = userid
                 user.Username = username
                 user.IsBlocked = isBlocked
                 user.UserType = distype
                 self.contacts.append(user)
             }
         

         
         DispatchQueue.main.async {
             self.tble.dataSource = self
             self.tble.delegate = self
             //Sorting pinned contacts
             
             
             self.tble.reloadData()
         }
     }

 
     
     
  

     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 80
     }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         print("no of contacts are \(self.contacts.count)")
         return self.contacts.count
     }
     
     var n = 0
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tble.dequeueReusableCell(withIdentifier: "c2") as! DetailedContactsTableViewCell
         
         do {
         //To take orignallist
         if n < 1{
             print(" Copying orignal contacts")
             dumylist = contacts
             filteredContacts = contacts
              n += 1
         }
             
             guard indexPath.row < contacts.count else {
                 print("Index out of bounds")
                 return cell
             }

         
         print("index path : \(indexPath.row)")
         if contacts[indexPath.row].IsBlocked == 0 {
             

         cell.call.imageView?.contentMode = .scaleAspectFit

             
         cell.name.text = contacts[indexPath.row].Fname+" "+contacts[indexPath.row].Lname
         cell.about.text = contacts[indexPath.row].BioStatus
             
         if contacts[indexPath.row].OnlineStatus == 1{
         if let image = UIImage(named: "online", in: Bundle.main, compatibleWith: nil) {
             cell.isActive?.image = image
                 }
         }
         cell.call?.tag = indexPath.row
         cell.call?.addTarget(self, action: #selector(btn_call(_:)), for: .touchUpInside)
         
             let base = "\(Constants.serverURL)\(contacts[indexPath.row].ProfilePicture)"

             if let url = URL(string: base) {
                 // Attempt to load the image from the URL
                 cell.profilepic.kf.setImage(with: url, placeholder: UIImage(named: "No image found"), completionHandler: { result in
                     switch result {
                     case .success:
                         // Image loaded successfully, do nothing
                         break
                     case .failure:
                         // Image loading failed, set placeholder image
                         let placeholderImage = UIImage(named: "noprofile", in: Bundle.main, compatibleWith: nil)
                         cell.profilepic.image = placeholderImage
                         cell.profilepic.layer.cornerRadius = 28
                         cell.profilepic.clipsToBounds = true
                     }
                 })
                 cell.profilepic.layer.cornerRadius = 28
                 cell.profilepic.clipsToBounds = true
                 
             }
             
      
         }
         //user blocked
         else{
             print("Blocked user are : \(contacts[indexPath.row].Fname)")
             
           
             cell.name.text = contacts[indexPath.row].Fname+" "+contacts[indexPath.row].Lname
             cell.about.text = contacts[indexPath.row].BioStatus
             
 //            cell.call.setBackgroundImage(UIImage(named: "disabledvideocall"), for: .normal)
 //            cell.call.imageView?.contentMode = .scaleAspectFit
 //           cell.call.frame.size.width = CGFloat(49)
 //            cell.call.frame.size.height = CGFloat(30)
             cell.call.setBackgroundImage( nil , for: .normal)
             
             
             
             if let p_pic = UIImage(named: "noprofile", in: Bundle.main, compatibleWith: nil) {
                 cell.profilepic.layer.cornerRadius = 28
                 cell.profilepic.clipsToBounds = true
                 cell.profilepic.image = p_pic
             }
             cell.isActive?.image = nil
                     
          
         }
             
         }catch {
             // Handle the error here
             print("A little bit error : \(error)")
         }
                 return cell
       
     }
     
    var vid = 0
    var callledFriendId = 0

    var add_members = [Int]()
     @objc func btn_call(_ sender:UIButton)
     {
        
        
        let recieverid = contacts[sender.tag].UserId
        add_members.append(recieverid)
        fetch_Name(userID: recieverid)
        
         
//         var userid = UserDefaults.standard.integer(forKey: "userID")
////             let controller = self.storyboard?.instantiateViewController(identifier: "callerscreen") as! CallerViewController
////
//         let  callerid = userid
//         let recieverid = contacts[sender.tag].UserId
//         let name =  contacts[sender.tag].Fname+" "+contacts[sender.tag].Lname
//         let isringing = "Calling"
//
//        print("--->sending group call msg to  sockets..\n")
//        sharedSockets.GroupChatCall(with: String(recieverid) , caller1: String(callerid), Caller2: String(callledFriendId), vid: vid)
       
                
     }
    
    func fetch_Name(userID : Int)
    {
            let Url = "\(Constants.serverURL)/user/userdetails/\(userID)"
            print("URL: " + Url)
          
            let url = URL(string: Url)!
            
            self.serverWrapper.fetchUserInfo(baseUrl: url, structure: singleUserInfo.self) { userInfo, error in
                if let error = error {
                    print("inner URL: \(Url)")
                    print("Error in receiving:", error.localizedDescription)
                } else if let userObject = userInfo {
                    print("JSON Data:", userObject)
                    self.processUserName(userObject)
                } else {
                    print("No data received from the server")
                }
            }
        

      
    }
    
    func processUserName(_ userObject: singleUserInfo) {
        print("Processing user data")
        var Fname = userObject.fname
        var Lname = userObject.lname
        
        tbNames.text! += Fname+" "+Lname+" ,"
        

    }
    
    
    @objc func handleSwipes(_ gesture: UISwipeGestureRecognizer) {
           guard let tabBarController = self.tabBarController else { return }
           
           let numberOfTabs = tabBarController.viewControllers?.count ?? 0
           let selectedIndex = tabBarController.selectedIndex
           
           if gesture.direction == .right {
               if selectedIndex > 0 {
                   tabBarController.selectedIndex = selectedIndex - 1
               }
           } else if gesture.direction == .left {
               if selectedIndex < numberOfTabs - 1 {
                   tabBarController.selectedIndex = selectedIndex + 1
               }
           }
       }
    
    
    @IBAction func start_call(_ sender : Any)
    {
        print("Call Started")
        
        for uid in add_members{
            
            sharedSockets.ClassRoomCall(with: String(uid))
        }
    }
     
}





