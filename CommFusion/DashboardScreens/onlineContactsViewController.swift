//
//  onlineContactsViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 06/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import Kingfisher


class onlineContactsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate  {
//    func presentIncomingCallScreen(isRecieving: Bool) {
//        print("\nrecieveing \(isRecieving)")
//        
//        
//    }
    

    
    
    
    @IBOutlet weak var protectview: UIView!
    @IBOutlet weak var circleview: UIView!
    var pinned_contacts = [String]()
    var muted_contacts = [String]()
    var longPressGesture: UILongPressGestureRecognizer!
    var longPressIndexPath: IndexPath?
    
    var logindefaults = UserDefaults.standard
    var serverWrapper = APIWrapper()
    
    var contacts = [User]()
    var filteredContacts = [User]()
    var dumylist = [User]()
    //used in scroll down refresh
    var isFunctionCalled = false
   
    @IBAction func addFriend(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(identifier: "addcontacts") 
        controller?.modalPresentationStyle = .fullScreen
        controller?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller!, animated: true)
        
    }
    
    @IBAction func btn_settings(_ sender: Any) {
    let controller = self.storyboard!.instantiateViewController(identifier: "settings")
        controller.modalPresentationStyle = .fullScreen
        controller.hidesBottomBarWhenPushed = true
      self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnplus(_ sender: Any) {
        if btncontactOutlet.isHidden {
            // If the button is hidden, animate showing the view
            UIView.animate(withDuration: 0, animations: {
               
                let screenWidth = UIScreen.main.bounds.width
                let screenHeight = UIScreen.main.bounds.height
                self.protectview.transform = CGAffineTransform(translationX: 0.8, y:0.8)

                self.protectview.transform = .identity // Reset transform
                self.protectview.alpha = 0.8 // Make view fully visible
            }) { (finished) in
                // After animation completion, show the button and view
                self.protectview.isHidden = false
                self.btncontactOutlet.isHidden = false
            }
        } else {
            // If the button is visible, animate hiding the view
            UIView.animate(withDuration: 0.5, animations: {
                // Gradually move the view back to its offscreen position
                let screenWidth = UIScreen.main.bounds.width
                let screenHeight = UIScreen.main.bounds.height
                self.protectview.transform = CGAffineTransform(translationX: screenWidth - self.protectview.frame.origin.x, y: screenHeight - self.protectview.frame.origin.y)
                self.protectview.alpha = 0.0 // Make view fully transparent
            }) { (finished) in
                // After animation completion, hide the button and view
                self.protectview.isHidden = true
                self.btncontactOutlet.isHidden = true
            }
        }

    }
 
    @IBOutlet weak var btncontactOutlet: UIButton!
    @IBAction func btncontact(_ sender: Any) {

        protectview.isHidden = true
        btncontactOutlet.isHidden = true
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
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("no of contacts are \(self.contacts.count)")
        if self.contacts.count>0{
            self.noFriendsLabel.isHidden = true
            
        }
        return self.contacts.count
    }
    
    var n = 0
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      
        
        let cell = tble.dequeueReusableCell(withIdentifier: "c1") as? ContactTableTableViewCell
       
        //To take orignallist
        if n < 1{
            print(" Copying orignal contacts")
            dumylist = contacts
            filteredContacts = contacts
             n += 1
        }
        
        guard indexPath.row < contacts.count else {
            print("Index out of bounds")
            return cell!
        }
       
        cell?.name.text = contacts[indexPath.row].Fname+" "+contacts[indexPath.row].Lname
        cell?.about.text = contacts[indexPath.row].BioStatus
       
        if let image = UIImage(named: "online", in: Bundle.main, compatibleWith: nil) {
            cell?.isActive?.image = image
                }
        
        cell?.call?.tag = indexPath.row
        cell?.call?.addTarget(self, action: #selector(btn_call(_:)), for: .touchUpInside)
        
        if let image = UIImage(named: "pin", in: Bundle.main, compatibleWith: nil) {
            
          if pinned_contacts.contains(contacts[indexPath.row].Username){
//              print("username \(pinned_contacts) == \(contacts[indexPath.row].Username)")
            
              cell?.pin?.image = image
                  }
          else{
              cell?.pin?.image = nil
                  }
              }
          if let image = UIImage(named: "mute", in: Bundle.main, compatibleWith: nil) {
              if muted_contacts.contains(contacts[indexPath.row].Username){
              cell?.mute?.image = image
                  }
                  else{
                  cell?.mute?.image = nil
                      }
                  }

        let base = "\(Constants.serverURL)\(contacts[indexPath.row].ProfilePicture)"

        if let url = URL(string: base) {
            // Attempt to load the image from the URL
            cell?.profilepic.kf.setImage(with: url, placeholder: UIImage(named: "No image found"), completionHandler: { result in
                switch result {
                case .success:
                    // Image loaded successfully, do nothing
                    break
                case .failure:
                    // Image loading failed, set placeholder image
                    let placeholderImage = UIImage(named: "noprofile", in: Bundle.main, compatibleWith: nil)
                    cell?.profilepic.image = placeholderImage
                    cell?.profilepic.layer.cornerRadius = 28
                    cell?.profilepic.clipsToBounds = true
                }
            })
            cell?.profilepic.layer.cornerRadius = 28
            cell?.profilepic.clipsToBounds = true
            
        }
        return cell!
             
}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if   actionbuttons_On {
           
            actionbuttons_On = false
        }
        else{
        let cell = tble.cellForRow(at: indexPath)
               cell?.backgroundColor = .white
        
        
        let controller = self.storyboard?.instantiateViewController(identifier: "userdetails") as! UserProfileViewController
      
        
        controller.name = contacts[indexPath.row].Fname+" "+contacts[indexPath.row].Lname
        controller.about = contacts[indexPath.row].BioStatus
        controller.distype = contacts[indexPath.row].UserType
        controller.contactid = contacts[indexPath.row].UserId
        controller.username = "@"+contacts[indexPath.row].Username
        let base = "\(Constants.serverURL)\(contacts[indexPath.row].ProfilePicture)"
        
        print("\nfor \(controller.name) \nProfilePic : \(base)")
        
        
        if contacts[indexPath.row].ProfilePicture != "" {
        
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
         }
           
        }
        else{
            controller.img =  UIImage(named: "noprofile", in: Bundle.main, compatibleWith: nil)!
            
        }
          
        controller.modalPresentationStyle = .fullScreen
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
            
           }
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
    
       
    func getOnlineStatus(status : Int)
   {
    
   
        var userid = UserDefaults.standard.integer(forKey: "userID")
    let Url = "\(Constants.serverURL)/user/\(userid)/online-status?online_status=\(status)"
    
    let requestBody = OnlineStatusRequestBody(online_status: 0)
   
    
    serverWrapper.putRequest(urlString: Url, requestBody: requestBody) { data, response, error in
        if let error = error {
                print("Error>>>>>> \(error)")
            self.noFriendsLabel.text = "Network Problem..."
            self.noFriendsLabel.isHidden = false
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                return
            }

            if httpResponse.statusCode == 200 {
                if let responseData = data {
                    // Parse JSON data
                    do {
                        let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
                        if let message = json?["message"] as? String, let id = json?["Id"] as? Int {
                            print("Message: \(message)")
                            print("ID: \(id)")
                        } else {
                            print("Invalid JSON format")
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                } else {
                    print("No data received from the server")
                }
            } else {
                print("Request failed with status code \(httpResponse.statusCode)")
            }
    }
   }
    
   
   

    override func viewDidLoad() {
        super.viewDidLoad()
  
        
        
        //MARK:-
        if socketsClass.shared.isConnected(){
            
        }
        else{
            socketsClass.shared.connectSocket()
        }
        btncontactOutlet.alpha = 1
        circleview.alpha = 1
        circleview.layer.cornerRadius = 44
        
        protectview.isHidden = true
        //for update list after block /unblock from user profile
        NotificationCenter.default.addObserver(self, selector: #selector(refreshContacts), name: .RefreshOnlineContacts, object: nil)

        //Setting Group Call not
         UserDefaults.standard.setValue("0", forKey:"groupchat")
        
        if let retrievedArray = UserDefaults.standard.array(forKey: "pinnedUser") as? [String] {
            pinned_contacts = retrievedArray
           
            
        }
        
        
        if let muttedArray = UserDefaults.standard.array(forKey: "muttedUser") as? [String] {
            let mutted_users = muttedArray
            muted_contacts = mutted_users
        }
        
        //Setting ASL by Default
        if UserDefaults.standard.object(forKey: "SignType") == nil {
            
            UserDefaults.standard.set("ASL", forKey: "SignType")
        }
        if UserDefaults.standard.object(forKey: "SignType") == nil {
            
            UserDefaults.standard.set("ASL", forKey: "SignType")
        }
        
        if UserDefaults.standard.object(forKey: "disability_Type") == nil {
            UserDefaults.standard.set("normal", forKey: "disabilityType")
            print("Setting disablity to normal")
        }
        else{
            print("user disablity is already setted : \( UserDefaults.standard.string(forKey: "disabilityType"))")
        }
        
        
        if UserDefaults.standard.object(forKey: "disability_Type") == nil {
            let setting =  settingsViewController()
            setting.fetchUserDisability()
            
            print("USer disablity is nil so : \(UserDefaults.standard.string(forKey: "disability_Type"))")
            
          
        }
        else{
            
            
            print("User disablity is : \(UserDefaults.standard.string(forKey: "disability_Type"))")
        }
            
            
            
        if UserDefaults.standard.object(forKey: "rigntones") == nil {
            UserDefaults.standard.setValue("default", forKey: "rigntones")
            
        }
        
        DispatchQueue.global().async {
               self.fetchContactsData()
            self.getOnlineStatus(status: 1)
           }
        btncontactOutlet.isHidden = true
        searchbtnSetup()
       
        addDoneButtonToKeyboard()
        for i in 0..<contacts.count {
            contacts.append(contacts[i])
        }
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tble.addGestureRecognizer(longPressGesture)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap(sender:)))
            // Make sure the recognizer doesn't cancel other touch events, like table view cell selections
            tapGestureRecognizer.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGestureRecognizer)
        
        
        
              
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown(_:)))
        swipeDown.direction = .down
             view.addGestureRecognizer(swipeDown)
        
        
        
                noFriendsLabel.text = "You don't have any friends yet."
                noFriendsLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
                noFriendsLabel.textColor = .gray
                noFriendsLabel.textAlignment = .center
                noFriendsLabel.numberOfLines = 0
                
                // Add the label to the view
                noFriendsLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(noFriendsLabel)
        
                
                // Center the label in the view
                NSLayoutConstraint.activate([
                    noFriendsLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    noFriendsLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                    noFriendsLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                    noFriendsLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
                ])
        
        setupSwipeGestures()
      }
    private func setupSwipeGestures() {
           let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
           rightSwipe.direction = .right
           self.view.addGestureRecognizer(rightSwipe)
           
           let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
           leftSwipe.direction = .left
           self.view.addGestureRecognizer(leftSwipe)
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
    
    let noFriendsLabel = UILabel()
    
    deinit {
            // Unsubscribe from the notification
            NotificationCenter.default.removeObserver(self, name: .openViewControllerNotification, object: nil)
        }

    @objc func swipedDown(_ gesture: UISwipeGestureRecognizer) {
           if gesture.direction == .down {
            //Displaying Refreshing
            showLoadingView()
            print("Refreshing online contacts...")
         DispatchQueue.global().async {
             print("Refreshing data")
                 self.contacts = []
                self.fetchContactsData()
                
         }
            
           }
       }
    
    func fetchContactsData() {
       
        guard let userID = self.logindefaults.string(forKey: "userID") else {
            print("User ID not found")
            return
        }
        
       
       
        let Url = "\(Constants.serverURL)/contacts/\(userID)/online-contacts"
        
      
        let url = URL(string: Url)!
        serverWrapper.fetchData(baseUrl: url, structure: [ContactsUser].self) { contactsUsers, error in
            if let error = error {
                print("Error-------", error.localizedDescription)
                
               
            } else if let jsonData = contactsUsers {
                DispatchQueue.main.async {
                    self.noFriendsLabel.isHidden = true
                }
                self.processContactsData(jsonData)
            } else {
                print("No data received from the server")
            }
        }
    
    }

    func processContactsData(_ jsonArray: [ContactsUser]) {
            for userObject in jsonArray {
                
                self.noFriendsLabel.isHidden = true
                
                let bioStatus = userObject.bio_status
                let onlineStatus = userObject.online_status
                let firstName = userObject.fname
                let lastName = userObject.lname
                let profilePicture = userObject.profile_picture
                let userid = userObject.user_id
                let isBlocked  = userObject.is_blocked
                let usernam = userObject.user_name
                let distype = userObject.disability

                
                if isBlocked != 1  {
                var user = User()
                user.BioStatus = bioStatus
                user.Fname = firstName
                user.Lname = lastName
                user.ProfilePicture = profilePicture
                user.OnlineStatus = onlineStatus
                user.UserId = userid
                user.IsBlocked = isBlocked
                user.Username = usernam
                user.UserType = distype
                self.contacts.append(user)
                }
            }
        

        
        DispatchQueue.main.async {
            self.tble.dataSource = self
            self.tble.delegate = self
            self.contacts = self.sortContactsByPinned(contacts: self.contacts, pinned: self.pinned_contacts)
            if self.contacts.count == 0 {
                
                self.noFriendsLabel.isHidden = false
                self.noFriendsLabel.text = "You don't have any online friends yet."
            }
            else{
                self.noFriendsLabel.isHidden = true
            }
            self.tble.reloadData()
        }
    }
    

    
//    MARK:-
    
    //  MARK:-
  
  
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
//                  customView.addSubview(muteButton)

                  // Add block user button
                  let blockButton = UIButton(type: .system)
                  blockButton.setBackgroundImage(UIImage(named: "Block_USer"), for: .normal)
                  blockButton.frame = CGRect(x: 90, y: 5, width: 20, height: 20)
                  blockButton.addTarget(self, action: #selector(blockButtonTapped), for: .touchUpInside)
                  customView.addSubview(blockButton)
                  
                  // Make sure customView is not already added somewhere else
//                  customView.removeFromSuperview()
                  
                  
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
        
            customView.removeFromSuperview()
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
        
        for user in pinned_contacts{
            print("Pined username : \(user)")
        }
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
        customView.removeFromSuperview()
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
        customView.removeFromSuperview()
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
                       print("Error++++++ \(error)")
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
  
    var loadingView: UIView!
    var activityIndicator: UIActivityIndicatorView!
    var loadingLabel: UILabel!
    
    func showLoadingView() {
        setupLoading()
        view.addSubview(loadingView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.hideLoadingView()
                    }
    }
    
    // Function to hide loading view
    func hideLoadingView() {
        loadingView.removeFromSuperview()
    }
    func setupLoading(){
        // Create loading view
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 100))
        loadingView.center = view.center
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        view.addSubview(loadingView)
        
        // Add activity indicator
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 3)
        loadingView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // Add loading label
        loadingLabel = UILabel(frame: CGRect(x: 0, y: activityIndicator.frame.origin.y + activityIndicator.frame.size.height + 10, width: loadingView.frame.size.width, height: 20))
        loadingLabel.text = "Refreshing..."
        loadingLabel.textColor = UIColor.white
        loadingLabel.textAlignment = .center
        loadingLabel.font = UIFont.systemFont(ofSize: 16)
        loadingView.addSubview(loadingLabel)
        
        // Rotate animation for the activity indicator
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2.0)
        rotateAnimation.duration = 1.0
        rotateAnimation.repeatCount = .infinity
        activityIndicator.layer.add(rotateAnimation, forKey: nil)
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
    
    @objc func refreshContacts() {
           print("Refreshing online contacts...")
        showLoadingView()
        DispatchQueue.global().async {
            print("Refreshing data")
                self.contacts = []
               self.fetchContactsData()
        }
       }
   
}
extension Notification.Name {
    static let RefreshOnlineContacts = Notification.Name("RefreshContactsNotification")
}
extension onlineContactsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -100 && !isFunctionCalled {
            isFunctionCalled = true
            
            refreshContacts()
           
                       
           
        } else if scrollView.contentOffset.y >= -100 && isFunctionCalled {
            isFunctionCalled = false
        }
        
        
    }
}
