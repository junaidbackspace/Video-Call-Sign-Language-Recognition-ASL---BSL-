import Foundation
import UIKit

class APIWrapper {
  
    private let session: URLSession

    init() {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 600 // Set timeout to 300 seconds (5 minutes)
            configuration.timeoutIntervalForResource = 600
            session = URLSession(configuration: configuration)
        }

    func insertData(baseUrl: String, userDictionary: [String: Any], completion: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: baseUrl) else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: userDictionary) else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize user data to JSON"]))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"]))
                    return
                }

                if httpResponse.statusCode == 200 {
                    // Check if there is data received from the server
                    guard let responseData = data else {
                        completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from the server"]))
                        return
                    }

                    // Convert data to string
                    if let responseString = String(data: responseData, encoding: .utf8) {
                        completion(responseString, nil)
                    } else {
                        completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to string"]))
                    }
                } else {
                    completion(nil, NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to sign up user"]))
                }
            }
        }.resume()
    }


    
  //  MARK:- Img Upload
    
    func uploadImage(baseUrl: String,imageURL: URL) {
          // Change to your server URL for image upload
         guard let imageData = try? Data(contentsOf: imageURL) else {
             print("Failed to read image data")
             return
         }
         
         let request = NSMutableURLRequest(url: NSURL(string: baseUrl)! as URL)
         request.httpMethod = "POST"
         
         let boundary = "Boundary-\(UUID().uuidString)"
         request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
         
         var body = Data()
         
         body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"profile_picture\"; filename=\"\(imageURL.lastPathComponent)\"\r\n".data(using: .utf8)!)

         body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
         body.append(imageData)
         body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
         
         request.httpBody = body
         
         let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
             guard let data = data, error == nil else {
                 print("Error uploading image:", error ?? "Unknown error")
                 return
             }
             
             if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                 print("Error uploading image. HTTP status code:", httpStatus.statusCode)
                 print("Response:", String(data: data, encoding: .utf8) ?? "")
             } else {
                 print("Image uploaded successfully")
                 // Handle successful upload response
             }
         }
         
         task.resume()
     }
    
  

    func fetchData<T: Decodable>(baseUrl: URL, structure: T.Type, completion: @escaping (T?, Error?) -> Void) {
        var request = URLRequest(url: baseUrl)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
//                    handleError(error, completion)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
//                    handleError(nil, completion)
                    return
                }

                if (200...299).contains(httpResponse.statusCode) {
                    if let responseData = data {
                        do {
                            let decoder = JSONDecoder()
                            let decodedData = try decoder.decode(structure, from: responseData)
                            completion(decodedData, nil)
                        } catch {
                            print("Error decoding response:", error.localizedDescription)
                            completion(nil, error)
                        }
                    } else {
                        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from the server"])
                        print("Error in receiving:", error.localizedDescription)
                        completion(nil, error)
                    }
                } else {
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch data"])
                    print("Error in receiving:", error.localizedDescription)
                    completion(nil, error)
                }
            }
        }.resume()
    }


    func fetchDatatoAddContact(baseUrl: URL, structure: addUser.Type, completion: @escaping (addUser?, Error?) -> Void) {
        var request = URLRequest(url: baseUrl)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error in receiving:", error.localizedDescription)
                    completion(nil, error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])
                    print("Error in receiving:", error.localizedDescription)
                    completion(nil, error)
                    return
                }

                if (200...299).contains(httpResponse.statusCode) {
                    if let responseData = data {
                        do {
                            // Attempt manual decoding
                            if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                                let decoder = JSONDecoder()
                                let jsonData = try JSONSerialization.data(withJSONObject: json)
                                let decodedData = try decoder.decode(addUser.self, from: jsonData)
                                completion(decodedData, nil)
                            } else {
                                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode JSON response"])
                                print("Error in receiving:", error.localizedDescription)
                                completion(nil, error)
                            }
                        } catch {
                            print("Error decoding response:", error.localizedDescription)
                            completion(nil, error)
                        }
                    } else {
                        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from the server"])
                        print("Error in receiving:", error.localizedDescription)
                        completion(nil, error)
                    }
                } else {
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch data"])
                    print("Error in receiving:", error.localizedDescription)
                    completion(nil, error)
                }
            }
        }.resume()
    }
    
    func fetchUserInfo(baseUrl: URL, structure: singleUserInfo.Type, completion: @escaping (singleUserInfo?, Error?) -> Void) {
        var request = URLRequest(url: baseUrl)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error in receiving:", error.localizedDescription)
                    completion(nil, error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])
                    print("Error in receiving:", error.localizedDescription)
                    completion(nil, error)
                    return
                }

                if (200...299).contains(httpResponse.statusCode) {
                    if let responseData = data {
                        do {
                            // Attempt manual decoding
                            if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                                print("\ndecoding user info \n")
                                let decoder = JSONDecoder()
                                let jsonData = try JSONSerialization.data(withJSONObject: json)
                                let decodedData = try decoder.decode(singleUserInfo.self, from: jsonData)
                                completion(decodedData, nil)
                            } else {
                                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode JSON response"])
                                print("Error in receiving:", error.localizedDescription)
                                completion(nil, error)
                            }

                        } catch {
                            print("Error decoding response:", error.localizedDescription)
                            completion(nil, error)
                        }
                    } else {
                        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from the server"])
                        print("Error in receiving:", error.localizedDescription)
                        completion(nil, error)
                    }
                } else {
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch data"])
                    print("Error in receiving:", error.localizedDescription)
                    completion(nil, error)
                }
            }
        }.resume()
    }

    


