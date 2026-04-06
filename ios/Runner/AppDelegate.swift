import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private lazy var flutterEngine = FlutterEngine(name: "main_engine")

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let didFinish = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    flutterEngine.run(withEntrypoint: nil, initialRoute: resolveInitialRoute())
    GeneratedPluginRegistrant.register(with: flutterEngine)

    let splashController = NativeSplashViewController { [weak self] in
      self?.showFlutterRoot()
    }

    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = splashController
    window?.makeKeyAndVisible()

    return didFinish
  }

  private func showFlutterRoot() {
    guard let window else { return }
    let flutterController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
    UIView.transition(
      with: window,
      duration: 0.32,
      options: [.transitionCrossDissolve, .allowAnimatedContent]
    ) {
      window.rootViewController = flutterController
    }
  }

  private func resolveInitialRoute() -> String {
    let defaults = UserDefaults.standard
    guard
      let tokenJson = defaults.string(forKey: "flutter.token_model"),
      let data = tokenJson.data(using: .utf8),
      let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let accessToken = (object["access_token"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
      !accessToken.isEmpty
    else {
      return "/login"
    }
    return "/dashboard"
  }
}

private final class NativeSplashViewController: UIViewController {
  private let onFinish: () -> Void

  private let titleLabel = UILabel()
  private let taglineLabel = UILabel()
  private let versionLabel = UILabel()
  private let logoContainer = UIView()
  private let logoSymbol = UIImageView(image: UIImage(systemName: "soccerball.fill"))
  private let cardView = UIView()
  private let cardTitle = UILabel()
  private let cardSubtitle = UILabel()
  private var dotViews: [UIView] = []

  init(onFinish: @escaping () -> Void) {
    self.onFinish = onFinish
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupBackground()
    setupLogoSection()
    setupCard()
    setupVersion()
    startAnimations()

    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
      self?.onFinish()
    }
  }

  private func setupBackground() {
    view.backgroundColor = UIColor(red: 0.15, green: 0.71, blue: 0.54, alpha: 1.0)

    let gradient = CAGradientLayer()
    gradient.colors = [
      UIColor(red: 0.11, green: 0.56, blue: 0.42, alpha: 1.0).cgColor,
      UIColor(red: 0.12, green: 0.61, blue: 0.46, alpha: 1.0).cgColor,
      UIColor(red: 0.15, green: 0.71, blue: 0.54, alpha: 1.0).cgColor,
    ]
    gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
    gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
    gradient.frame = view.bounds
    view.layer.addSublayer(gradient)

    let glow1 = makeGlow(size: 240, color: UIColor(red: 0.37, green: 0.9, blue: 0.66, alpha: 0.20))
    glow1.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(glow1)
    NSLayoutConstraint.activate([
      glow1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 48),
      glow1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -48),
      glow1.widthAnchor.constraint(equalToConstant: 240),
      glow1.heightAnchor.constraint(equalToConstant: 240),
    ])

    let glow2 = makeGlow(size: 200, color: UIColor(white: 1.0, alpha: 0.12))
    glow2.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(glow2)
    NSLayoutConstraint.activate([
      glow2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -70),
      glow2.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -120),
      glow2.widthAnchor.constraint(equalToConstant: 200),
      glow2.heightAnchor.constraint(equalToConstant: 200),
    ])
  }

  private func setupLogoSection() {
    let centerStack = UIStackView()
    centerStack.axis = .vertical
    centerStack.alignment = .center
    centerStack.spacing = 20
    centerStack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(centerStack)

    logoContainer.translatesAutoresizingMaskIntoConstraints = false
    logoContainer.backgroundColor = .white
    logoContainer.layer.cornerRadius = 48
    logoContainer.layer.shadowColor = UIColor(red: 0.15, green: 0.71, blue: 0.54, alpha: 0.35).cgColor
    logoContainer.layer.shadowOpacity = 1
    logoContainer.layer.shadowRadius = 18
    logoContainer.layer.shadowOffset = CGSize(width: 0, height: 12)
    centerStack.addArrangedSubview(logoContainer)

    NSLayoutConstraint.activate([
      logoContainer.widthAnchor.constraint(equalToConstant: 96),
      logoContainer.heightAnchor.constraint(equalToConstant: 96),
    ])

    logoSymbol.translatesAutoresizingMaskIntoConstraints = false
    logoSymbol.contentMode = .scaleAspectFit
    logoSymbol.tintColor = UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0)
    logoContainer.addSubview(logoSymbol)
    NSLayoutConstraint.activate([
      logoSymbol.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
      logoSymbol.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor),
      logoSymbol.widthAnchor.constraint(equalToConstant: 44),
      logoSymbol.heightAnchor.constraint(equalToConstant: 44),
    ])

    titleLabel.text = "Hamro Futsal"
    titleLabel.textColor = .white
    titleLabel.font = .systemFont(ofSize: 34, weight: .black)
    titleLabel.textAlignment = .center
    centerStack.addArrangedSubview(titleLabel)

    let taglineContainer = UIView()
    taglineContainer.translatesAutoresizingMaskIntoConstraints = false
    taglineContainer.backgroundColor = UIColor(red: 0.37, green: 0.9, blue: 0.66, alpha: 0.20)
    taglineContainer.layer.cornerRadius = 10
    taglineContainer.layer.borderWidth = 1
    taglineContainer.layer.borderColor = UIColor(red: 0.37, green: 0.9, blue: 0.66, alpha: 0.35).cgColor
    centerStack.addArrangedSubview(taglineContainer)

    taglineLabel.text = "Book courts. Play harder. Manage better."
    taglineLabel.textColor = UIColor(white: 1.0, alpha: 0.95)
    taglineLabel.font = .systemFont(ofSize: 12, weight: .bold)
    taglineLabel.textAlignment = .center
    taglineLabel.translatesAutoresizingMaskIntoConstraints = false
    taglineContainer.addSubview(taglineLabel)

    NSLayoutConstraint.activate([
      taglineLabel.leadingAnchor.constraint(equalTo: taglineContainer.leadingAnchor, constant: 16),
      taglineLabel.trailingAnchor.constraint(equalTo: taglineContainer.trailingAnchor, constant: -16),
      taglineLabel.topAnchor.constraint(equalTo: taglineContainer.topAnchor, constant: 9),
      taglineLabel.bottomAnchor.constraint(equalTo: taglineContainer.bottomAnchor, constant: -9),
      centerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      centerStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -90),
      centerStack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
      centerStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
    ])
  }

  private func setupCard() {
    cardView.translatesAutoresizingMaskIntoConstraints = false
    cardView.backgroundColor = UIColor(white: 1.0, alpha: 0.14)
    cardView.layer.cornerRadius = 10
    cardView.layer.borderWidth = 1
    cardView.layer.borderColor = UIColor(white: 1.0, alpha: 0.20).cgColor
    view.addSubview(cardView)

    NSLayoutConstraint.activate([
      cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
      cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
      cardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -54),
      cardView.heightAnchor.constraint(equalToConstant: 132),
    ])

    let cardStack = UIStackView()
    cardStack.axis = .vertical
    cardStack.alignment = .center
    cardStack.distribution = .equalCentering
    cardStack.translatesAutoresizingMaskIntoConstraints = false
    cardView.addSubview(cardStack)

    NSLayoutConstraint.activate([
      cardStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
      cardStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
      cardStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
      cardStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18),
    ])

    let dotsRow = UIStackView()
    dotsRow.axis = .horizontal
    dotsRow.alignment = .center
    dotsRow.spacing = 8
    for idx in 0..<4 {
      let dot = UIView()
      dot.translatesAutoresizingMaskIntoConstraints = false
      dot.layer.cornerRadius = 4
      dot.backgroundColor = (idx % 2 == 0)
        ? UIColor(red: 0.37, green: 0.9, blue: 0.66, alpha: 0.8)
        : UIColor(white: 1.0, alpha: 0.85)
      NSLayoutConstraint.activate([
        dot.widthAnchor.constraint(equalToConstant: 8),
        dot.heightAnchor.constraint(equalToConstant: 8),
      ])
      dotsRow.addArrangedSubview(dot)
      dotViews.append(dot)
    }
    cardStack.addArrangedSubview(dotsRow)

    cardTitle.text = "Play or Manage"
    cardTitle.textColor = .white
    cardTitle.font = .systemFont(ofSize: 14, weight: .heavy)
    cardTitle.textAlignment = .center
    cardStack.addArrangedSubview(cardTitle)

    cardSubtitle.text = "Continue as Player or Vendor"
    cardSubtitle.textColor = UIColor(white: 1.0, alpha: 0.82)
    cardSubtitle.font = .systemFont(ofSize: 11, weight: .medium)
    cardSubtitle.textAlignment = .center
    cardSubtitle.numberOfLines = 2
    cardStack.addArrangedSubview(cardSubtitle)
  }

  private func setupVersion() {
    versionLabel.translatesAutoresizingMaskIntoConstraints = false
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    versionLabel.text = "Version \(version?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? version! : "1.0.0")"
    versionLabel.textColor = .white
    versionLabel.font = .systemFont(ofSize: 10, weight: .heavy)
    view.addSubview(versionLabel)

    NSLayoutConstraint.activate([
      versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      versionLabel.bottomAnchor.constraint(equalTo: cardView.topAnchor, constant: -20),
    ])
  }

  private func startAnimations() {
    let float = CABasicAnimation(keyPath: "position.y")
    float.byValue = 9
    float.duration = 1.6
    float.autoreverses = true
    float.repeatCount = .infinity
    float.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    logoContainer.layer.add(float, forKey: "float")

    let pulse = CABasicAnimation(keyPath: "transform.scale")
    pulse.fromValue = 0.94
    pulse.toValue = 1.03
    pulse.duration = 1.6
    pulse.autoreverses = true
    pulse.repeatCount = .infinity
    pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    logoContainer.layer.add(pulse, forKey: "pulse")

    for (index, dot) in dotViews.enumerated() {
      let delay = CFTimeInterval(index) * 0.18
      let scale = CAKeyframeAnimation(keyPath: "transform.scale")
      scale.values = [0.62, 1.14, 0.62]
      scale.keyTimes = [0, 0.5, 1]
      scale.duration = 1.2
      scale.repeatCount = .infinity
      scale.beginTime = CACurrentMediaTime() + delay
      scale.timingFunction = CAMediaTimingFunction(name: .linear)
      dot.layer.add(scale, forKey: "dot_scale_\(index)")

      let opacity = CAKeyframeAnimation(keyPath: "opacity")
      opacity.values = [0.28, 1.0, 0.28]
      opacity.keyTimes = [0, 0.5, 1]
      opacity.duration = 1.2
      opacity.repeatCount = .infinity
      opacity.beginTime = CACurrentMediaTime() + delay
      opacity.timingFunction = CAMediaTimingFunction(name: .linear)
      dot.layer.add(opacity, forKey: "dot_opacity_\(index)")
    }
  }

  private func makeGlow(size: CGFloat, color: UIColor) -> UIView {
    let glow = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
    glow.layer.cornerRadius = size / 2
    glow.backgroundColor = color
    glow.layer.blur(radius: 50)
    return glow
  }
}

private extension CALayer {
  func blur(radius: CGFloat) {
    shadowColor = backgroundColor
    shadowRadius = radius
    shadowOpacity = 1
    shadowOffset = .zero
    backgroundColor = UIColor.clear.cgColor
  }
}
