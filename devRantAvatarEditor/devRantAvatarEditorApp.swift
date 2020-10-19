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

struct TestView: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: RantView(rantID: 3240155,
                                                 apiRequest: APIRequest())) {
                RantInFeedView(rantContents: RantInFeed(
                                id: 3240155,
                                text: "80% of the letters in \"Intel\" also appear in \"Hitler\" while none of the letters in \"AMD\" do.",
                                score: 8,
                                created_time: 1602599842,
                                attached_image: .attachedImage(
                                    AttachedImage(
                                        url: "https://img.devrant.com/devrant/rant/r_3240155_Re4L3.jpg",
                                        width: 491,
                                        height: 487
                                    )
                                ),
                                num_comments: 12,
                                tags: ["random","intel is evil"],
                                vote_state: 0,
                                edited: false,
                                link: nil,
                                rt: 1,
                                rc: 6,
                                c_type: nil,
                                c_type_long: nil,
                                user_id: 1434356,
                                user_username: "Fast-Nop",
                                user_score: 29021,
                                user_avatar: UserAvatar(
                                	b: "7bc8a4",
                                    i: "v-37_c-3_b-1_g-m_9-1_1-1_16-3_3-4_8-3_7-3_5-4_12-1_6-98_2-21_22-1_15-2_11-2_4-4.jpg"
                                ),
                                user_avatar_lg: UserAvatar(
                                	b: "69c9cd",
                                    i: "v-37_c-1_b-6_g-m_9-1_1-7_16-11_3-1_8-2_7-2_5-1_12-7_6-97_10-5_2-25_22-2_15-3_18-2_19-3_4-1_20-1.png"
                                ),
                                user_dpp: nil))
                    //.fixedSize(horizontal: false, vertical: true)
                    .frame(alignment: .leading)
            }
        }
    }
}
