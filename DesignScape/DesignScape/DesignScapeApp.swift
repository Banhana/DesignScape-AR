//
//  DesignScapeApp.swift
//  DesignScape
//
//  Created by Tony Banh on 12/4/23.
//

import SwiftUI
import FirebaseCore

// Firebase Stuff
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
    }
}

@main
struct DesignScapeApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    // Change to "dev.DesignScape.DesignScape once we get unique identifier
    static let subsystem: String = "dev.tony.DesignScape"

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.font, Font.custom("Merriweather-Regular", size: 14))
//            RoomLoaderView()
        }
    }
}
 