//Lesson dislike
    func deleteData(baseUrl: String, data: [String: Any], completion: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: baseUrl) else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize data to JSON"]))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"]))
                    return
                }

                if httpResponse.statusCode == 200 {
                    // Check if there is data received from the server
                    guard let responseData = data else {
                        completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from the server"]))
                        return
                    }

                    // Convert data to string
                    if let responseString = String(data: responseData, encoding: .utf8) {
                        completion(responseString, nil)
                    } else {
                        completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to string"]))
                    }
                } else {
                    completion(nil, NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed request with status code \(httpResponse.statusCode)"]))
                }
            }
        }.resume()
    }


    func putRequest<T: Encodable>(urlString: String, requestBody: T, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        // Construct the URL
        guard let url = URL(string: urlString) else {
            completion(nil, nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        // Serialize the request body to JSON data
        let jsonData: Data
        do {
            jsonData = try JSONEncoder().encode(requestBody)
        } catch {
            completion(nil, nil, error)
            return
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, nil, error)
                    return
                }

                completion(data, response, nil)
            }
        }.resume()
    }
    
 


    func predictAlphabet(baseUrl: URL, image: UIImage, completion: @escaping (String?, Error?) -> Void) {
        var request = URLRequest(url: baseUrl)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get JPEG representation of UIImage"])
            completion(nil,  error)
            return
        }
        
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error in receiving:", error.localizedDescription)
                    completion(nil, error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])
                    print("Error in receiving:", error.localizedDescription)
                    completion(nil,  error)
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    if let responseData = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                                if let predictedLabel = json["class_name"] as? String,
                                   let confidence = json["confidence"] as? Float {
                                    completion(predictedLabel, nil)
                                } else {
                                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode JSON response"])
                                    print("Error in receiving:", error.localizedDescription)
                                    completion(nil, error)
                                }
                            } else {
                                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode JSON response"])
                                print("Error in receiving:", error.localizedDescription)
                                completion(nil, error)
                            }
                        } catch {
                            print("Error decoding response:", error.localizedDescription)
                            completion(nil, error)
                        }
                    } else {
                        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from the server"])
                        print("Error in receiving:", error.localizedDescription)
                        completion(nil,  error)
                    }
                } else {
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch data"])
                    print("Error in receiving:", error.localizedDescription)
                    completion(nil, error)
                }
            }
        }.resume()
    }

    

    
    func predictWords(baseUrl: URL, image: UIImage, completion: @escaping (String?, Error?) -> Void) {
        var request = URLRequest(url: baseUrl)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get JPEG representation of UIImage"])
            completion(nil, error)
            return
        }

        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"

        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!) // Note the change here: `name="file"`
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        // Debug: Print request headers
        print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")

        // Debug: Print the complete request body as string
        if let bodyString = String(data: body, encoding: .utf8) {
            print("Request Body: \(bodyString)")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error in receiving:", error.localizedDescription)
                    completion(nil, error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])
                    print("Error in receiving:", error.localizedDescription)
                    completion(nil, error)
                    return
                }

                print("HTTP Status Code:", httpResponse.statusCode)

                if (200...299).contains(httpResponse.statusCode) {
                    if let responseData = data {
                        do {
                            // Debug: Print raw response data for debugging
                            if let responseString = String(data: responseData, encoding: .utf8) {
                                print("Raw Response Data: \(responseString)")
                            }

                            if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                                if let predictedLabel = json["label"] as? String {
                                    print("Predicted Word : \(predictedLabel)")
                                    completion(predictedLabel, nil)
                                } else {
                                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode JSON response: required keys not found"])
                                    print("Error in receiving:", error.localizedDescription)
                                    completion(nil, error)
                                }
                            } else {
                                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode JSON response"])
                                print("Error in receiving:", error.localizedDescription)
                                completion(nil, error)
                            }
                        } catch {
                            print("Error decoding response:", error.localizedDescription)
                            completion(nil, error)
                        }
                    } else {
                        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from the server"])
                        print("Error in receiving:", error.localizedDescription)
                        completion(nil, error)
                    }
                } else {
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch data"])
                    print("Error in receiving:", error.localizedDescription, "Status code:", httpResponse.statusCode)
                    completion(nil, error)
                }
            }
        }.resume()
    }

    
    
    func predictBSL(baseUrl: URL, image: UIImage, completion: @escaping (String?, Error?) -> Void) {
        var request = URLRequest(url: baseUrl)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get JPEG representation of UIImage"])
            completion(nil, error)
            return
        }

        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"

        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!) // Note the change here: `name="file"`
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        // Debug: Print request headers
        print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")

        // Debug: Print the complete request body as string
        if let bodyString = String(data: body, encoding: .utf8) {
            print("Request Body: \(bodyString)")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error in receiving:", error.localizedDescription)
                    completion(nil, error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])
                    print("Error in receiving:", error.localizedDescription)
                    completion(nil, error)
                    return
                }

                print("HTTP Status Code:", httpResponse.statusCode)

                if (200...299).contains(httpResponse.statusCode) {
                    if let responseData = data {
                        do {
                            // Debug: Print raw response data for debugging
                            if let responseString = String(data: responseData, encoding: .utf8) {
                                print("Raw Response Data: \(responseString)")
                            }

                            if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                                if let predictedLabel = json["prediction"] as? String {
                                    print("Predicted BSL Sign : \(predictedLabel)")
                                    completion(predictedLabel, nil)
                                } else {
                                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode JSON response: required keys not found"])
                                    print("Error in receiving:", error.localizedDescription)
                                    completion(nil, error)
                                }
                            } else {
                                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode JSON response"])
                                print("Error in receiving:", error.localizedDescription)
                                completion(nil, error)
                            }
                        } catch {
                            print("Error decoding response:", error.localizedDescription)
                            completion(nil, error)
                        }
                    } else {
                        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from the server"])
                        print("Error in receiving:", error.localizedDescription)
                        completion(nil, error)
                    }
                } else {
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch data"])
                    print("Error in receiving:", error.localizedDescription, "Status code:", httpResponse.statusCode)
                    completion(nil, error)
                }
            }
        }.resume()
    }

    
    func uploadCustom_SignsImages(user: String, label: String, images: [URL], completion: @escaping (Result<TrainResponse, Error>) -> Void) {
        guard let url = URL(string: "\(Constants.serverURL)/testing-CustomSigns/train/") else {
               completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
               return
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           
           let boundary = UUID().uuidString
           request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
           
           var data = Data()
           
           // Add user parameter
           data.append("--\(boundary)\r\n".data(using: .utf8)!)
           data.append("Content-Disposition: form-data; name=\"user\"\r\n\r\n".data(using: .utf8)!)
           data.append("\(user)\r\n".data(using: .utf8)!)
           
           // Add label parameter
           data.append("--\(boundary)\r\n".data(using: .utf8)!)
           data.append("Content-Disposition: form-data; name=\"label\"\r\n\r\n".data(using: .utf8)!)
           data.append("\(label)\r\n".data(using: .utf8)!)
           
           // Add images
           for (index, imageUrl) in images.enumerated() {
               guard let imageData = try? Data(contentsOf: imageUrl) else {
                   completion(.failure(NSError(domain: "Failed to load image data", code: 0, userInfo: nil)))
                   return
               }
               
               data.append("--\(boundary)\r\n".data(using: .utf8)!)
               data.append("Content-Disposition: form-data; name=\"images\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
               data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
               data.append(imageData)
               data.append("\r\n".data(using: .utf8)!)
           }
           
           data.append("--\(boundary)--\r\n".data(using: .utf8)!)
           
           request.httpBody = data
           
           // Perform the request with the shared session
           let task = session.dataTask(with: request) { (responseData, response, error) in
               if let error = error {
                   completion(.failure(error))
                   return
               }
               
               guard let responseData = responseData else {
                   completion(.failure(NSError(domain: "No response data", code: 0, userInfo: nil)))
                   return
               }
               
               do {
                   let response = try JSONDecoder().decode(TrainResponse.self, from: responseData)
                   completion(.success(response))
               } catch {
                   completion(.failure(error))
               }
           }
           
           task.resume()
       }
    
    
    func CustomSigns_Predict(url : URL,image: UIImage, user: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Convert UIImage to Data
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            print("Error converting image to data")
            return
        }
        
        // Create a URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Define boundary string
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create multipart form data
        var body = Data()
        
        // Append user data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"user\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(user)\r\n".data(using: .utf8)!)
        
        // Append image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // End boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Create and start a URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "com.yourapp.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let prediction = jsonResponse["prediction"] as? String {
                    completion(.success(prediction))
                } else if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                          let error = jsonResponse["error"] as? String {
                    let error = NSError(domain: "com.yourapp.error", code: -1, userInfo: [NSLocalizedDescriptionKey: error])
                    completion(.failure(error))
                } else {
                    let error = NSError(domain: "com.yourapp.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }

    
}
