//
//  AddContactViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 07/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import Kingfisher

class AddContactViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate{
    
    var logindefaults = UserDefaults.standard
    var serverWrapper = APIWrapper()
    
    var userID = ""
    
    var contacts = [User]()
    
    @IBAction func btnback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        userID = self.logindefaults.string(forKey: "userID")!
        super.viewDidLoad()
        
        txtsearch.frame = CGRect(x: txtsearch.frame.origin.x,
                                y: txtsearch.frame.origin.y,
                                width: txtsearch.frame.size.width,
                                height: 80)
        txtsearch.layer.borderWidth = 1.0
        txtsearch.layer.borderColor = UIColor.gray.cgColor
        txtsearch.layer.cornerRadius = 27
        
        // Do any additional setup after loading the view.
        let tapscreen = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapscreen.delegate = self
                self.view.addGestureRecognizer(tapscreen)
     
    
    }
    @objc func hideKeyboard() {
            self.view.endEditing(true)
        }
    
    @IBAction func btnSearch(_ sender: Any) {
        //on again click
        showLoadingView()
        
        contacts.removeAll()
        self.tble.reloadData()
      
        if self.rdemail.isSelected {
            // Encode the email address to handle special characters such as spaces
            if let searchText = self.txtsearch.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                let urlString = "\(Constants.serverURL)/user/search?user_id=\(userID)&search_Email=\(searchText)"
                self.fetchContactsData(Url: urlString)
                print("Entered in Email Selected: \(searchText)")
            }
        }

        if self.rdusername.isSelected {
            if let searchText = self.txtsearch.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                let urlString = "\(Constants.serverURL)/user/search?user_id=\(userID)&search_username=\(searchText)"
                self.fetchContactsData(Url: urlString)
                print("Entered in username Selected: \(searchText)")
            }
        }

           
    }
    func fetchContactsData(Url : String) {
        
       
        if self.rdemail.isSelected{
            print("Entered in Email Selected")
           
        }
        if self.rdusername.isSelected{
            print("Entered in username Selected")
           
        }
        let url = URL(string: Url)!
       
        serverWrapper.fetchDatatoAddContact(baseUrl: url, structure: addUser.self) { addUser, error in
            
            if let error = error {
                print("URL: \(Url)")
                print("Error in recieving :", error.localizedDescription)
                self.hideLoadingView()
               
            } else if let jsonData = addUser {
                print("JSON Data:", jsonData)
               
                self.processContactsData(jsonData)
            } else {
                print("No data received from the server")
            }
        }
    
    }

    var user = User()
    
    func processContactsData(_ userObject: addUser) {
            
                if userObject.account_status != "Active"{
                    
                }
                else{
                    
                    user.BioStatus  = userObject.bio_status
                    user.Fname = userObject.fname
                    user.Lname = userObject.lname
                    user.ProfilePicture = userObject.profile_picture
                    user.isfriend = userObject.is_friend
                    user.UserId = userObject.user_id
               
                self.contacts.append(user)
                }
            

        
        DispatchQueue.main.async {
            self.hideLoadingView()
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
        cell?.about.text = contacts[indexPath.row].BioStatus
        cell?.btnadd.tag = contacts[indexPath.row].UserId
        cell?.btnadd.addTarget(self, action: #selector(AddFriend(_:)), for: .touchUpInside)
        if user.isfriend {
            cell?.btnadd.setBackgroundImage(UIImage(named: "freind_Added"), for: .normal)
        }
        
        let base = "\(Constants.serverURL)\(contacts[indexPath.row].ProfilePicture)"
        print("\n url is: \(base)")
        if let url = URL(string: base) {
            cell?.profilePic?.kf.setImage(with: url, placeholder: UIImage(named: "No image found"))
            
            cell?.profilePic?.layer.cornerRadius = 25
            cell?.profilePic?.clipsToBounds = true
        }
                
        return cell!
    }
   //Send Request
    @objc func AddFriend(_ sender:UIButton) {
       
        let Url = "\(Constants.serverURL)/contacts/add"
 
        let Dic: [String: Any] = [
            "user_id": Int(userID)!,
            "contact_id": user.UserId,
            "is_blocked" : 0
        ]
        print(Dic)
        serverWrapper.insertData(baseUrl: Url,  userDictionary: Dic) { [self] responseString, error in
            if let error = error {
                print("\n\nError:", error)
               
            } else {
                if let responseString = responseString {
                    print("login Server response:", responseString)
                    
                    do {
                        if let responseData = responseString.data(using: .utf8) {
                            do {
                                let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: [])
                                print("Server Message: \(jsonObject)")
                                
                                if let cell = tble.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddFriendTableViewCell {
                                       
                                cell.btnadd.setBackgroundImage(UIImage(named: "freind_Added"), for: .normal)
                                
                                }
                            }
                            
                            }

                    } catch {
                        print("Error parsing JSON data: \(error)")
                    }
                }
                
               
            }
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
