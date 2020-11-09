//
//  devRantAvatarEditorApp.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/13/20.
//

import SwiftUI
import BackgroundTasks
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    /*func applicationDidFinishLaunching(_ application: UIApplication) {
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) { didAllow, error in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }*/
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { didAllow, error in
            
            if didAllow == true {
                print("User allowed notifications!")
            } else {
                print("User has denied notifications")
            }
            
            if error != nil {
                print(error!.localizedDescription)
            }
        }
        
        return true
    }
    
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
    
    let file = File.loadFiles(images: [AttachedImage(
        url: "https://img.devrant.com/devrant/rant/r_3240155_Re4L3.jpg",
        width: 491,
        height: 487
    )])[0]
    
    @State var url: URL?
    
    init() {
        self.url = file.url
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
