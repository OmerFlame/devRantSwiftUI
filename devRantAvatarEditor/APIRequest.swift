//
//  APIRequest.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/13/20.
//

import Foundation
import SwiftUI

enum APIError: Error {
    case responseError
    case decodingError
    case otherError
}

class APIRequest {
    var resourceURL: URL!
    var request: URLRequest!
    
    //@Binding var success: Bool?
    //@Binding var authTokenID: Int
    //@Binding var authTokenKey: String?
    //@Binding var authTokenExpireTime: Int?
    //@Binding var authTokenUserID: Int
    
    let userIDUserDefaultsIdentifier: String!
    let tokenIDUserDefaultsIdentifier: String!
    let tokenKeyUserDefaultsIdentifier: String!
    
    init() {
        //self._success = success
        //self._authTokenID = authTokenID
        //self._authTokenKey = authTokenKey
        //self._authTokenExpireTime = authTokenExpireTime
        //self._authTokenUserID = authTokenUserID
        
        self.userIDUserDefaultsIdentifier = "UserID"
        self.tokenIDUserDefaultsIdentifier = "TokenID"
        self.tokenKeyUserDefaultsIdentifier = "TokenKey"
    }
    
    func logIn(username: String, password: String) {
        self.resourceURL = URL(string: "https://devrant.com/api/users/auth-token?app=3")!
        self.request = URLRequest(url: self.resourceURL)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "app=3&username=\(username)&password=\(password)".data(using: .utf8)
        
        let completionSemaphore = DispatchSemaphore(value: 0)
        var receivedRawJSON = String()
        
        
        let task = URLSession.shared.dataTask(with: self.request) { data, response, error in
            if let response = response {
                print(response)
                
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    receivedRawJSON = body
                    print(body)
                    completionSemaphore.signal()
                }
            }
        }
        
        defer {
            completionSemaphore.wait()
            var extractedCredentials: UserCredentials!
            let dataFromString = receivedRawJSON.data(using: .utf8)
            
            let decoder = JSONDecoder()
            
            do {
                extractedCredentials = try decoder.decode(UserCredentials.self, from: dataFromString!)
            } catch let error {
                //self.authTokenID = 0
                //self.authTokenKey = nil
                //self.authTokenUserID = 0
                
                UserDefaults.standard.set(0, forKey: self.userIDUserDefaultsIdentifier)
                UserDefaults.standard.set(nil, forKey: self.tokenKeyUserDefaultsIdentifier)
                UserDefaults.standard.setValue(0, forKey: self.tokenIDUserDefaultsIdentifier)
                print(error.localizedDescription)
                //return
                
            }
            
            if extractedCredentials != nil && extractedCredentials.auth_token != nil {
                DispatchQueue.main.async {
                    //self.success = extractedCredentials.success!
                    //self.authTokenID = extractedCredentials.auth_token!.id
                    //self.authTokenKey = extractedCredentials.auth_token!.key
                    //self.authTokenExpireTime = extractedCredentials.auth_token!.expire_time
                    //self.authTokenUserID = extractedCredentials.auth_token!.user_id
                    
                    UserDefaults.standard.set(extractedCredentials.auth_token!.id, forKey: self.tokenIDUserDefaultsIdentifier)
                    UserDefaults.standard.set(extractedCredentials.auth_token!.key, forKey: self.tokenKeyUserDefaultsIdentifier)
                    UserDefaults.standard.set(extractedCredentials.auth_token!.user_id, forKey: self.userIDUserDefaultsIdentifier)
                    UserDefaults.standard.set(extractedCredentials.auth_token!.expire_time, forKey: "TokenExpireTime")
                    
                    UserDefaults.standard.set(username, forKey: "Username")
                    UserDefaults.standard.set(password, forKey: "Password")
                }
            }
        }
        
