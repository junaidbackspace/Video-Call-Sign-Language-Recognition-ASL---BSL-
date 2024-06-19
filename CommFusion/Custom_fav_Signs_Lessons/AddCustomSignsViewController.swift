import UIKit
import AVFoundation

class AddCustomSignsViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    var captureSession: AVCaptureSession!
    var frontCamera: AVCaptureDevice?
    var stillImageOutput: AVCapturePhotoOutput!
    var capturedImages: [UIImage] = []
    var timerLabel: UILabel!
    var timer: Timer?
    var timerCounter = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        addTimerLabel()
        addBackButton() // Add the back button
        startTimer()
    }

    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        // Find the front camera
        if let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            do {
                let input = try AVCaptureDeviceInput(device: frontCamera)
                stillImageOutput = AVCapturePhotoOutput()

                if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                    captureSession.addInput(input)
                    captureSession.addOutput(stillImageOutput)

                    let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer.videoGravity = .resizeAspectFill
                    previewLayer.frame = view.layer.bounds
                    view.layer.addSublayer(previewLayer)

                    captureSession.startRunning()
                }
            } catch let error {
                print("Error Unable to initialize camera: \(error.localizedDescription)")
            }
        } else {
            print("Unable to access front camera.")
        }
    }

    func addTimerLabel() {
        timerLabel = UILabel()
        timerLabel.textColor = .white
        timerLabel.textAlignment = .center
        timerLabel.font = UIFont.systemFont(ofSize: 100)
        timerLabel.backgroundColor = .black
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timerLabel)

        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
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
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    @objc func updateTimer() {
        timerCounter -= 1
        if timerCounter == 0 {
            // Timer reached 0, start capturing images
            timer?.invalidate()
            timer = nil
            timerLabel.textColor = .blue
            timerLabel.backgroundColor = .clear
            captureImages()
        }
        timerLabel.text = "\(timerCounter)"
    }

    func captureImages() {
        var captureCount = 0
        let captureTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if captureCount < 5 {
                let settings = AVCapturePhotoSettings()
                self.stillImageOutput.capturePhoto(with: settings, delegate: self)
                captureCount += 1
            } else {
                timer.invalidate() // Stop the timer once three images are captured
            }
        }
        // Ensure the timer fires even when the app is in background mode
        RunLoop.main.add(captureTimer, forMode: .common)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            capturedImages.append(image)
            
            timerLabel.text = String (capturedImages.count)
            print("Total Captured images",capturedImages.count)
            if capturedImages.count == 5 { // Change this to the desired number of images
              
                
                print("Captured 5 images")
                navigateToNextController()
            }
        }
    }

    func navigateToNextController() {
        // Navigate to the given controller
        
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadCustomimages") as? UploadCapturedImageViewController {
            // Pass captured images to the next controller
            nextVC.images = capturedImages
            navigationController?.pushViewController(nextVC, animated: true)
            captureSession.stopRunning()
        }
    }
}
