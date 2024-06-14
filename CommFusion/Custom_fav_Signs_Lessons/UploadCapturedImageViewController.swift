import UIKit


class UploadCapturedImageViewController: UIViewController {
    
    var images: [UIImage] = []
    var textField: UITextField?
    var bottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let modelManager = SignLanguageModelManager(modelFileName: "DeepLabV3")
        
        // Set background color
        view.backgroundColor = .white
        
        // Display captured images in a scroll view
        displayCapturedImages()
        addBackButton()
        // Add upload button
        addUploadButton()
        addDoneButtonToKeyboard(for: textField!)
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
        // Your implementation for displaying images
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
               stackView.spacing = 5 // Adjust spacing between images
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
                   imageView.heightAnchor.constraint(equalToConstant: 500).isActive = true // Adjust image height
                   imageView.widthAnchor.constraint(equalToConstant: 500).isActive = true // Adjust image width
                   stackView.addArrangedSubview(imageView)
               }
    }
    
    func addUploadButton() {
        let uploadButton = UIButton(type: .system)
        uploadButton.setTitle("Upload", for: .normal)
        uploadButton.backgroundColor = .blue
        uploadButton.setTitleColor(.white, for: .normal) // Set text color to white
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(uploadButton)
        
        // Add text field
        let textField = UITextField()
        textField.placeholder = "Enter text"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        self.textField = textField
        
        // Constraints
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textField.bottomAnchor.constraint(equalTo: uploadButton.topAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 40), // Adjust height as needed
            
            uploadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uploadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            uploadButton.widthAnchor.constraint(equalToConstant: 200), // Set width as needed
            uploadButton.heightAnchor.constraint(equalToConstant: 50) // Set height as needed
        ])
    }
    
    // MARK: - Actions
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func uploadButtonTapped() {
        guard let text = textField?.text else {
            print("Text field is nil")
            return
        }
        
        // Use the text variable here as needed
        print("Text from text field: \(text)")
    }
    
    deinit {
        // Remove keyboard notification observers when the view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
}



import UIKit
import TensorFlowLite

class ViewController: UIViewController {
    
    // TensorFlow Lite model variables
    var interpreter: Interpreter?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize TensorFlow Lite Interpreter
        if let modelPath = Bundle.main.path(forResource: "model", ofType: "tflite") {
            interpreter = try? Interpreter(modelPath: modelPath)
        }
        
        // Example usage with an input image
        if let inputImage = UIImage(named: "input_image.jpg"),
           let inputTensor = preprocess(image: inputImage) {
            // Perform inference
            if let outputTensor = try? interpreter?.inferring(from: inputTensor) as? [Float] {
                // Process outputTensor as needed (e.g., classification results)
                print("Inference successful")
                print("Output tensor:", outputTensor)
            } else {
                print("Inference failed")
            }
        }
    }
    
    // Preprocess image into TensorFlow Lite input tensor
    private func preprocess(image: UIImage) -> Tensor? {
        guard let cgImage = image.cgImage else { return nil }
        
        // Resize image to match model input size
        let inputWidth = 224
        let inputHeight = 224
        
        // Create a new context with the desired size and draw the image into that context
        let size = CGSize(width: inputWidth, height: inputHeight)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        UIGraphicsGetCurrentContext()?.interpolationQuality = .high
        image.draw(in: CGRect(origin: .zero, size: size))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        // Normalize the pixel values and convert to tensor
        let inputTensor: Tensor
        do {
            let imageData = resizedImage.normalized()
            inputTensor = try Tensor(data: imageData, shape: [1, inputWidth, inputHeight, 3])
        } catch {
            print("Error converting image to tensor:", error)
            return nil
        }
        
        return inputTensor
    }
}

// UIImage extension for pixel normalization
extension UIImage {
    func normalized() -> Data {
        guard let cgImage = cgImage else { return Data() }
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        let minDimension = min(size.width, size.height)
        let scale = UIScreen.main.scale
        let width = Int(minDimension * scale)
        let height = Int(minDimension * scale)
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)!
        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        return context.makeImage()!.dataProvider!.data! as Data
    }
}
