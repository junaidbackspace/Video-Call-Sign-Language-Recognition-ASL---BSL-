import UIKit
import TensorFlowLite

class LocalModelRetrainingViewController: UIViewController {

    private var interpreter: Interpreter?
    private var modelLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the initial model
        loadInitialModel()
        
        // Example of adding new images with labels
        let newImages = [UIImage(named: "11.jpeg"), UIImage(named: "22.jpeg"), UIImage(named: "33.jpeg"), UIImage(named: "44.jpeg")].compactMap { $0 }
        let newLabels = ["stop", "stop" ,"stop", "stop"]
        
        // Retrain the model with new data
        if modelLoaded {
            for i in 0..<newImages.count {
                let image = newImages[i]
                let label = newLabels[i]
                retrainModelWith(image: image, label: label)
            }
        } else {
            print("Initial model failed to load.")
        }
    }

    func loadInitialModel() {
        guard let modelPath = Bundle.main.path(forResource: "Custom_signs_model", ofType: "tflite") else {
            fatalError("Failed to load the initial model file.")
        }

        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter?.allocateTensors()
            modelLoaded = true
        } catch {
            fatalError("Failed to create the interpreter: \(error)")
        }
    }

    func retrainModelWith(image: UIImage, label: String) {
        guard let interpreter = interpreter else {
            print("Interpreter is not initialized.")
            return
        }

        // Preprocess the image
        guard let pixelBuffer = image.pixelBuffer(width: 150, height: 150) else {
            print("Failed to convert image to pixel buffer.")
            return
        }

        // Convert the CVPixelBuffer to Data
        guard let pixelBufferData = pixelBuffer.toNormalizedData() else {
            print("Failed to convert pixel buffer to data.")
            return
        }

        // Ensure the data size matches the model's expected input size
        do {
            let inputTensor = try interpreter.input(at: 0)
            let expectedSize = inputTensor.shape.dimensions.reduce(1, *)
            guard pixelBufferData.count == expectedSize * MemoryLayout<Float>.size else {
                print("Mismatch in data size: provided \(pixelBufferData.count), expected \(expectedSize * MemoryLayout<Float>.size).")
                print("Expected size details: inputShape = \(inputTensor.shape.dimensions), expectedSize = \(expectedSize * MemoryLayout<Float>.size)")
                return
            }
        } catch {
            print("Error getting input tensor: \(error)")
            return
        }

        // Run inference and update the model with new data
        do {
            try interpreter.copy(pixelBufferData, toInputAt: 0)
            try interpreter.invoke()

            // Perform backpropagation or fine-tuning here based on the label
            // Example: Update model weights with backpropagation based on prediction error
            let outputTensor = try interpreter.output(at: 0)
            let predictedLabel = processOutputTensor(outputTensor)
            print("Predicted label: \(predictedLabel), Actual label: \(label)")

            // Optionally, evaluate and adjust model parameters based on prediction accuracy
            // This step is simplified for illustration
        } catch {
            print("Failed to invoke the interpreter: \(error)")
        }
    }

    func processOutputTensor(_ outputTensor: Tensor) -> String {
        // Extract the predicted label from the output tensor
        let outputData = outputTensor.data.toArray(type: Float32.self)
        
        // Debug: Print the raw output data
        print("Output tensor data: \(outputData)")

        // Assuming the model outputs a one-hot encoded vector, find the index with the highest probability
        guard let maxIndex = outputData.indices.max(by: { outputData[$0] < outputData[$1] }) else {
            return "unknown"
        }

        // Map the index to the corresponding label
        let labels = ["stop", "go", "yield", "turn_left", "turn_right"] // Update with your actual labels
        return labels[maxIndex]
    }
}
