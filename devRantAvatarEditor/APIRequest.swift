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
    
    init(userIDUserDefaultsIdentifier: String, tokenIDUserDefaultsIdentifier: String, tokenKeyUserDefaultsIdentifier: String) {
        //self._success = success
        //self._authTokenID = authTokenID
        //self._authTokenKey = authTokenKey
        //self._authTokenExpireTime = authTokenExpireTime
        //self._authTokenUserID = authTokenUserID
        
        self.userIDUserDefaultsIdentifier = userIDUserDefaultsIdentifier
        self.tokenIDUserDefaultsIdentifier = tokenIDUserDefaultsIdentifier
        self.tokenKeyUserDefaultsIdentifier = tokenKeyUserDefaultsIdentifier
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
        
        var extractedCredentials: RantFeed?
        
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
                    
                    extractedCredentials = try! decoder.decode(RantFeed.self, from: dataFromString!)
                    completionSemaphore.signal()
                }
            }
        }
        
        /*defer {
            completionSemaphore.wait()
            let dataFromString = receivedRawJSON.data(using: .utf8)
            
            let decoder = JSONDecoder()
            
            do {
                extractedCredentials = try decoder.decode(RantFeed.self, from: dataFromString!)
                print("SUCCESS")
            } catch let error {
                print("ERROR: \(error.localizedDescription)")
            }
        }*/
        
        task.resume()
        
        completionSemaphore.wait()
        return extractedCredentials!
    }
}
