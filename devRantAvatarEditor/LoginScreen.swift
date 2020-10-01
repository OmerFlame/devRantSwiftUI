//
//  LoginScreen.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/13/20.
//

import SwiftUI
import Combine

struct LoginScreen: View {
    @Binding var showVar: Bool
    
    @State var userID = UserDefaults.standard.integer(forKey: "UserID")
    @State var tokenID = UserDefaults.standard.integer(forKey: "TokenID")
    @State var tokenKey = UserDefaults.standard.string(forKey: "TokenKey")
    
    //@ObservedObject var userCredentials = credentials()
    
    @State var username = ""
    @State var password = ""
    
    @State var shouldShowLoadingRing = false
    @State var apiRequest: APIRequest
    
    @State var shouldShowIncorrectPassword = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField(String("Username"), text: $username).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 250, height: 34)
                SecureField(String("Password"), text: $password).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width: 250, height: 34)
                
                Button(action: {
                    self.shouldShowLoadingRing.toggle()
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.apiRequest.logIn(username: self.username, password: self.password)
                        
                        DispatchQueue.main.async {
                            self.shouldShowLoadingRing.toggle()
                            
                            if UserDefaults.standard.integer(forKey: "UserID") == 0 && UserDefaults.standard.integer(forKey: "TokenID") == 0 && UserDefaults.standard.string(forKey: "TokenKey") == nil {
                                
                                self.shouldShowIncorrectPassword.toggle()
                            } else {
                                showVar = false
                            }
                        }
                    }
                }, label: {
                    if shouldShowLoadingRing {
                        ProgressView().progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Log In")
                        
                    }
                })
            }.navigationBarTitle(Text("Log In"))
            .alert(isPresented: $shouldShowIncorrectPassword, content: {
                Alert(title: Text("Incorrect Credentials"), message: Text("Either your username or password are incorrect, please try again."), dismissButton: .default(Text("OK")))
            })
        }.onAppear {
            UserDefaults.standard.setValue(0, forKey: "UserID")
            UserDefaults.standard.setValue(0, forKey: "TokenID")
            UserDefaults.standard.setValue(nil, forKey: "TokenKey")
            
            UserDefaults.standard.setValue(nil, forKey: "Username")
            UserDefaults.standard.setValue(nil, forKey: "Password")
        }
    }
}

/*struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
*/

class credentials: ObservableObject {
    @Published var userID = UserDefaults.standard.integer(forKey: "UserID")
    @Published var tokenID = UserDefaults.standard.integer(forKey: "TokenID")
    @Published var tokenKey = UserDefaults.standard.string(forKey: "TokenKey")
}
