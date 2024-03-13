//
//  CallLogsViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 07/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import Kingfisher

class CallLogsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
     var logindefaults = UserDefaults.standard
     var serverWrapper = APIWrapper()

     var contacts = [User]()
     var filteredContacts = [User]()
     var dumylist = [User]()
    
    @IBOutlet weak var tble: UITableView!
    
    
   
    
    @IBAction func btn_settings(_ sender: Any) {
    let controller = self.storyboard!.instantiateViewController(identifier: "settings")
        controller.modalPresentationStyle = .fullScreen
        controller.hidesBottomBarWhenPushed = true
      self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
    var searchTextField: UITextField!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    func searchbtnSetup()
    {
       
        
        searchTextField = UITextField()
                searchTextField.borderStyle = .roundedRect
                searchTextField.placeholder = "Search"
                searchTextField.translatesAutoresizingMaskIntoConstraints = false
                searchTextField.isHidden = true // Initially hidden
                view.addSubview(searchTextField)
                
                // Add constraints for the search text field
                NSLayoutConstraint.activate([
                    searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
                    searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    searchTextField.heightAnchor.constraint(equalToConstant: 40)
                ])
        searchTextField.delegate = self
      
    }
    
    func addDoneButtonToKeyboard() {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
        let doneButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(doneButtonTapped))
            toolbar.items = [doneButton]
            
            searchTextField.inputAccessoryView = toolbar
        }
        
        @objc func doneButtonTapped() {
            searchTextField.resignFirstResponder() // Dismiss keyboard
            searchTextField.isHidden = true // Hide search text field
            if let constraint = tableViewTopConstraint {
                // Adjust the top constraint of the table view
                if searchTextField.isHidden {
                    // Hide the text field
                    constraint.constant = 50
                } else {
                    // Show the text field and increase top constraint
                    constraint.constant = 100
                }
                
                // Animate the constraint change
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            } else {
                print("tableViewTopConstraint is nil")
            }
        }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        // Toggle visibility of the search text field
            searchTextField.isHidden = !searchTextField.isHidden
            
            
            if let constraint = tableViewTopConstraint {
                // Adjust the top constraint of the table view
                if searchTextField.isHidden {
                    // Hide the text field
                    constraint.constant = 50
                } else {
                    // Show the text field and increase top constraint
                    constraint.constant = 100
                }
                
                // Animate the constraint change
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            } else {
                print("tableViewTopConstraint is nil")
            }
        }
    
    
    

    //Check call Status is missed or iscaller

    func callStatusCheck(iscaller :Int , ismissed: Int) -> UIImage{
        //"arrow.down.right"
        if iscaller == 0 {
        let imageName = "arrow.up.backward"
        let image = UIImage(systemName: imageName)!
            return image.withTintColor(.red)
        }
        else {
            let imageName = "arrow.down.right"
            let image = UIImage(systemName: imageName)!
            return image.withTintColor(.green)
        }
        return UIImage(systemName: "imageName")!
        
        
    }
    
    
 

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("no of callers are \(self.contacts.count)")
        return self.contacts.count
    }
    
    var n = 0
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tble.dequeueReusableCell(withIdentifier: "c11") as? CallLogsTableTableViewCell
        
        //To take orignallist
        if n < 1{
            print(" Copying orignal contacts")
            dumylist = contacts
            filteredContacts = contacts
             n += 1
        }
        
       
        
        cell?.name.text = contacts[indexPath.row].Fname+" "+contacts[indexPath.row].Lname
        if contacts[indexPath.row].isCaller {
        cell?.callStatus.image = callStatusCheck(iscaller: 1,ismissed: 0)
        }
        else {
            cell?.callStatus.image = callStatusCheck(iscaller: 0,ismissed: 0)
        }
        
        
        if contacts[indexPath.row].Status == 1{
        if let image = UIImage(named: "online", in: Bundle.main, compatibleWith: nil) {
            cell?.isActive?.image = image
                }
        }
        
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, h:mm a"
            let formattedDate = dateFormatter.string(from: Date())
        
        cell?.callTime.text = contacts[indexPath.row].Call_StartTime
        
        if let image = UIImage(named: "online", in: Bundle.main, compatibleWith: nil) {
            cell?.isActive?.image = image
                }
        
        cell?.call.tag = indexPath.row
        cell?.call.addTarget(self, action: #selector(btn_call(_:)), for: .touchUpInside)
        
        
        let base = "\(Constants.serverURL)\(contacts[indexPath.row].ProfilePicture)"
        print("\n url is: \(base)")
        if let url = URL(string: base) {
            cell?.profilepic.kf.setImage(with: url, placeholder: UIImage(named: "No image found"))
            cell?.profilepic?.layer.cornerRadius = 28
            cell?.profilepic?.clipsToBounds = true
              }
                
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tble.cellForRow(at: indexPath)
               cell?.backgroundColor = .white
        let profilepic = contacts[indexPath.row].ProfilePicture
          
        let controller = self.storyboard?.instantiateViewController(identifier: "userdetails") as! UserProfileViewController
      
        
        controller.name = contacts[indexPath.row].Fname+" "+contacts[indexPath.row].Lname
        controller.about = contacts[indexPath.row].AccountStatus
        controller.distype = contacts[indexPath.row].UserType
        
        let base = "\(Constants.serverURL)\(contacts[indexPath.row].ProfilePicture)"
        if let url = URL(string: base) {
            
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let value):
                    let downloadedImage = value.image
                    controller.img = downloadedImage
                case .failure(let error):
                    print("Error downloading image: \(error)")
                }
            }
        } else {
            print("Invalid URL")
        }
    }
           
    @objc func btn_call(_ sender:UIButton)
    {
        
        let controller = self.storyboard?.instantiateViewController(identifier: "callerscreen") as! CallerViewController
    controller.name =  contacts[sender.tag].Fname+" "+contacts[sender.tag].Lname
    controller.isringing = "Calling"
    
    let base = "\(Constants.serverURL)\(contacts[sender.tag].ProfilePicture)"
    if let url = URL(string: base) {
        
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                let downloadedImage = value.image
                controller.profilepic = downloadedImage
            case .failure(let error):
                print("Error downloading image: \(error)")
            }
        }
    } else {
        print("Invalid URL")
    }
    
   
        controller.modalPresentationStyle = .fullScreen
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
           
}
               
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global().async {
               self.fetchCallHistory()
        }
        
        searchbtnSetup()
       
        addDoneButtonToKeyboard()
        for i in 0..<contacts.count {
            contacts.append(contacts[i])
        }
      
    }
    func fetchCallHistory() {
        let u = User()
        guard let userID = self.logindefaults.string(forKey: "userID") else {
            print("User ID not found")
            return
        }
        
        let Url = "\(Constants.serverURL)/get_user_calls"
        
        let parameters: [String: Any] = [
            "user_id": userID
        ]
        
        self.serverWrapper.insertData(baseUrl: Url, u: u, userDictionary: parameters) { responseString, error in
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
                            
                           if let userObjectsArray = jsonArray.first as? [[String: Any]] {
                            self.processContactsData(userObjectsArray)
                            
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
        for userObject in jsonArray {
            guard let accountStatus = userObject["AccountStatus"] as? String,
                  let firstName = userObject["Fname"] as? String,
                  let lastName = userObject["Lname"] as? String,
                  let online = userObject["Status"] as? Int,
                  let callStart = userObject["StartTime"] as? String,
                  let callEnd = userObject["EndTime"] as? String,
                  let iscaller = userObject["IsCaller"] as? Bool,
                  let participantID = userObject["User_id"] as? Int,
                  let profilePicture = userObject["ProfilePicture"] as? String else {
                print("Error: Invalid user data")
                continue
            }
            
            var user = User()
            print("Fname: \(firstName) Lname: \(lastName) accountStatus: \(accountStatus) ProfilePic: \(profilePicture)")
            user.AccountStatus = accountStatus
            user.Fname = firstName
            user.Lname = lastName
            user.ProfilePicture = profilePicture
            user.Status = online
            user.Call_StartTime = callStart
            user.Call_EndTime = callEnd
            user.Callparticipant_Id = participantID
            user.isCaller = iscaller
            self.contacts.append(user)
            
            print("User details:")
            print("Account Status:", accountStatus)
            print("First Name:", firstName)
            print("Last Name:", lastName)
            print("Call Start:", callStart)
            print("Call End:", callEnd)
            print("Profile Picture:", profilePicture)
            print("Participant id :", participantID)
            print("Is i am caller :", iscaller)
            print("------------------")
        }
        
        DispatchQueue.main.async {
            self.tble.dataSource = self
            self.tble.delegate = self
            self.tble.reloadData()
        }
    
}
    

}
extension CallLogsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the new text after appending the replacement string
        guard let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else {
            return false
        }
       
        if newText.count == 0
        {
            print("typing: "+newText)
            contacts =  dumylist
            tble.reloadData()
            return true
    
        }
        // Filter the contacts based on the new text
        contacts = filteredContacts.filter { $0.Fname.lowercased().contains(newText.lowercased()) }
        
        // Update the UI with the filtered data
        tble.reloadData()
        
        return true
    }
}
