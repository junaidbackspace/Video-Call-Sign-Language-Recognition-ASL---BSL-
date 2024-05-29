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

    func callStatusCheck(iscaller: Int, ismissed: Int) -> UIImage {
        var imageName = ""
        var tintColor: UIColor = .blue // Default tint color

        if iscaller != 0 {
            print("\n\nin red color")
            imageName = "arrow.up.backward"
            tintColor = .red
        } else {
            print("\n\nin Green color")
            imageName = "arrow.down.right"
            tintColor = .green
        }

        guard let image = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate) else {
            print("Error: Unable to load system image named \(imageName)")
            return UIImage()
        }

        return image.withTintColor(tintColor)
    }


    
 

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("no of calls are \(self.contacts.count)")
        return self.contacts.count
    }
    
    
    var n = 0
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tble.dequeueReusableCell(withIdentifier: "c11") as? CallLogsTableTableViewCell
        
        //To take orignallist
        if n < 1{
            print(" Copying orignal Callers")
            dumylist = contacts
            filteredContacts = contacts
             n += 1
        }
        
       
        
        cell?.name.text = contacts[indexPath.row].Fname+" "+contacts[indexPath.row].Lname
        
        cell?.callStatus.image = callStatusCheck(iscaller: contacts[indexPath.row].isCaller,ismissed: 0)
       
        
        
        if contacts[indexPath.row].OnlineStatus == 1{
        if let image = UIImage(named: "online", in: Bundle.main, compatibleWith: nil) {
            cell?.isActive?.image = image
                }
        }
        
        
        
        cell?.callTime.text = contacts[indexPath.row].Call_StartTime
        
        if let image = UIImage(named: "online", in: Bundle.main, compatibleWith: nil) {
            cell?.isActive?.image = image
                }
        
        cell?.call.tag = indexPath.row
        cell?.call.addTarget(self, action: #selector(btn_call(_:)), for: .touchUpInside)
        
        
        let base = "\(Constants.serverURL)\(contacts[indexPath.row].ProfilePicture)"
        
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
        controller.about = contacts[indexPath.row].BioStatus
        controller.distype = contacts[indexPath.row].UserType
        controller.contactid = contacts[indexPath.row].UserId
        controller.username = "@"+contacts[indexPath.row].Username
        
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
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
           
    @objc func btn_call(_ sender:UIButton)
    {
        
        let controller = self.storyboard?.instantiateViewController(identifier: "callerscreen") as! CallerViewController
    controller.name =  contacts[sender.tag].Fname+" "+contacts[sender.tag].Lname
    controller.isringing = "Calling"
        controller.recieverid = contacts[sender.tag].UserId
        controller.callerid =  UserDefaults.standard.integer(forKey: "userID")
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
               
    @objc func swipedDown(_ gesture: UISwipeGestureRecognizer) {
           if gesture.direction == .down {
            //Displaying Refreshing
            showLoadingView()
            print("Refreshing online contacts...")
         DispatchQueue.global().async {
             
                 self.contacts = []
                self.fetchCallHistory()
                
         }
            
           }
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown(_:)))
        swipeDown.direction = .down
             view.addGestureRecognizer(swipeDown)
        
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.showLoadingView()
            }
            self.fetchCallHistory()
        }
        
        searchbtnSetup()
       
        addDoneButtonToKeyboard()
        for i in 0..<contacts.count {
            contacts.append(contacts[i])
        }
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
              rightSwipe.direction = .right
              self.view.addGestureRecognizer(rightSwipe)
              
              // Add left swipe gesture recognizer
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

    
    func fetchCallHistory() {
       
        guard let userID = self.logindefaults.string(forKey: "userID") else {
            print("User ID not found")
            return
        }
        
        let Url = "\(Constants.serverURL)/videocallparticipants/\(userID)/calls"
        
      
        let url = URL(string: Url)!
        serverWrapper.fetchData(baseUrl: url, structure: [CallLogs].self) { UserCallHistory, error in
            if let error = error {
                print("Call History Error:", error.localizedDescription)
                self.hideLoadingView()
               
            } else if let jsonData = UserCallHistory {
                
                self.hideLoadingView()
                self.processContactsData(jsonData)
            } else {
                self.hideLoadingView() 
                print("No data received from the server")
            }
        }
    
    }

    
    func processContactsData(_ jsonArray: [CallLogs]) {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.timeZone = TimeZone(abbreviation: "UTC")

        // Date Formatter to output the user-friendly date strings
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        outputFormatter.timeZone = TimeZone.current
        
            for userObject in jsonArray {
                
                let call_id = userObject.VideoCallId
                let onlineStatus = userObject.OnlineStatus
                let firstName = userObject.OtherParticipantFname
                let lastName = userObject.OtherParticipantLname
                let profilePicture = userObject.ProfilePicture
                let iscaller = userObject.isCaller
               
                let userid = userObject.user_id
                let username = userObject.user_name
                var  start_Time = ""
                var  end_Time = ""
                if let startTime = inputFormatter.date(from: userObject.StartTime){
                   
                    let startUserFriendlyString = outputFormatter.string(from: startTime)
                    
                    
                     start_Time = startUserFriendlyString
//                     end_Time = startUserFriendlyString
                    
//                    print("End Time: \(startUserFriendlyString)")
                } else {
                    let inputFormatter = DateFormatter()
                    inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                    inputFormatter.timeZone = TimeZone(abbreviation: "UTC")
                    if let startTime = inputFormatter.date(from: userObject.StartTime){
                       
                        let startUserFriendlyString = outputFormatter.string(from: startTime)
                         start_Time = startUserFriendlyString
                    
                    }
                   
                }

                
                
                // Optionally, you can create a User object and append it to contacts array
                var user = User()
                user.CallId = call_id
                user.Fname = firstName
                user.Lname = lastName
                user.ProfilePicture = profilePicture
                user.OnlineStatus = onlineStatus
                user.isCaller = iscaller
                user.Call_StartTime = start_Time
               
                if let endtime = user.Call_EndTime {
                    
                    user.Call_EndTime = endtime
                }

                else{
                    user.Call_EndTime = "not ended"
                }
                user.UserId = userid
                user.Username = username
                self.contacts.append(user)
            }
        

        
        DispatchQueue.main.async {
            self.tble.dataSource = self
            self.tble.delegate = self
            self.tble.reloadData()
        }
    }
    var loadingView: UIView!
    var activityIndicator: UIActivityIndicatorView!
    var loadingLabel: UILabel!
    
    func showLoadingView() {
        setupLoading()
        view.addSubview(loadingView)
     
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
        loadingLabel.text = "Please Wait..."
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