        task.resume()
    }
    
    func getRantFeed() -> RantFeed {
        if Double(UserDefaults.standard.integer(forKey: "TokenExpireTime")) - Date().timeIntervalSince1970 <= 0 {
            logIn(username: UserDefaults.standard.string(forKey: "Username")!, password: UserDefaults.standard.string(forKey: "Password")!)
        }
        
        var extractedData: RantFeed?
        
        self.resourceURL = URL(string: "https://devrant.com/api/devrant/rants?app=3&token_id=\(String(UserDefaults.standard.integer(forKey: "TokenID")))&token_key=\(UserDefaults.standard.string(forKey: "TokenKey")!)&user_id=\(String(UserDefaults.standard.integer(forKey: "UserID")))&range=week&limit=20")
        self.request = URLRequest(url: self.resourceURL)
        request.httpMethod = "GET"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        //request.httpBody = "app=3&token_id=\(String(tokenID))&token_key=\(tokenKey)&user_id=\(String(userID))&range=week&limit=20".data(using: .utf8)
        
        let completionSemaphore = DispatchSemaphore(value: 0)
        var receivedRawJSON = String()
        
        let task = URLSession.shared.dataTask(with: self.request) { data, response, error in
            if let response = response {
                print(response)
                
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    receivedRawJSON = body
                    print(body)
                    
                    let dataFromString = receivedRawJSON.data(using: .utf8)
                    
                    let decoder = JSONDecoder()
                    
                    extractedData = try! decoder.decode(RantFeed.self, from: dataFromString!)
                    completionSemaphore.signal()
                }
            }
        }
        
        task.resume()
        
        completionSemaphore.wait()
        return extractedData!
    }
    
    func getRantFromID(id: Int) throws -> RantResponse? {
        
        self.resourceURL = URL(string: "https://devrant.com/api/devrant/rants/\(String(id))?app=3&user_id=\(String(UserDefaults.standard.integer(forKey: "UserID")))&token_id=\(String(UserDefaults.standard.integer(forKey: "TokenID")))&token_key=\(String(UserDefaults.standard.string(forKey: "TokenKey")!))")
        self.request = URLRequest(url: self.resourceURL)
        request.httpMethod = "GET"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let completionSemaphore = DispatchSemaphore(value: 0)
        var receivedRawJSON = String()
        
        var extractedData: RantResponse?
        
        let task = URLSession.shared.dataTask(with: self.request) { data, response, error in
            if response != nil {
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    receivedRawJSON = body
                    
                    print(body)
                    
                    completionSemaphore.signal()
                }
            }
        }
        
        task.resume()
        
        completionSemaphore.wait()
        
        let decoder = JSONDecoder()
        let dataFromString = receivedRawJSON.data(using: .utf8)
        
        do {
            extractedData = try decoder.decode(RantResponse.self, from: dataFromString!)
            
            return extractedData!
        } catch let error {
            print(error.localizedDescription)
            
            throw APIError.decodingError
        }
    }
    
    func getProfileFromID(_ profileID: Int, userContentType: ProfileContentTypes, skip: Int) throws -> ProfileResponse? {
        let userID = UserDefaults.standard.integer(forKey: "UserID")
        let tokenID = UserDefaults.standard.integer(forKey: "TokenID")
        let tokenKey = UserDefaults.standard.string(forKey: "TokenKey")
        
        let resourceURL = URL(string: "https://devrant.com/api/users/\(String(profileID))?app=3&skip=\(String(skip))&content=\(String(userContentType.rawValue))&user_id=\(String(userID))&token_id=\(String(tokenID))&token_key=\(String(tokenKey!))")
        self.request = URLRequest(url: resourceURL!)
        self.request.httpMethod = "GET"
        self.request.addValue("application/x-www-form/urlencoded", forHTTPHeaderField: "Content-Type")
        
        let completionSemaphore = DispatchSemaphore(value: 0)
        var receivedRawJSON = String()
        
        var extractedData: ProfileResponse?
        
        let task = URLSession.shared.dataTask(with: self.request) { data, response, error in
            if response != nil {
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    receivedRawJSON = body
                    
                    print(body)
                    
                    completionSemaphore.signal()
                }
            }
        }
        
        task.resume()
        
        completionSemaphore.wait()
        
        let decoder = JSONDecoder()
        let dataFromString = receivedRawJSON.data(using: .utf8)
        
        do {
            extractedData = try decoder.decode(ProfileResponse.self, from: dataFromString!)
            
            return extractedData!
        } catch DecodingError.dataCorrupted(let context) {
            print(context)
            
            throw APIError.decodingError
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Key: '\(key)' not found: ", context.debugDescription)
            
            throw APIError.decodingError
        } catch DecodingError.valueNotFound(let value, let context) {
            print("Value: '\(value)' not found: ", context.debugDescription)
            
            throw APIError.decodingError
        } catch DecodingError.typeMismatch(let type, let context) {
            print("Type '\(type)' mismatch: ", context.debugDescription)
            print("codingPath: ", context.codingPath)
            
            throw APIError.decodingError
        } catch let error {
            print(error.localizedDescription)
            
            throw APIError.decodingError
        }
        
        return nil
    }
}
