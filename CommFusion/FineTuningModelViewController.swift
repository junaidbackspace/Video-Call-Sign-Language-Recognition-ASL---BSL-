import UIKit
import TensorFlowLite

class FineTuningModelViewController: UIViewController {

    private var interpreter: Interpreter?
    private var modelLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the initial model
        loadInitialModel()

        // Print input tensor shape to diagnose expected dimensions
        printInputTensorShape()

        // Example of adding new images with labels
        let newImages = [UIImage(named: "11.jpeg"), UIImage(named: "22.jpeg"), UIImage(named: "33.jpeg"), UIImage(named: "44.jpeg")].compactMap { $0 }
        let newLabels = ["Stop", "sTop", "stOp", "stoP"]

        // Fine-tune the model with new data
        fineTuneModel(with: newImages, labels: newLabels)

        // Save the updated model after fine-tuning
        saveUpdatedModel()
    }

    func loadInitialModel() {
        guard let modelPath = Bundle.main.path(forResource: "Custom_signs_model", ofType: "tflite") else {
            fatalError("Failed to load the initial model file.")
        }

        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter?.xallocateTensors()
            modelLoaded = true
        } catch {
            fatalError("Failed to create the interpreter: \(error)")
        }
    }

    func printInputTensorShape() {
        guard let interpreter = interpreter else {
            print("Interpreter is not initialized.")
            return
        }

        do {
            let inputTensor = try interpreter.input(at: 0)
            let inputShape = inputTensor.shape.dimensions
            print("Input Tensor Shape: \(inputShape)")
        } catch {
            print("Failed to get input tensor shape: \(error)")
        }
    }

    func fineTuneModel(with images: [UIImage], labels: [String]) {
        guard let interpreter = interpreter else {
            print("Interpreter is not initialized.")
            return
        }

        // Loop through each image and label
        for i in 0..<images.count {
            let image = images[i]
            let label = labels[i]

            // Preprocess the image
            guard let pixelBuffer = image.pixelBuffer(width: 150, height: 150) else {  // Adjust size to 150x150
                print("Failed to convert image to pixel buffer.")
                continue
            }

            // Convert the pixel buffer to normalized data
            guard let normalizedData = pixelBuffer.toNormalizedData() else {
                print("Failed to convert pixel buffer to normalized data.")
                continue
            }

            // Ensure the data size matches the model's expected input size
            do {
                let inputTensor = try interpreter.input(at: 0)
                let expectedSize = inputTensor.shape.dimensions.reduce(1, *)

                // Check if the normalized data size matches the expected input size of the model
                guard normalizedData.count == expectedSize * MemoryLayout<Float>.size else {
                    print("Mismatch in data size: provided \(normalizedData.count), expected \(expectedSize * MemoryLayout<Float>.size).")
                    continue
                }

                // Copy the normalized data to the input tensor of the interpreter
                try interpreter.copy(normalizedData, toInputAt: 0)

                // Run inference
                try interpreter.invoke()

                // Example: Update model weights based on prediction error or accuracy
                let outputTensor = try interpreter.output(at: 0)
                let predictedLabel = processOutputTensor(outputTensor)
                print("Predicted label: \(predictedLabel), Actual label: \(label)")

                // Simulated backpropagation or weight update based on prediction
                // Replace with actual fine-tuning logic if applicable

            } catch {
                print("Failed to process image \(i): \(error)")
                continue
            }
        }
    }

    func saveUpdatedModel() {
        // Example: Save updated model weights or parameters
        // Implement logic to save the model after fine-tuning
        // Replace this with your actual implementation to save the model

        print("Updated model weights saved successfully.")
    }

    func processOutputTensor(_ outputTensor: Tensor) -> String {
        // Example: Extract label from output tensor
        // Replace with actual post-inference processing logic
        return "predicted_label"
    }

}
