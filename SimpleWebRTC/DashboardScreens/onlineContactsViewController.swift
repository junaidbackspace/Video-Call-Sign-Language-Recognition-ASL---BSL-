//
//  onlineContactsViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 06/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import Kingfisher


class onlineContactsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    var logindefaults = UserDefaults.standard
    var serverWrapper = APIWrapper()
    
    var contacts = [User]()
    var filteredContacts = [User]()
    var dumylist = [User]()

   
    @IBAction func addFriend(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(identifier: "addcontacts") 
        controller?.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(controller!, animated: true)
        
    }
    
    @IBAction func btn_settings(_ sender: Any) {
    let controller = self.storyboard!.instantiateViewController(identifier: "settings")
        controller.modalPresentationStyle = .fullScreen
        controller.hidesBottomBarWhenPushed = true
      self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnplus(_ sender: Any) {
        if btncontactOutlet.isHidden{
        btncontactOutlet.isHidden = false
        }
        else{
        btncontactOutlet.isHidden = true
        }
    }
 
    @IBOutlet weak var btncontactOutlet: UIButton!
    @IBAction func btncontact(_ sender: Any) {

        
        let controller = self.storyboard?.instantiateViewController(identifier: "Contacts") as! ContactsViewController
        controller.modalPresentationStyle = .fullScreen
        controller.hidesBottomBarWhenPushed = true
          self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBOutlet weak var tble: UITableView!
    
    
    
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
    
    
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("no of contacts are \(self.contacts.count)")
        return self.contacts.count
    }
    
    var n = 0
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tble.dequeueReusableCell(withIdentifier: "c1") as? ContactTableTableViewCell
        
        //To take orignallist
        if n < 1{
            print(" Copying orignal contacts")
            dumylist = contacts
            filteredContacts = contacts
             n += 1
        }
        print("User Full name : \(contacts[indexPath.row].Fname+" "+contacts[indexPath.row].Lname)")
        
        cell?.name.text = contacts[indexPath.row].Fname+" "+contacts[indexPath.row].Lname
        cell?.about.text = contacts[indexPath.row].AccountStatus
       
        if let image = UIImage(named: "online", in: Bundle.main, compatibleWith: nil) {
            cell?.isActive?.image = image
                }
        
        cell?.call?.tag = indexPath.row
        cell?.call?.addTarget(self, action: #selector(btn_call(_:)), for: .touchUpInside)
        
             
//        if let image = UIImage(named: "http://localhost:5000"+contacts[indexPath.row].ProfilePicture, in: Bundle.main, compatibleWith: nil) {
////            http://localhost:5000/profile_images/B3DA9C5F-F977-4894-BF50-64D27A5FA0FF.jpeg
//            cell?.profilepic?.image = image
//
//
//                }
        let base = "\(Constants.serverURL)\(contacts[indexPath.row].ProfilePicture)"
        print("\n url is: \(base)")
        if let url = URL(string: base) {
            cell?.profilepic.kf.setImage(with: url, placeholder: UIImage(named: "No image found"))
            cell?.profilepic?.layer.cornerRadius = 27
            cell?.profilepic?.clipsToBounds = true
              }
                
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tble.cellForRow(at: indexPath)
               cell?.backgroundColor = .white
        
        
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
          
        controller.modalPresentationStyle = .fullScreen
        //self.present(controller, animated: true, completion: nil)
        self.navigationController?.pushViewController(controller, animated: true)
           }
    
    
    @objc func btn_call(_ sender:UIButton)
    {
        
            let controller = self.storyboard?.instantiateViewController(identifier: "callerscreen") //as! CallerViewController
//            controller.name =  names [sender.tag]
//        controller.isringing = "Calling"
//        if let image = UIImage(named: contacts[sender.tag].imageName, in: Bundle.main, compatibleWith: nil) {
//            controller.profilepic = image
           
        //        }
       
        controller?.modalPresentationStyle = .fullScreen
        controller?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller!, animated: true)
               
    }
    
       
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global().async {
               self.fetchContactsData()
           }
        btncontactOutlet.isHidden = true
        searchbtnSetup()
       
        addDoneButtonToKeyboard()
        for i in 0..<contacts.count {
            contacts.append(contacts[i])
        }
      }
    func fetchContactsData() {
        var u = User()
        guard let userID = self.logindefaults.string(forKey: "userID") else {
            print("User ID not found")
            return
        }
        
        let Url = "\(Constants.serverURL)/get_user_contacts"
        
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
            guard let accountStatus = userObject["account_status"] as? String,
                  let firstName = userObject["fname"] as? String,
                  let lastName = userObject["lname"] as? String,
                  let profilePicture = userObject["profile_picture"] as? String else {
                print("Error: Invalid user data")
                continue
            }
            
            var user = User()
            print("Fname: \(firstName) Lname: \(lastName) accountStatus: \(accountStatus) ProfilePic: \(profilePicture)")
            user.AccountStatus = accountStatus
            user.Fname = firstName
            user.Lname = lastName
            user.ProfilePicture = profilePicture
            self.contacts.append(user)
            
            print("User details:")
            print("Account Status:", accountStatus)
            print("First Name:", firstName)
            print("Last Name:", lastName)
            print("Profile Picture:", profilePicture)
            print("------------------")
        }
        
        DispatchQueue.main.async {
            self.tble.dataSource = self
            self.tble.delegate = self
            self.tble.reloadData()
        }
    }
}
//On Key Press
extension onlineContactsViewController: UITextFieldDelegate {
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
