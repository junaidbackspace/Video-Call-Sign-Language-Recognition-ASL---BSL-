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
    
                if searchTextField.isHidden {
                    
                    constraint.constant = 50
                } else {
                    
                    constraint.constant = 100
                }
                
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
        cell?.about.text = contacts[indexPath.row].BioStatus
       
        if let image = UIImage(named: "online", in: Bundle.main, compatibleWith: nil) {
            cell?.isActive?.image = image
                }
        
        cell?.call?.tag = indexPath.row
        cell?.call?.addTarget(self, action: #selector(btn_call(_:)), for: .touchUpInside)
        
             

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
        controller.about = contacts[indexPath.row].BioStatus
        controller.distype = contacts[indexPath.row].UserType
        
        let base = "\(Constants.serverURL)\(contacts[indexPath.row].ProfilePicture)"
        
        print("\nfor \(controller.name) \nProfilePic : \(base)")
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
       
        guard let userID = self.logindefaults.string(forKey: "userID") else {
            print("User ID not found")
            return
        }
        
        let Url = "\(Constants.serverURL)/contacts/\(userID)/online-contacts"
        print("URL: "+Url)
      
        
        self.serverWrapper.fetchData(baseUrl: Url) { jsonData, error in
            if let error = error {
                print("Error:", error.localizedDescription)
               
            } else if let jsonData = jsonData {
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

                // Now you can use these properties as needed
                print("Fname: \(firstName), Lname: \(lastName), OnlineStatus: \(onlineStatus), BioStatus: \(bioStatus), ProfilePic: \(profilePicture)")

                // Optionally, you can create a User object and append it to contacts array
                var user = User()
                user.BioStatus = bioStatus
                user.Fname = firstName
                user.Lname = lastName
                user.ProfilePicture = profilePicture
                user.OnlineStatus = onlineStatus
                self.contacts.append(user)
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

        
        let searchText = newText.lowercased()
        contacts = filteredContacts.filter { contact in
            let fullName = "\(contact.Fname.lowercased()) \(contact.Lname.lowercased())"
            
            // Check if full name length is greater than or equal to search text length
            guard fullName.count >= searchText.count else {
                return false
            }
            
            var searchIndex = searchText.startIndex
            
            // Iterate through each character of the full name
            for char in fullName {
                // If character matches search text character, move to next search text character
                if char == searchText[searchIndex] {
                    searchIndex = searchText.index(after: searchIndex)
                }
                // If reached end of search text, return true
                if searchIndex == searchText.endIndex {
                    return true
                }
            }
            // If search text characters were not found in sequence in full name, return false
            return false
        }

        // Update the UI with the filtered data
        tble.reloadData()
        
        return true
    }
}
