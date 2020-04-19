//
//  AppDelegate.swift
//  ipinmame-swift
//
//  Created by Jason Millard on 3/6/20.
//  Copyright © 2020 Jason Millard. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func createRomsFolder() {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                        .userDomainMask,
                                                                        true).first
        
        if let documentDirectoryPath = documentDirectoryPath {
            let romsPath = documentDirectoryPath.appending("/roms")
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: romsPath) {
                do {
                    try fileManager.createDirectory(atPath: romsPath,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
                } catch {
                    print("Error creating roms folder in documents dir: \(error)")
                }
            }
        }
    }
    
    func copyRom(nameForFile: String,
                 extForFile: String) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first
        
        let destURL = documentsURL!.appendingPathComponent("roms/")
            .appendingPathComponent(nameForFile)
            .appendingPathExtension(extForFile)
        
        guard let sourceURL = Bundle.main.url(forResource: nameForFile,
                                              withExtension: extForFile)
            else {
                print("Source File not found.")
                return
        }
        let fileManager = FileManager.default
        do {
            try fileManager.copyItem(at: sourceURL, to: destURL)
        } catch {
            print("Unable to copy file")
        }
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        createRomsFolder()
               
        copyRom(nameForFile: "ij_l7",
                extForFile: "zip")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

