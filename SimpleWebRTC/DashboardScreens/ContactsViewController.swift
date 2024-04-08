//
//  ContactsViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 06/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import Kingfisher






class ContactsViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate{
    
   
    
    
       
   
    var pinned_contacts = [String]()
    var muted_contacts = [String]()
    var longPressGesture: UILongPressGestureRecognizer!
    var longPressIndexPath: IndexPath?
   
    var logindefaults = UserDefaults.standard
    var serverWrapper = APIWrapper()

    var contacts = [User]()
    var filteredContacts = [User]()
    var dumylist = [User]()

    // iterate from i = 1 to i = 3
   
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
    
    //Notification from user profile controller
    @objc func refreshContacts() {
           print("Refreshing contacts...")
        DispatchQueue.global().async {
            print("Refreshing data")
                self.contacts = []
               self.fetchContactsData()
        }
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        NotificationCenter.default.addObserver(self, selector: #selector(refreshContacts), name: .RefreshContacts, object: nil)
       
        if let retrievedArray = UserDefaults.standard.array(forKey: "pinnedUser") as? [String] {
            let pinned_users = retrievedArray
           
            pinned_contacts = pinned_users
            
            
        }
        
        if let muttedArray = UserDefaults.standard.array(forKey: "muttedUser") as? [String] {
            let mutted_users = muttedArray
            muted_contacts = mutted_users
        }
        
        
        DispatchQueue.global().async {
               self.fetchContactsData()
        }
        searchbtnSetup()
       
        addDoneButtonToKeyboard()
        for i in 0..<contacts.count {
            contacts.append(contacts[i])
        }
      
      //  MARK:-
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tble.addGestureRecognizer(longPressGesture)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap(sender:)))
            // Make sure the recognizer doesn't cancel other touch events, like table view cell selections
            tapGestureRecognizer.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleScreenTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)

       
        if customView.isHidden == false && !customView.frame.contains(location) {
            customView.isHidden = true
            print("Hiding view")
            actionbuttons_On = true // Assuming you want to reset this flag
        }
    }

    
    var selectedrow = 0
    var actionbuttons_On = false
    var customView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if !actionbuttons_On {
            if gestureRecognizer.state == .began {
                actionbuttons_On = true
                let point = gestureRecognizer.location(in: tble)
                          if let indexPath = tble.indexPathForRow(at: point), let cell = tble.cellForRow(at: indexPath) {
                              longPressIndexPath = indexPath
                              selectedrow = indexPath.row

                    customView.subviews.forEach { $0.removeFromSuperview() }
                            let lightBlueColor = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1.0)

                            customView.backgroundColor = lightBlueColor
                    customView.alpha = 0.8
                    customView.isHidden = false

                   
                    
                    // Add pin button
                    let pinButton = UIButton(type: .system)
                    pinButton.setBackgroundImage(UIImage(named: "pin"), for: .normal)
                    pinButton.frame = CGRect(x: 10, y: 5, width: 17, height: 17)
                    pinButton.addTarget(self, action: #selector(pinButtonTapped), for: .touchUpInside)
                    customView.addSubview(pinButton)

                    // Add mute button
                    let muteButton = UIButton(type: .system)
                    muteButton.setBackgroundImage(UIImage(named: "mute"), for: .normal)
                    muteButton.frame = CGRect(x: 50, y: 5, width: 17, height: 17)
                    muteButton.addTarget(self, action: #selector(muteButtonTapped), for: .touchUpInside)
                    customView.addSubview(muteButton)

                    // Add block user button
                    let blockButton = UIButton(type: .system)
                    blockButton.setBackgroundImage(UIImage(named: "Block_USer"), for: .normal)
                    blockButton.frame = CGRect(x: 90, y: 5, width: 20, height: 20)
                    blockButton.addTarget(self, action: #selector(blockButtonTapped), for: .touchUpInside)
                    customView.addSubview(blockButton)
                    
                    // Make sure customView is not already added somewhere else
                    customView.removeFromSuperview()
                    
                    
                    let cellRect = cell.convert(cell.bounds, to: view)
                                    let cellCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)

                                    // Set customView's center to the cell's center
                                    customView.center = cellCenter
                    // Add the custom view to your view hierarchy
                    view.addSubview(customView)
                }
            }
        }
    }




    
    
        
        @objc func pinButtonTapped() {
           
             customView.isHidden = true
              actionbuttons_On = false // Assuming you want to reset this flag
            print("\n\n\nselected row is : \(selectedrow)")
            
            //if user already exist
            if pinned_contacts.contains(contacts[selectedrow].Username)
            {
                let selectedUsername = contacts[selectedrow].Username
                    
                pinned_contacts.removeAll { $0 == selectedUsername }
                tble.reloadData()
            }
            
            else{
                print("pinning : \(contacts[selectedrow].Username)")
            pinned_contacts.append(contacts[selectedrow].Username)
            }
            
            UserDefaults.standard.setValue(pinned_contacts, forKey: "pinnedUser")
            
            contacts = sortContactsByPinned(contacts: contacts, pinned: pinned_contacts)
            tble.reloadData()
        }
        
    func sortContactsByPinned(contacts: [User], pinned: [String]) -> [User] {
        
        let pinnedSet = Set(pinned)
        
        let sortedContacts = contacts.sorted { (user1, user2) -> Bool in
            let isUser1Pinned = pinnedSet.contains(user1.Username)
            let isUser2Pinned = pinnedSet.contains(user2.Username)
            
            // If both are pinned or both are not pinned, sort by username
            if isUser1Pinned == isUser2Pinned {
                return user1.Username < user2.Username
            } else {
                // If one is pinned and the other is not, sort by pinned status
                return isUser1Pinned
            }
        }
        
        return sortedContacts
    }
    
    
        @objc func muteButtonTapped() {
            customView.isHidden = true
             actionbuttons_On = false // Assuming you want to reset this flag
            
            if muted_contacts.contains(contacts[selectedrow].Username)
            {
                let selectedUsername = contacts[selectedrow].Username
                    
                muted_contacts.removeAll { $0 == selectedUsername }
                tble.reloadData()
            }
            else{
                muted_contacts.append(contacts[selectedrow].Username)
            }
            UserDefaults.standard.setValue(muted_contacts, forKey: "muttedUser")
            print("Mutted : \(muted_contacts)")
           
            tble.reloadData()
        }
        
    
    
        @objc func blockButtonTapped() {
            customView.isHidden = true
             actionbuttons_On = false // Assuming you want to reset this flag
            
            var shouldblock = false
            if contacts[selectedrow].IsBlocked == 0 {

                shouldblock = true
            }
            
            // Handle block button tap
            print("\(contacts[selectedrow].Fname) Block button tapped")
           
            var contactid = contacts[selectedrow].UserId
                 var userid = UserDefaults.standard.integer(forKey: "userID")
             let Url = "\(Constants.serverURL)/contacts/\(userid)/contacts/\(contactid)/block?is_blocked=\(shouldblock)"
             
             let requestBody = OnlineStatusRequestBody(online_status: 0)
            
             
             serverWrapper.putRequest(urlString: Url, requestBody: requestBody) { data, response, error in
                 if let error = error {
                         print("Error: \(error)")
                         return
                     }

                     guard let httpResponse = response as? HTTPURLResponse else {
                         print("Invalid HTTP response")
                         return
                     }

                     if httpResponse.statusCode == 200 {
                         if let responseData = data {
                            
                            let toastView = ToastView(message: "User Blocked successfully")
                            toastView.show(in: self.view)
                            
                            DispatchQueue.global().async {
                                print("Refreshing data")
                                    self.contacts = []
                                   self.fetchContactsData()
                            }
                         }
                     } else {
                         print("Request failed with status code \(httpResponse.statusCode)")
                     }
             }
            

            
           
        
           
        }
    
    
   
    func fetchContactsData() {
       
        guard let userID = self.logindefaults.string(forKey: "userID") else {
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
                self.contacts.append(user)
            }
        

        
        DispatchQueue.main.async {
            self.tble.dataSource = self
            self.tble.delegate = self
            //Sorting pinned contacts
            self.contacts = self.sortContactsByPinned(contacts: self.contacts, pinned: self.pinned_contacts)
            
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
        
        //To take orignallist
        if n < 1{
            print(" Copying orignal contacts")
            dumylist = contacts
            filteredContacts = contacts
             n += 1
        }
        
        
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
            cell.profilepic.kf.setImage(with: url, placeholder: UIImage(named: "No image found"))
            cell.profilepic?.layer.cornerRadius = 28
            cell.profilepic?.clipsToBounds = true
              }
                
      if let image = UIImage(named: "pin", in: Bundle.main, compatibleWith: nil) {
        if pinned_contacts.contains(contacts[indexPath.row].Username){
            print("username \(pinned_contacts) == \(contacts[indexPath.row].Username)")
            cell.pin?.image = image
                }
        else{
            cell.pin?.image = nil
                }
            }
        if let image = UIImage(named: "mute", in: Bundle.main, compatibleWith: nil) {
            if muted_contacts.contains(contacts[indexPath.row].Username){
            cell.mute?.image = image
                }
                else{
                cell.mute?.image = nil
                    }
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
                    
          if let image = UIImage(named: "pin", in: Bundle.main, compatibleWith: nil) {
            if pinned_contacts.contains(contacts[indexPath.row].Username){
                print("username \(pinned_contacts) == \(contacts[indexPath.row].Username)")
                cell.pin?.image = image
                    }
            else{
                cell.pin?.image = nil
                    }
                }
            if let image = UIImage(named: "mute", in: Bundle.main, compatibleWith: nil) {
                if muted_contacts.contains(contacts[indexPath.row].Username){
                cell.mute?.image = image
                    }
                    else{
                    cell.mute?.image = nil
                        }
                    }
        }
                return cell
      
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if   actionbuttons_On {
           
            actionbuttons_On = false
        }
        else{
       
        let cell = tble.cellForRow(at: indexPath)
               cell?.backgroundColor = .white
        
        let profilepic = contacts[indexPath.row].ProfilePicture
          
        let controller = self.storyboard?.instantiateViewController(identifier: "userdetails") as! UserProfileViewController
      
        
            controller.name = contacts[indexPath.row].Fname+" "+contacts[indexPath.row].Lname
            controller.about = contacts[indexPath.row].BioStatus
            controller.distype = contacts[indexPath.row].UserType
            controller.contactid = contacts[indexPath.row].UserId
        
            if contacts[indexPath.row].IsBlocked == 0 {
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
            //user is blocked
            else{
                controller.isblocked = 1
                controller.img = UIImage(named: "noprofile", in: Bundle.main, compatibleWith: nil)!
            }
          
        controller.modalPresentationStyle = .fullScreen
        //self.present(controller, animated: true, completion: nil)
        self.navigationController?.pushViewController(controller, animated: true)
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
    
  

}

extension ContactsViewController: UITextFieldDelegate {
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

extension Notification.Name {
    static let RefreshContacts = Notification.Name("RefreshContactsNotification")
}
