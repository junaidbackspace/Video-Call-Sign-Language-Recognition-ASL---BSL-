//
//  AddContactViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 07/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import Kingfisher

class AddContactViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate{
    
    var logindefaults = UserDefaults.standard
    var serverWrapper = APIWrapper()
    
    var contacts = [User]()
    
    @IBAction func btnback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtsearch.frame = CGRect(x: txtsearch.frame.origin.x,
                                y: txtsearch.frame.origin.y,
                                width: txtsearch.frame.size.width,
                                height: 80)
        txtsearch.layer.borderWidth = 1.0
        txtsearch.layer.borderColor = UIColor.gray.cgColor
        txtsearch.layer.cornerRadius = 27
        
        // Do any additional setup after loading the view.
    }
    @IBAction func btnSearch(_ sender: Any) {
        //on again click
        contacts.removeAll()
        self.tble.reloadData()
      
            if self.rdemail.isSelected{
                self.fetchContactsData(Url: "http://192.168.31.106:5000/search_user_by_email", searchby: self.txtsearch.text!)
                print("Entered in Email Selected: \(self.txtsearch.text!)")
            }
            else if self.rdusername.isSelected {
                self.fetchContactsData(Url: "http://192.168.31.106:5000/search_user" ,searchby: self.txtsearch.text!)
                print("Entered in username Selected: \(self.txtsearch.text!)")
                
            }
           
    }
    func fetchContactsData(Url : String, searchby : String) {
      
        guard let userID = self.logindefaults.string(forKey: "userID") else {
            print("User ID not found")
            return
        }
        
        
        var parameters: [String: Any] = [
            "user_id": userID,
            "search_email": searchby
        ]
        if self.rdemail.isSelected{
            print("Entered in Email Selected")
            parameters = [
            "user_id": userID,
            "search_email": searchby
        ]
        }
        if self.rdusername.isSelected{
            print("Entered in username Selected")
            parameters = [
            "user_id": userID,
            "search_username": searchby
        ]
        }
        
        self.serverWrapper.insertData(baseUrl: Url, userDictionary: parameters) { responseString, error in
            if let error = error {
                print("Error:", error)
                // Handle the error appropriately
            } else if let responseString = responseString {
                print("Server response:", responseString)
                
                do {
                    guard let jsonData = responseString.data(using: .utf8) else {
                        print("Failed to convert response string to data")
                        return
                    }
                    
                    let jsonArrayServer = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [Any]
                    
                    guard let jsonArray = jsonArrayServer else {
                        print("Invalid JSON array format")
                        return
                    }
                    
                    print("JSON Array:", jsonArray)
                    
                    if let firstElement = jsonArray.first as? [String: Any] {
                        // Pass the single dictionary to the processContactsData function
                        print("first element : \(firstElement)")
                        self.processContactsData([firstElement])
                    } else if let userObjectsArray = jsonArray.first as? [[String: Any]] {
                        // Pass the array of dictionaries to the processContactsData function
                   
                        self.processContactsData(userObjectsArray)
                    } else {
                        print("Unexpected format for the first element of the JSON array")
                    }
                } catch {
                    print("Error parsing JSON data:", error)
                    // Handle the parsing error appropriately
                }
            } else {
                print("No response string received from server")
            }
        }

    }

    func processContactsData(_ jsonArray: [[String: Any]]) {
        print("\nProcessing----\n")
        for userObject in jsonArray {
            print("user Object : \(userObject)")
            
            guard let accountStatus = userObject["account_status"] as? String,
                  let firstName = userObject["fname"] as? String,
                  let lastName = userObject["lname"] as? String,
                  let profilepic = userObject["profile_picture"] as? String,
                  let isFriendValue = userObject["is_friend"] as? Bool,
                  let userId = userObject["user_id"] as? Int else {
                print("Error: Invalid user data")
                continue
            }

           
            var user = User()
            print("Fname: \(firstName) Lname: \(lastName) accountStatus: \(accountStatus) ProfilePic: ")
            user.AccountStatus = accountStatus
            user.Fname = firstName
            user.Lname = lastName
            user.ProfilePicture = profilepic
            user.isfriend = isFriendValue
            user.UserId = userId
            
            self.contacts.append(user)
            
            print("User details:")
            print("Account Status:", accountStatus)
            print("First Name:", firstName)
            print("Last Name:", lastName)
//            print("Profile Picture:", profilePicture)
//            print("Is Friend:", isFriendValue)
            print("User ID:", userId)
            print("------------------")
        }
        
        // Reload table view data after processing
        DispatchQueue.main.async {
            self.tble.dataSource = self
            self.tble.delegate = self
            self.tble.reloadData()
        }
    }

    @IBAction func rdemailClick(_ sender: Any) {
        rdemail.isSelected = true
        rdusername.isSelected = false
        txtsearch.placeholder = "Search by Email"
        
    }
    @IBAction func rdusernameClick(_ sender: Any) {
        rdemail.isSelected = false
        rdusername.isSelected = true
        txtsearch.placeholder = "Search by Username"
    }
    @IBOutlet weak var rdemail: UIButton!
    @IBOutlet weak var rdusername: UIButton!
    
    @IBOutlet weak var tble: UITableView!
    @IBOutlet weak var txtsearch: UITextField!

    
    let imageNames = ["profilepic"]

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tble.dequeueReusableCell(withIdentifier: "c1") as? AddFriendTableViewCell
        
        cell?.name.text = contacts[indexPath.row].Fname+" "+contacts[indexPath.row].Lname
        cell?.about.text = contacts[indexPath.row].AccountStatus
        cell?.btnadd.tag = contacts[indexPath.row].UserId
        cell?.btnadd.addTarget(self, action: #selector(AddFriend(_:)), for: .touchUpInside)

        
        let base = "http://192.168.31.106:5000\(contacts[indexPath.row].ProfilePicture)"
        print("\n url is: \(base)")
        if let url = URL(string: base) {
            cell?.profilePic?.kf.setImage(with: url, placeholder: UIImage(named: "No image found"))
            cell?.profilePic?.layer.cornerRadius = 29
            cell?.profilePic?.clipsToBounds = true
        }
//        if let image = UIImage(named: imageNames[indexPath.row], in: Bundle.main, compatibleWith: nil) {
//            cell?.profilePic?.image = image
//            cell?.profilePic?.layer.cornerRadius = 29
//
//            cell?.profilePic?.clipsToBounds = true
//
//                }
                
        return cell!
    }
   //Send Request
    @objc func AddFriend(_ sender:UIButton) {
        let userID = self.logindefaults.string(forKey: "userID")
        print("clicked",sender.tag)
        
        let Url = "http://192.168.31.106:5000/add_user_contact"

        let Dic: [String: Any] = [
            "user_id": userID ?? "",
            "contacts_id": sender.tag,
        ]

        serverWrapper.insertData(baseUrl: Url,  userDictionary: Dic) { responseString, error in
            if let error = error {
                print("Error:", error)
            } else {
                if let responseString = responseString {
                    print("Add to Contact response:", responseString)
                    
                    DispatchQueue.main.async {
                            if let cell = sender.superview?.superview as? AddFriendTableViewCell {
                                cell.btnadd.setBackgroundImage(UIImage(named: "freind_Added"), for: .normal)
                            }
                        }
                }
            }
        }
    }


}
