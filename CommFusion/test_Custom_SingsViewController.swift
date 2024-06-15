import UIKit
import TensorFlowLite

class test_Custom_SingsViewController: UIViewController {

    private var interpreter: Interpreter?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the model
        guard let modelPath = Bundle.main.path(forResource: "Custom_signs_model", ofType: "tflite") else {
            fatalError("Failed to load the model file.")
        }

        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter?.allocateTensors()
        } catch {
            fatalError("Failed to create the interpreter: \(error)")
        }

        if let prediction = predict(image: UIImage(named: "aaa.jpeg")!) {
            print("Prediction is: \(prediction)")
        } else {
            print("Failed to get prediction.")
        }
    }

    func predict(image: UIImage) -> String? {
        guard let interpreter = interpreter else {
            fatalError("Interpreter is not initialized.")
        }

        // Get input tensor shape
        let inputTensor = try! interpreter.input(at: 0)
        let inputShape = inputTensor.shape.dimensions
        let inputHeight = inputShape[1]
        let inputWidth = inputShape[2]
        let inputChannels = inputShape[3]

        // Preprocess the image
        guard let pixelBuffer = image.pixelBuffer(width: inputWidth, height: inputHeight) else {
            print("Failed to convert image to pixel buffer.")
            return nil
        }

        // Convert the CVPixelBuffer to Data
        guard let pixelBufferData = pixelBuffer.toNormalizedData() else {
            print("Failed to convert pixel buffer to data.")
            return nil
        }

        // Ensure the data size matches the model's expected input size
        let expectedSize = inputHeight * inputWidth * inputChannels * MemoryLayout<Float>.size
        guard pixelBufferData.count == expectedSize else {
            print("Mismatch in data size: provided \(pixelBufferData.count), expected \(expectedSize).")
            return nil
        }

        // Run inference
        do {
            try interpreter.copy(pixelBufferData, toInputAt: 0)
            try interpreter.invoke()

            // Get the output tensor from the interpreter
            let outputTensor = try interpreter.output(at: 0)

            // Process the output tensor directly
            if let prediction = processOutputTensor(outputTensor) {
                return prediction
            } else {
                print("Failed to process output tensor.")
                return nil
            }
        } catch {
            print("Failed to invoke the interpreter: \(error)")
            return nil
        }
    }

    func processOutputTensor(_ outputTensor: Tensor) -> String? {
        // Extract float values from the output tensor
        let results: [Float] = outputTensor.data.toArray(type: Float.self)
        print("Results: \(results)")
        guard let maxResult = results.max() else {
            print("Failed to find the maximum result.")
            return nil
        }
        let maxIndex = results.firstIndex(of: maxResult) ?? 0
        return labels[maxIndex]
    }

    private var labels: [String] {
        return ["Hi I am Junaid", "label2", "label3"] // Replace with your actual labels
    }
}

extension Data {
    func toArray<T>(type: T.Type) -> [T] {
        let count = self.count / MemoryLayout<T>.size
        return self.withUnsafeBytes {
            Array(UnsafeBufferPointer(start: $0.baseAddress!.assumingMemoryBound(to: T.self), count: count))
        }
    }
}

extension CVPixelBuffer {
    func toNormalizedData() -> Data? {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(self, .readOnly) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(self) else {
            fatalError("Failed to get base address of pixel buffer.")
        }

        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
        let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)

        var data = Data(count: width * height * 3 * MemoryLayout<Float>.size)
        data.withUnsafeMutableBytes { (outputBuffer: UnsafeMutableRawBufferPointer) in
            let outputPointer = outputBuffer.baseAddress!.assumingMemoryBound(to: Float.self)
            var pixelIndex = 0
            for row in 0..<height {
                for col in 0..<width {
                    let pixelOffset = row * bytesPerRow + col * 4
                    let r = Float(buffer[pixelOffset + 1]) / 255.0
                    let g = Float(buffer[pixelOffset + 2]) / 255.0
                    let b = Float(buffer[pixelOffset + 3]) / 255.0
                    outputPointer[pixelIndex] = r
                    outputPointer[pixelIndex + 1] = g
                    outputPointer[pixelIndex + 2] = b
                    pixelIndex += 3
                }
            }
        }
        return data
    }
}

extension UIImage {
    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                         kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            return nil
        }

        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        UIGraphicsPopContext()

        return buffer
    }
}
