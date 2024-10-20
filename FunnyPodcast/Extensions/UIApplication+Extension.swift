//
//  UIApplication+Extension.swift
//  FunnyPodcast
//
//  Created by Gokhan on 20.10.2024.
//

import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
        guard let windowScene = shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate
        else {
            return nil
        }
        
        let mainTabbarController =  sceneDelegate.window?.rootViewController as? MainTabBarController
        return mainTabbarController
    }
}

