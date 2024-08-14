//
//  SceneDelegate.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/16/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // 스토리보드에서 초기 뷰 컨트롤러 가져오기
        let launchStoryboard = UIStoryboard(name: "LaunchScreen", bundle: nil)

        // 스토리보드의 초기 ViewController가 SplashVC인 경우
        guard let splashVC = launchStoryboard.instantiateViewController(withIdentifier: "SplashVC") as? SplashVC else {
            fatalError("#### SplashVC not found in storyboard")
        }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = splashVC
        window.makeKeyAndVisible()
        self.window = window

        let storyboard = UIStoryboard(name: "ReadTodo", bundle: nil)

        // 새로운 뷰 컨트롤러 (ReadToDoVC)로 전환
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            guard let rootVC = storyboard.instantiateViewController(withIdentifier: "ReadToDoVC") as? ReadToDoVC else {
                fatalError("#### ReadToDoVC not found in storyboard")
            }
            let navigationController = UINavigationController(rootViewController: rootVC)
            self.window?.rootViewController = navigationController
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
