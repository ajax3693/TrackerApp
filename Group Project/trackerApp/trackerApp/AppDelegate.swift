//
//  AppDelegate.swift
//  trackerApp
//
//  Created by AJ Cardoza on 11/2/23.
//

import UIKit
import ParseSwift
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ParseSwift.initialize(applicationId: "ElQcnjjx0i7PgZCt4NqxCrXgQSdtjWitxgzePJGt",
                              clientKey: "jNSe3gqoNMpcjl91BD77KWiaJIxbGwO52EJWMOwN",
                              serverURL: URL(string: "https://parseapi.back4app.com")!)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        print("Notification permission granted.")
                    } else {
                        print("Notification permission denied because: \(error?.localizedDescription ?? "Error not available").")
                    }
                }
                
        return true
    }


    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }
}
