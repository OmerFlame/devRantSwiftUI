//
//  ContentView.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/13/20.
//

import SwiftUI

struct ContentView: View {
    @State var shouldShowLogin = false
    @State var shouldShowEditor = false
    @State var userID = UserDefaults.standard.integer(forKey: "UserID")
    @State var tokenID = UserDefaults.standard.integer(forKey: "TokenID")
    @State var tokenKey = UserDefaults.standard.string(forKey: "TokenKey")
    
    @State var username = UserDefaults.standard.string(forKey: "Username")
    @State var password = UserDefaults.standard.string(forKey: "Password")
    
    @State var isSheet = true
    
    @State var apiRequest = APIRequest(userIDUserDefaultsIdentifier: "UserID", tokenIDUserDefaultsIdentifier: "TokenID", tokenKeyUserDefaultsIdentifier: "TokenKey")
    
    var body: some View {
        VStack {
            /*if self.userID == 0 || self.tokenID == 0 || self.tokenKey == nil {
                EmptyView()
            } else if self.shouldShowEditor == true {
                AvatarEditor()
            }*/
            
            if self.shouldShowLogin {
                EmptyView()
            }
            
            if self.shouldShowEditor {
                MainScreen(apiRequest: self.apiRequest)
            }
        }.onAppear {
            if self.userID == 0 || self.tokenID == 0 || self.tokenKey == nil || self.username == nil || self.password == nil {
                self.shouldShowLogin.toggle()
            } else {
                self.shouldShowEditor.toggle()
            }
        }
        .sheet(isPresented: $shouldShowLogin, onDismiss: {
            self.shouldShowLogin = false
            self.shouldShowEditor = true
        }) {
            LoginScreen(showVar: $shouldShowLogin, apiRequest: self.apiRequest).presentation(isSheet: $isSheet)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
