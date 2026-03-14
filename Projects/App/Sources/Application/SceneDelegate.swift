//
//  SceneDelegate.swift
//  ProjectDescriptionHelpers
//
//  Created by 새미 on 1/10/24.
//
import UIKit
import Feature

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private let refreshTokenManager = GOMSRefreshToken.shared
    public let notificationViewModel = NotificationViewModel()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        // 테스트를 위해 MapViewController로 즉시 이동
        DispatchQueue.main.async {
            let mapVC = MapViewController()
            self.window?.rootViewController = UINavigationController(rootViewController: mapVC)
            self.window?.makeKeyAndVisible()
        }
        
        applySavedTheme()
    }
    
    private func applySavedTheme() {
        let savedThemeValue = UserDefaults.standard.integer(forKey: "selectedTheme")
        let savedTheme = UIUserInterfaceStyle(rawValue: savedThemeValue) ?? .unspecified
        window?.overrideUserInterfaceStyle = savedTheme
    }
}
