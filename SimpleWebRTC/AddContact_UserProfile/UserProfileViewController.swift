import Kingfisher
import UIKit




class UserProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
    //notifcation for update contacts
    func actionThatRequiresRefresh() {
           print("Calling for refresh contacts")
            NotificationCenter.default.post(name: .RefreshContacts, object: nil)
            
       }
   
    
    var logindefaults = UserDefaults.standard
    var serverWrapper = APIWrapper()

    var contacts = [User]()
    var filteredContacts = [User]()
    var dumylist = [User]()
    
    
    @IBOutlet weak var tble: UITableView!
    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    @IBOutlet weak var profilepic: UIImageView!
    @IBOutlet weak var disabilityImg: UIImageView!
    @IBOutlet weak var lblabout: UILabel!
    @IBOutlet weak var btn_block: UIButton!
    
    @IBAction func btncall(_ sender: Any) {
        
           let controller = self.storyboard?.instantiateViewController(identifier: "callerscreen") //as! CallerViewController
//        controller.name =  lblname.text!
//        controller.isringing = "Calling"
//        controller.profilepic = profilepic.image!
        controller?.modalPresentationStyle = .fullScreen
        controller?.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    @IBAction func btnBlock(_ sender: Any) {
        if isblocked == 1 {
            //unblocking user
            
            blockuser(shouldblock: false)
            
        }
        else{
            //blocking user
            
            blockuser(shouldblock: true)
            

        }
    }
    func blockuser(shouldblock : Bool)
    {
        var contactid = self.contactid
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
                        //ublocking user
                        if shouldblock == false {
                            self.isblocked = 0
                            self.btn_block.setBackgroundImage(UIImage(named: "Block_USer"), for: .normal)
                            let toastView = ToastView(message: "User Unblocked successfully")
                            toastView.show(in: self.view)
                            
                           

                        }
                        else{
                            
                            self.isblocked = 1
                            self.profilepic.image =  UIImage(named: "noprofile", in: Bundle.main, compatibleWith: nil)!
                            self.btn_block.setBackgroundImage(UIImage(named: "unblock_user"), for: .normal)

                            // Set the content mode for the button's image view
                            self.btn_block.imageView?.contentMode = .scaleAspectFit

                            // Adjust the frame size for the button
                            let buttonWidth: CGFloat = 17 // Example width
                            let buttonHeight: CGFloat = 17 // Example height
                            self.btn_block.frame = CGRect(x: self.btn_block.frame.origin.x, y: self.btn_block.frame.origin.y, width: buttonWidth, height: buttonHeight)
                            let toastView = ToastView(message: "User Blocked successfully")
                            toastView.show(in: self.view)
                        }
                        //Refreshing contact list
                        self.actionThatRequiresRefresh()
                     }
                 } else {
                     print("Request failed with status code \(httpResponse.statusCode)")
                 }
         }
    }
    var name = " "
    var username = " "
    var about = " "
    var distype = " "
    var contactid = 0
    var contactidofprofile = 0
    var isblocked = 0
    var img = UIImage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblname.text = name
        lblUsername.text = username
        lblUsername.isUserInteractionEnabled = true
        lblabout.text = about
        profilepic.image = img
        profilepic.layer.cornerRadius = 30
        contactidofprofile = contactid
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
        lblUsername.addGestureRecognizer(tapGesture)
               
        
        if isblocked == 1 {
           
            btn_block.setBackgroundImage(UIImage(named: "unblock_user"), for: .normal)

            // Set the content mode for the button's image view
            btn_block.imageView?.contentMode = .scaleAspectFit

            // Adjust the frame size for the button
            let buttonWidth: CGFloat = 17 // Example width
            let buttonHeight: CGFloat = 17 // Example height
            btn_block.frame = CGRect(x: btn_block.frame.origin.x, y: btn_block.frame.origin.y, width: buttonWidth, height: buttonHeight)

            profilepic.image =  UIImage(named: "noprofile", in: Bundle.main, compatibleWith: nil)!
            
            
        }
        
        if distype == "Deaf and Mute"
        {
            if let image = UIImage(named: "deff", in: Bundle.main, compatibleWith: nil) {
                disabilityImg.image = image
                    }
            
        }
        else if distype == "Blind"
        {
            if let image = UIImage(named: "blind", in: Bundle.main, compatibleWith: nil) {
                disabilityImg.image = image
                    }
        }
        else{
            if let image = UIImage(named: "normalperson", in: Bundle.main, compatibleWith: nil) {
                disabilityImg.image = image
                    }
        }
        
        DispatchQueue.global().async {
               self.fetchCallHistory()
        }
        
    }
    
    func fetchCallHistory() {
       
        guard let userID = self.logindefaults.string(forKey: "userID") else {
            print("User ID not found")
            return
        }
        
        let Url = "\(Constants.serverURL)/videocallparticipants/\(userID)/calls/\(contactidofprofile)"
        print("URL in contact call history : "+Url)
      
        let url = URL(string: Url)!
        serverWrapper.fetchData(baseUrl: url, structure: [CallLogs].self) { UserCallHistory, error in
            if let error = error {
                print("Error:", error.localizedDescription)
               
            } else if let jsonData = UserCallHistory {
                print("JSON Data:", jsonData)
               
                self.processContactsData(jsonData)
            } else {
                print("No data received from the server")
            }
        }
    
    }

    
    func processContactsData(_ jsonArray: [CallLogs]) {
            for userObject in jsonArray {
                
                let call_id = userObject.VideoCallId
                let onlineStatus = userObject.OnlineStatus
                let firstName = userObject.OtherParticipantFname
                let lastName = userObject.OtherParticipantLname
                let profilePicture = userObject.ProfilePicture
                let iscaller = userObject.isCaller
                let startTime = userObject.StartTime
                let endTime = userObject.EndTime

                // Now you can use these properties as needed
                print("Call id : \(call_id), Fname: \(firstName), OnlineStatus: \(onlineStatus), IScaller: \(iscaller), ProfilePic: \(profilePicture)")

            
                
                // Optionally, you can create a User object and append it to contacts array
                var user = User()
                user.CallId = call_id
                user.Fname = firstName
                user.Lname = lastName
                user.ProfilePicture = profilePicture
                user.OnlineStatus = onlineStatus
                user.isCaller = iscaller
                user.Call_StartTime = startTime
                user.Call_EndTime = endTime
                self.contacts.append(user)
            }
        

        
        DispatchQueue.main.async {
            self.tble.dataSource = self
            self.tble.delegate = self
            self.tble.reloadData()
        }
    
}
    
    func callStatusCheck(iscaller: Int, ismissed: Int) -> UIImage {
        var imageName = ""
        var tintColor: UIColor = .blue // Default tint color

        if iscaller == 0 {
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
        return 90
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
        
        cell?.callStatus.image = callStatusCheck(iscaller: contacts[indexPath.row].isCaller,ismissed: 0)
       
        
        
        if contacts[indexPath.row].OnlineStatus == 1{
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
        
        if isblocked == 0 {
        cell?.call.tag = indexPath.row
        cell?.call.addTarget(self, action: #selector(btn_call(_:)), for: .touchUpInside)
        
        }
        //user is blocked
        else{
            
            cell?.call.setBackgroundImage(nil, for: .normal)
            cell?.isActive?.image = nil
           
            }
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
        
       let controller = self.storyboard!.instantiateViewController(identifier: "CallTranscriptionScreen")
        controller.modalPresentationStyle = .fullScreen
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
        
   
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
                let placeholderImage = UIImage(named: "noprofile", in: Bundle.main, compatibleWith: nil)
                controller.profilepic = placeholderImage!
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
    
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
            if let label = sender.view as? UILabel {
                // Remove "@" from username
                var username = lblUsername.text ?? ""
                username = username.replacingOccurrences(of: "@", with: "")
                
                // Copy modified username to clipboard
                UIPasteboard.general.string = username
                lblUsername.text = "Username copied"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.lblUsername.text = self.username // Reset the label's text
                }
            }
        }
    
    
}

