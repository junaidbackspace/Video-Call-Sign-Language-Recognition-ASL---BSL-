//
//  AddFriendViewController.swift
//  CommFusion
//
//  Created by Umer Farooq on 04/06/2024.
//  Copyright © 2024 n0. All rights reserved.
//
import UIKit
import Kingfisher


import UIKit

class AddFriendViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate{

   var serverWrapper = APIWrapper()

     var contacts = [User]()
     var filteredContacts = [User]()
     var dumylist = [User]()

     // iterate from i = 1 to i = 3
    
    
     
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
     
    
     override func viewDidLoad() {
         super.viewDidLoad()
     
        
         
         DispatchQueue.global().async {
                self.fetchContactsData()
         }
         searchbtnSetup()
        
         addDoneButtonToKeyboard()
         for i in 0..<contacts.count {
             contacts.append(contacts[i])
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

     @IBAction func Back(_ sender: Any) {
         
         self.navigationController?.popViewController(animated: true)
         
         
         
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
             
             
             cell.call.setBackgroundImage(UIImage(named: "videocall"), for: .normal)
             cell.call.imageView?.contentMode = .scaleAspectFit
 //            cell.call.frame.size.width = CGFloat(32)
 //            cell.call.frame.size.height = CGFloat(18)
             
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
     

    

     @objc func btn_call(_ sender:UIButton)
     {
         
         var userid = UserDefaults.standard.integer(forKey: "userID")
             let controller = self.storyboard?.instantiateViewController(identifier: "callerscreen") as! CallerViewController
         
         controller.callerid = userid
         controller.recieverid = contacts[sender.tag].UserId
         controller.name =  contacts[sender.tag].Fname+" "+contacts[sender.tag].Lname
         controller.isringing = "Calling"
         if contacts[sender.tag].ProfilePicture != "" {
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
         }
             }
         else{
             controller.profilepic =  UIImage(named: "noprofile", in: Bundle.main, compatibleWith: nil)!
             
         }
             
        
         controller.modalPresentationStyle = .fullScreen
         controller.hidesBottomBarWhenPushed = true
         self.navigationController?.pushViewController(controller, animated: true)
                
     }
     
}



extension AddFriendViewController: UITextFieldDelegate {
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


