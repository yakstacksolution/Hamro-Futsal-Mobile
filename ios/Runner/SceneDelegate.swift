import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private var splashWindow: UIWindow?

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    showNativeSplash(in: scene)
  }

  private func showNativeSplash(in scene: UIScene) {
    guard let windowScene = scene as? UIWindowScene else { return }

    let overlay = UIWindow(windowScene: windowScene)
    overlay.windowLevel = .normal + 1
    overlay.backgroundColor = SplashPalette.secondary
    overlay.rootViewController = NativeSplashViewController { [weak self] in
      self?.hideNativeSplash()
    }
    overlay.isHidden = false
    splashWindow = overlay
  }

  private func hideNativeSplash() {
    guard let splashWindow else { return }
    UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut]) {
      splashWindow.alpha = 0
    } completion: { [weak self] _ in
      splashWindow.isHidden = true
      self?.splashWindow = nil
    }
  }
}
