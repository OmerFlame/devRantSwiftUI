//
//  devRantAvatarEditorApp.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/13/20.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        let tmpDirectory = try! FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
        tmpDirectory.forEach { file in
            let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
            try! FileManager.default.removeItem(atPath: path)
        }
    }
}

@main
struct devRantAvatarEditorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
