//
//  SceneDelegate.swift
//  ProjectDescriptionHelpers
//
//  Created by 준표 on 4/4/26.
//

import UIKit
import Feature
import KakaoMapsSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let refreshTokenManager = GOMSRefreshToken.shared
    public let notificationViewModel = NotificationViewModel()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let defaults = UserDefaults.standard
        let isSwitchOn = defaults.bool(forKey: "isCameraOn")
        let adminIsSwitchOn = defaults.bool(forKey: "isSwitchMakeOn")

        

        #if !DEBUG
        checkForUpdates { needsUpdate in
            if needsUpdate {
                print("업데이트 필요")
                self.showUpdatePopup()
            } else {
                print("최신 버전입니다")
            }
        }
        #endif

        applySavedTheme()

        if let accessToken = KeyChain.shared.read(key: Const.KeyChainKey.accessToken), !accessToken.isEmpty {
            refreshTokenManager.tokenReissuance { [weak self] success in
                guard let self = self else { return }
                if success {
                    if let savedToken = UserDefaults.standard.string(forKey: "FCMToken") {
                        notificationViewModel.setupFcmToken(fcmToken: savedToken)
                        notificationViewModel.setupaccessToken(accessToken: "Bearer \(accessToken)")
                        notificationViewModel.postFcmToken { success in
                            if success {
                                print("FCM 토큰 전송 성공")
                            } else {
                                print("FCM 토큰 전송 실패")
                            }
                        }
                    }
                    self.setRootViewControllerBasedOnAuthority(isSwitchOn: isSwitchOn, adminIsSwitchOn: adminIsSwitchOn)
                } else {
                    self.showLoginScreen()
                }
            }
        } else {
            showLoginScreen()
        }

        self.window?.makeKeyAndVisible()
    }

    private func setRootViewControllerBasedOnAuthority(isSwitchOn: Bool, adminIsSwitchOn: Bool) {
        let authority = KeyChain.shared.read(key: Const.KeyChainKey.authority)

        DispatchQueue.main.async {
            if authority == "ROLE_STUDENT_COUNCIL" {
                let adminMainVC = AdminMainViewController()
                let navigationController = UINavigationController(rootViewController: adminMainVC)
                self.window?.rootViewController = navigationController

                if adminIsSwitchOn {
                    print("Admin Screen: AdminMainViewController with AdminQRViewController")
                    let adminQRVC = AdminQRViewController()
                    navigationController.pushViewController(adminQRVC, animated: false)
                } else {
                    print("Admin Screen: AdminMainViewController")
                }
            } else if authority == "ROLE_STUDENT" {
                let navigationController = UINavigationController(rootViewController: MainViewController())
                self.window?.rootViewController = navigationController

                if isSwitchOn {
                    print("Student Screen: StudentQRViewController")
                    let qrVC = StudentQRViewController()
                    navigationController.pushViewController(qrVC, animated: false)
                } else {
                    print("Student Screen: MainViewController")
                }
            } else {
                self.showLoginScreen()
            }
        }
    }

    private func showLoginScreen() {
        DispatchQueue.main.async {
            self.window?.rootViewController = UINavigationController(rootViewController: IntroViewController())
        }
    }

    private func applySavedTheme() {
        let savedThemeValue = UserDefaults.standard.integer(forKey: "selectedTheme")
        let savedTheme = UIUserInterfaceStyle(rawValue: savedThemeValue) ?? .unspecified
        window?.overrideUserInterfaceStyle = savedTheme

        if let rootViewController = window?.rootViewController as? UserProfileViewController {
            rootViewController.updateThemeText()
        }
    }

    private func checkForUpdates(completion: @escaping (Bool) -> Void) {
        guard let bundleID = Bundle.main.bundleIdentifier else {
            completion(false)
            return
        }

        let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleID)")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let appStoreVersion = results.first?["version"] as? String {

                    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                    if let currentVersion = currentVersion, currentVersion.compare(appStoreVersion, options: .numeric) == .orderedAscending {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            } catch {
                completion(false)
            }
        }
        task.resume()
    }

    private func showUpdatePopup() {
        guard let rootVC = self.window?.rootViewController else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            GOMSAlert.show(
                in: rootVC,
                title: "업데이트 알림",
                message: "더 나은 서비스를 위해 곰스가 수정되었어요!\n원활한 사용을 위해 업데이트 후 이용해주세요!",
                actionTitle: "확인",
                cancelTitle: "",
                action: {
                    if let url = URL(string: "https://apps.apple.com/kr/app/goms/id6502936560") {
                        UIApplication.shared.open(url)
                    }
                }
            )
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {
        #if !DEBUG
        checkForUpdates { needsUpdate in
            if needsUpdate {
                DispatchQueue.main.async {
                    self.showUpdatePopup()
                }
            }
        }
        #endif
    }

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
