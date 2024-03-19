import Foundation
class APIWrapper {
  

    
//    func insertData(baseUrl: String, u: User, userDictionary: [String: Any], completion: @escaping (Error?) -> Void) {
//        guard let url = URL(string: baseUrl) else {
//            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
//            return
//        }
//
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: userDictionary) else {
//            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize user data to JSON"]))
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    completion(error)
//                    return
//                }
//
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"]))
//                    return
//                }
//
//                if httpResponse.statusCode == 200 {
//                    // Check if there is data received from the server
//                    guard let responseData = data else {
//                        completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from the server"]))
//                        return
//                    }
//
//                    do {
//                        // Parse the JSON data
//                        if let jsonArray = try JSONSerialization.jsonObject(with: responseData, options: []) as? [Any] {
//                            // Look for the dictionary in the array
//                            for item in jsonArray {
//                                if let dictionary = item as? [String: Any], let userId = dictionary["user_id"] as? Int {
//                                    // Save user ID to UserDefaults
//                                    UserDefaults.standard.set(userId, forKey: "userID")
//                                    print("User ID saved successfully: \(userId)")
//                                    completion(nil)
//                                    return
//                                }
//                            }
//                            // If no user ID found in the array
//                            print("User ID not found in JSON data")
//                            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not found in JSON data"]))
//                        } else {
//                            print("Failed to parse JSON data")
//                            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON data"]))
//                        }
//                    } catch {
//                        print("Error parsing JSON data: \(error)")
//                        completion(error)
//                    }
//                } else {
//                    completion(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to sign up user"]))
//                }
//            }
//        }.resume()
//    }



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
         body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(imageURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
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
    
}


