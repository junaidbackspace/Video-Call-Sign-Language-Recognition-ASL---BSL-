//
//  GeneralSettingsViewController.swift
//  SimpleWebRTC
//
//  Created by Umer Farooq on 13/02/2024.
//  Copyright © 2024 n0. All rights reserved.
//

import UIKit
import DropDown
class GeneralSettingsViewController: UIViewController, UIColorPickerViewControllerDelegate {
    
    @IBOutlet weak var colorPickerButton: UIButton!
    @IBOutlet weak var viewcolorPicker: UIView!
    @IBOutlet weak var lblColorPicker: UILabel!
    @IBOutlet weak var lblsize: UILabel!
    @IBOutlet weak var lblCap_opacity: UILabel!
    @IBOutlet weak var slider: UISlider!
      
    let font_sizeDefault = UserDefaults.standard
    let font_colorDefault = UserDefaults.standard
    let caption_opacityDefault = UserDefaults.standard
    
    
    
    
    @IBAction func btnback(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
            // Retrieve the value of the slider
        sliderupdate(value: sender.value)
        }
    func sliderupdate(value : Float)
    {
        var sliderValue = value
       
        lblCap_opacity.text = String(Int(Float(sliderValue)*100))+"%"
        caption_opacityDefault.setValue(Float(sliderValue), forKey: "caption")
        lblCap_opacity.alpha = CGFloat(Float(sliderValue))
    }
    
    @IBAction func pickColor(_ sender: Any) {
            let colorPicker = UIColorPickerViewController()
            colorPicker.delegate = self
            present(colorPicker, animated: true, completion: nil)
        }
        
        // Method to handle color selection
        func didSelectColor(_ color: UIColor) {
            
            viewcolorPicker.backgroundColor = color
            lblColorPicker.text = color.accessibilityName
            UserDefaults.standard.setColor(color, forKey: "color")
        }
    
  
//    @IBOutlet weak var languagePickerView: UIPickerView!
//
//        let languages = ["English", "Spanish", "French", "German", "Urdu"]
//
    
        override func viewDidLoad() {
            super.viewDidLoad()
            size = font_sizeDefault.integer(forKey: "fontsize")
            let currentFontSize = lblsize.font.pointSize
            lblsize.font = lblsize.font.withSize(currentFontSize+CGFloat(size))
            
            if let retrievedColor = UserDefaults.standard.color(forKey: "color") {
                lblColorPicker.text = retrievedColor.accessibilityName
                viewcolorPicker.backgroundColor = retrievedColor
            } else {
                print("No color found for key")
            }
            
            let opacity = font_colorDefault.float(forKey: "caption")
            lblCap_opacity.alpha = CGFloat(opacity)
            sliderupdate(value: opacity)
            slider.value = opacity
//            languagePickerView.delegate = self
//            languagePickerView.dataSource = self
        }
    
    func changelblSize( lbl: UILabel)
    {
        
            let currentFontSize = lbl.font.pointSize
            lbl.font = lbl.font.withSize(currentFontSize+CGFloat(size))
       
    }
    
    
   
   
    

   var size = 0
    @IBAction func btnMinus(_ sender: Any) {
        size = font_sizeDefault.integer(forKey: "fontsize")
        
              if  size > 0
              {
                size = size - 2
                font_sizeDefault.setValue(size, forKey: "fontsize")
              changelblSize(size: size, lbl: lblsize, increase: false)
              }
              
               
                
    }
    @IBAction func btnPlus(_ sender: Any) {
        size = font_sizeDefault.integer(forKey: "fontsize")
        if size < 15 {
        size = size + 2
        font_sizeDefault.setValue(size, forKey: "fontsize")
        
        changelblSize(size: size, lbl: lblsize, increase: true)
        }
        
           
    }
    
    @IBAction func btnDeleteAccount(_ sender: Any) {
        print(font_sizeDefault.integer(forKey: "fontsize"))
        print(caption_opacityDefault.float(forKey: "caption"))
        if let retrievedColor = UserDefaults.standard.color(forKey: "color") {
            print(retrievedColor.accessibilityName)
           
        }
        
    }
    
    func changelblSize(size: Int, lbl: UILabel, increase : Bool)
    {
        if increase{
            let currentFontSize = lbl.font.pointSize
            lbl.font = lbl.font.withSize(currentFontSize+CGFloat(2))
            }
        else{
            let currentFontSize = lbl.font.pointSize
            lbl.font = lbl.font.withSize(currentFontSize-CGFloat(2))
            }
        
    }
    
    
    
        
        // UIPickerViewDelegate method to handle language selection
//        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//            let selectedLanguage = languages[row]
//
//            switch selectedLanguage {
//                case "English":
//                    setAppLanguage("en")
//                case "Spanish":
//                    setAppLanguage("es")
//                case "French":
//                    setAppLanguage("fr")
//                case "German":
//                    setAppLanguage("de")
//                case "Urdu":
//                    setAppLanguage("ur")
//                default:
//                    break
//                }
//        }
//
//        // Function to set the app's language preference
//    func setAppLanguage(_ languageCode: String) {
//        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
//        UserDefaults.standard.synchronize()
//
//        // Reload the root view controller
//
//        guard let window = UIApplication.shared.windows.first else { return }
//
//        let initialViewController = self.storyboard?.instantiateViewController(withIdentifier: "firstscreen")
//        window.rootViewController = initialViewController
//    }
//
//
//        // UIPickerViewDataSource methods
//        func numberOfComponents(in pickerView: UIPickerView) -> Int {
//            return 1
//        }
//
//        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//            return languages.count
//        }
//
//        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//            return languages[row]
//        }
}
extension GeneralSettingsViewController {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        didSelectColor(viewController.selectedColor)
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension UserDefaults {
    func setColor(_ color: UIColor?, forKey key: String) {
        guard let color = color else {
            set(nil, forKey: key)
            return
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: color)
        set(data, forKey: key)
    }
    
    func color(forKey key: String) -> UIColor? {
        guard let data = data(forKey: key) else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? UIColor
    }
}
