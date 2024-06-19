import UIKit

struct TrainResponse: Codable {
    let message: String
    let logs: [String]
}

class UploadCapturedImageViewController: UIViewController {
    
    var serverwrapper = APIWrapper()
    var images: [UIImage] = []
    var imageUrls: [URL] = []
    var textField: UITextField?
    var bottomConstraint: NSLayoutConstraint?
    var progressView: UIProgressView!
    var timer: Timer?
    
    var signstext : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let customSigns = UserDefaults.standard.stringArray(forKey: "customsigns")
        {
            signstext = customSigns
        }
        // Save images to disk and generate URLs
        imageUrls = saveImagesToDisk(images: images)
        
        // Set background color
        view.backgroundColor = .white
        
        // Display captured images in a scroll view
        displayCapturedImages()
        addBackButton()
        addUploadButton()
        addDoneButtonToKeyboard(for: textField!)
        setupProgressView()
        
        // Add notification observer for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Keyboard Handling
    
    func addDoneButtonToKeyboard(for textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .close, target: textField, action: #selector(UIResponder.resignFirstResponder))
        toolbar.items = [doneButton]
        
        textField.inputAccessoryView = toolbar
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        let keyboardHeight = keyboardFrame.size.height
        
        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y = -keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y = 0
        }
    }
    
    // MARK: - UI Setup
    
    func addBackButton() {
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    func displayCapturedImages() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        for image in images {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalToConstant: 500).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 500).isActive = true
            stackView.addArrangedSubview(imageView)
        }
    }
    
    func addUploadButton() {
        let uploadButton = UIButton(type: .system)
        uploadButton.setTitle("Upload", for: .normal)
        uploadButton.backgroundColor = .blue
        uploadButton.setTitleColor(.white, for: .normal)
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(uploadButton)
        
        let textField = UITextField()
        textField.placeholder = "Enter text"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        self.textField = textField
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textField.bottomAnchor.constraint(equalTo: uploadButton.topAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 40),
            
            uploadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uploadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            uploadButton.widthAnchor.constraint(equalToConstant: 200),
            uploadButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func uploadButtonTapped() {
        guard let text = textField?.text, !text.isEmpty else {
            print("Text field is nil or empty")
            textField?.layer.borderColor = UIColor.red.cgColor
            textField?.layer.borderWidth = 1.0
            return
        }
        
       // adding in custom signs Array
        signstext.append(text)
        // Reset text field border if valid text is entered
        textField?.layer.borderColor = nil
        textField?.layer.borderWidth = 0.0
        
        progressView.isHidden = false
        progressView.progress = 0.0
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        
        let userid = String(UserDefaults.standard.integer(forKey: "userID"))
        serverwrapper.uploadCustom_SignsImages(user: userid, label: text, images: imageUrls) { result in
            switch result {
            case .success(let response):
                print("Success: \(response.message)")
                print("Logs: \(response.logs.joined(separator: "\n"))")
                DispatchQueue.main.async {
                    self.showSuccessAlert(message: "Model Trained Successfully")
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    
    func showSuccessAlert(message: String) {
        
        UserDefaults.standard.setValue(signstext, forKey: "customsigns")
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigateBack()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func navigateBack() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func saveImagesToDisk(images: [UIImage]) -> [URL] {
        var urls: [URL] = []
        for (index, image) in images.enumerated() {
            if let url = saveImageToTemporaryDirectory(image: image, index: index) {
                urls.append(url)
            }
        }
        return urls
    }
    
    func saveImageToTemporaryDirectory(image: UIImage, index: Int) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "captured_image_\(index).jpg"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        guard let imageData = image.fixOrientation().jpegData(compressionQuality: 1.0) else {
            return nil
        }
        
        do {
            try imageData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image to disk:", error)
            return nil
        }
    }

    var colors = ["a","b","c","d","e","f"]
    @objc func updateProgress() {
        if progressView.progress >= 1.0 {
            progressView.progress = 1.0
            timer?.invalidate()
            timer = nil
            
            let color =  colors.randomElement()
            if color == "a"{
                progressView.tintColor = UIColor.magenta
            }
            if color == "b"{
                progressView.tintColor = UIColor.purple
            }
            if color == "c"
            {
                progressView.tintColor = UIColor.yellow
            }
            if color == "d"
            {
                progressView.tintColor = UIColor.orange
            }
            if color == "e"
            {
                progressView.tintColor = UIColor.systemPink
            }
            else {
                progressView.tintColor = UIColor.cyan
            }
            progressView.progress = 0.0
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
            // Optionally dismiss progress view here
        } else {
            progressView.progress += 0.1 / (1 * 30) // 30 sec
        }
    }
    
    func setupProgressView() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.tintColor = UIColor.green
        progressView.isHidden = true
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 250),
            progressView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
        case .up, .upMirrored:
            break // Already in the correct orientation
        @unknown default:
            break
        }
        
        if let cgImage = self.cgImage,
            let colorSpace = cgImage.colorSpace,
            let context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
                                    bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0,
                                    space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue) {
            context.concatenate(transform)
            switch self.imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
            default:
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
            }
            
            if let fixedCGImage = context.makeImage() {
                return UIImage(cgImage: fixedCGImage)
            } else {
                return self
            }
        } else {
            return self
        }
    }
}
