
import UIKit
import AppTrackingTransparency

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let portalWindow = UIWindow(windowScene: windowScene)
        let menuController = PortalMenuViewController()
        let navigationWrapper = UINavigationController(rootViewController: menuController)
        navigationWrapper.setNavigationBarHidden(true, animated: false)

        portalWindow.rootViewController = navigationWrapper
        portalWindow.makeKeyAndVisible()
        self.window = portalWindow
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
    }
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
