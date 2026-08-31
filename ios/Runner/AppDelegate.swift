import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

enum AppLaunchRouteResolver {
  static func resolveInitialRoute() -> String {
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


/// Colour tokens mirrored from `LightColor` in
/// android/app/src/main/kotlin/com/np/hamrofutsal/ui/splash/SplashActivity.kt.
/// Both splashes must stay pixel-identical, so change them together.
enum SplashPalette {
  static let secondary = UIColor(red: 0x2C / 255, green: 0x79 / 255, blue: 0x69 / 255, alpha: 1)
  static let secondaryLight = UIColor(red: 0x5E / 255, green: 0xE6 / 255, blue: 0xA8 / 255, alpha: 1)
  static let primarySoft = UIColor(red: 0x6E / 255, green: 0xE7 / 255, blue: 0xB7 / 255, alpha: 1)
}

/// Pitch markings drawn behind the content — the UIKit twin of Compose's
/// `FieldLinesPainter`.
private final class FieldLinesView: UIView {
  override func draw(_ rect: CGRect) {
    let lineColor = UIColor(white: 1, alpha: 0.07)
    lineColor.setStroke()

    let w = rect.width
    let h = rect.height

    let border = UIBezierPath(
      roundedRect: CGRect(x: w * 0.04, y: h * 0.08, width: w * 0.92, height: h * 0.84),
      cornerRadius: 12
    )
    border.lineWidth = 1
    border.lineCapStyle = .round
    border.stroke()

    let halfway = UIBezierPath()
    halfway.move(to: CGPoint(x: 0, y: h * 0.5))
    halfway.addLine(to: CGPoint(x: w, y: h * 0.5))
    halfway.lineWidth = 1
    halfway.stroke()

    let centreCircle = UIBezierPath(
      arcCenter: CGPoint(x: w / 2, y: h * 0.5),
      radius: w * 0.24,
      startAngle: 0,
      endAngle: .pi * 2,
      clockwise: true
    )
    centreCircle.lineWidth = 1
    centreCircle.stroke()

    // The two penalty arcs are ellipses in Compose (drawArc over a non-square
    // rect), so scale a unit circle rather than using a plain arc path.
    drawArc(in: CGRect(x: (w / 2) - (w * 0.38) / 2, y: (h * 0.08) - (h * 0.16) / 2,
                       width: w * 0.38, height: h * 0.16), from: 0, sweep: .pi)
    drawArc(in: CGRect(x: (w / 2) - (w * 0.38) / 2, y: (h * 0.92) - (h * 0.16) / 2,
                       width: w * 0.38, height: h * 0.16), from: .pi, sweep: .pi)
  }

  private func drawArc(in rect: CGRect, from startAngle: CGFloat, sweep: CGFloat) {
    let path = UIBezierPath(
      arcCenter: .zero, radius: 0.5, startAngle: startAngle,
      endAngle: startAngle + sweep, clockwise: true
    )
    var transform = CGAffineTransform(translationX: rect.midX, y: rect.midY)
    transform = transform.scaledBy(x: rect.width, y: rect.height)
    path.apply(transform)
    path.lineWidth = 1
    path.lineCapStyle = .round
    path.stroke()
  }
}

/// A soft radial bloom — the UIKit twin of Compose's `GlowCircle`.
private final class GlowView: UIView {
  override class var layerClass: AnyClass { CAGradientLayer.self }

  init(color: UIColor) {
    super.init(frame: .zero)
    isUserInteractionEnabled = false
    guard let gradient = layer as? CAGradientLayer else { return }
    gradient.type = .radial
    gradient.colors = [color.cgColor, color.withAlphaComponent(0).cgColor]
    gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
    gradient.endPoint = CGPoint(x: 1, y: 1)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

/// Native launch splash. This is a deliberate port of the Compose `SplashScreen`
/// in SplashActivity.kt — same palette, geometry, copy and animation curves — so
/// the app opens identically on both platforms. Keep the two in sync.
final class NativeSplashViewController: UIViewController {
  private let onFinish: () -> Void
  private var didFinish = false

  private let heroStack = UIStackView()
  private let logoFloatBox = UIView()
  private let logoEntryBox = UIView()
  private let logoPulseBox = UIView()
  private let outerRing = UIView()
  private let cardView = UIView()
  private var glowFloatViews: [UIView] = []
  private var dotViews: [UIView] = []

  init(onFinish: @escaping () -> Void) {
    self.onFinish = onFinish
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = SplashPalette.secondary
    setupBackdrop()
    setupContent()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    startAnimations()

    // Android navigates away after a flat 1000 ms; match it exactly. The scene
    // delegate additionally waits for Flutter's first frame before removing us.
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      guard let self, !self.didFinish else { return }
      self.didFinish = true
      self.onFinish()
    }
  }

  // MARK: - Backdrop

  private func setupBackdrop() {
    let width = view.widthAnchor

    let glow1 = GlowView(color: SplashPalette.secondaryLight.withAlphaComponent(0.16))
    let glow2 = GlowView(color: SplashPalette.primarySoft.withAlphaComponent(0.42))
    let glow3 = GlowView(color: UIColor(white: 1, alpha: 0.07))
    for glow in [glow1, glow2, glow3] {
      glow.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(glow)
    }

    // Compose expresses the glow offsets as fractions of the screen, so drive
    // the anchor constants from the live bounds in viewDidLayoutSubviews.
    let g1x = glow1.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    let g1y = glow1.topAnchor.constraint(equalTo: view.topAnchor)
    let g2x = glow2.leadingAnchor.constraint(equalTo: view.leadingAnchor)
    let g2y = glow2.topAnchor.constraint(equalTo: view.topAnchor)
    let g3x = glow3.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    let g3y = glow3.bottomAnchor.constraint(equalTo: view.bottomAnchor)

    NSLayoutConstraint.activate([
      // TopEnd, size 0.62w, offset (+0.08w, -0.12w)
      glow1.widthAnchor.constraint(equalTo: width, multiplier: 0.62),
      glow1.heightAnchor.constraint(equalTo: glow1.widthAnchor),
      g1x, g1y,

      // TopStart, size 0.5w, offset (-0.18w, +0.22h)
      glow2.widthAnchor.constraint(equalTo: width, multiplier: 0.5),
      glow2.heightAnchor.constraint(equalTo: glow2.widthAnchor),
      g2x, g2y,

      // BottomEnd, size 0.68w, offset (+0.02w, +0.2w)
      glow3.widthAnchor.constraint(equalTo: width, multiplier: 0.68),
      glow3.heightAnchor.constraint(equalTo: glow3.widthAnchor),
      g3x, g3y,
    ])

    glowOffsets = [
      (g1x, { w, _ in w * 0.08 }), (g1y, { w, _ in -w * 0.12 }),
      (g2x, { w, _ in -w * 0.18 }), (g2y, { _, h in h * 0.22 }),
      (g3x, { w, _ in w * 0.02 }), (g3y, { w, _ in w * 0.2 }),
    ]
    glowFloatViews = [glow2]

    let fieldLines = FieldLinesView()
    fieldLines.backgroundColor = .clear
    fieldLines.isUserInteractionEnabled = false
    fieldLines.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(fieldLines)
    NSLayoutConstraint.activate([
      fieldLines.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      fieldLines.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      fieldLines.topAnchor.constraint(equalTo: view.topAnchor),
      fieldLines.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  private var glowOffsets: [(NSLayoutConstraint, (CGFloat, CGFloat) -> CGFloat)] = []

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let w = view.bounds.width
    let h = view.bounds.height
    for (constraint, offset) in glowOffsets {
      constraint.constant = offset(w, h)
    }
  }

  // MARK: - Content

  private func setupContent() {
    let column = UIStackView()
    column.axis = .vertical
    column.alignment = .fill
    column.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(column)
    NSLayoutConstraint.activate([
      column.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
      column.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
      column.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      column.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])

    // Compose: Spacer(weight 1f) … hero … Spacer(weight 1f) … card … version.
    let topSpacer = UIView()
    let bottomSpacer = UIView()
    column.addArrangedSubview(topSpacer)

    buildHero()
    column.addArrangedSubview(heroStack)

    column.addArrangedSubview(bottomSpacer)
    NSLayoutConstraint.activate([
      bottomSpacer.heightAnchor.constraint(equalTo: topSpacer.heightAnchor),
    ])

    buildCard()
    column.addArrangedSubview(cardView)
    // Compose: 12dp bottom padding on the card + a 20dp spacer before the
    // version line.
    column.setCustomSpacing(32, after: cardView)

    let versionLabel = UILabel()
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let trimmed = version?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    versionLabel.text = "Version \(trimmed.isEmpty ? "1.0.0" : trimmed)"
    versionLabel.textColor = .white
    versionLabel.font = .systemFont(ofSize: 10, weight: .heavy)
    versionLabel.textAlignment = .center
    column.addArrangedSubview(versionLabel)

    let tailSpacer = UIView()
    tailSpacer.translatesAutoresizingMaskIntoConstraints = false
    tailSpacer.heightAnchor.constraint(equalToConstant: 24).isActive = true
    column.addArrangedSubview(tailSpacer)
  }

  private func buildHero() {
    heroStack.axis = .vertical
    heroStack.alignment = .center
    heroStack.alpha = 0

    logoFloatBox.translatesAutoresizingMaskIntoConstraints = false
    heroStack.addArrangedSubview(logoFloatBox)
    NSLayoutConstraint.activate([
      logoFloatBox.widthAnchor.constraint(equalToConstant: 168),
      logoFloatBox.heightAnchor.constraint(equalToConstant: 168),
    ])

    for box in [logoEntryBox, logoPulseBox] {
      box.translatesAutoresizingMaskIntoConstraints = false
    }
    logoFloatBox.addSubview(logoEntryBox)
    logoEntryBox.addSubview(logoPulseBox)
    NSLayoutConstraint.activate([
      logoEntryBox.centerXAnchor.constraint(equalTo: logoFloatBox.centerXAnchor),
      logoEntryBox.centerYAnchor.constraint(equalTo: logoFloatBox.centerYAnchor),
      logoEntryBox.widthAnchor.constraint(equalToConstant: 168),
      logoEntryBox.heightAnchor.constraint(equalToConstant: 168),
      logoPulseBox.centerXAnchor.constraint(equalTo: logoEntryBox.centerXAnchor),
      logoPulseBox.centerYAnchor.constraint(equalTo: logoEntryBox.centerYAnchor),
      logoPulseBox.widthAnchor.constraint(equalToConstant: 168),
      logoPulseBox.heightAnchor.constraint(equalToConstant: 168),
    ])

    // Outer ring: 162, 1pt border, secondaryLight @22%, independently pulsing.
    outerRing.translatesAutoresizingMaskIntoConstraints = false
    outerRing.layer.cornerRadius = 81
    outerRing.layer.borderWidth = 1
    outerRing.layer.borderColor = SplashPalette.secondaryLight.withAlphaComponent(0.22).cgColor
    logoPulseBox.addSubview(outerRing)

    // Middle ring: 126, 1.3pt border, white @14%.
    let middleRing = UIView()
    middleRing.translatesAutoresizingMaskIntoConstraints = false
    middleRing.layer.cornerRadius = 63
    middleRing.layer.borderWidth = 1.3
    middleRing.layer.borderColor = UIColor(white: 1, alpha: 0.14).cgColor
    logoPulseBox.addSubview(middleRing)

    // Logo disc: 104, white, with the secondary @28% bloom Compose draws behind
    // the artwork.
    let disc = UIView()
    disc.translatesAutoresizingMaskIntoConstraints = false
    disc.backgroundColor = .white
    disc.layer.cornerRadius = 52
    disc.clipsToBounds = true
    logoPulseBox.addSubview(disc)

    let bloom = GlowView(color: SplashPalette.secondary.withAlphaComponent(0.28))
    bloom.translatesAutoresizingMaskIntoConstraints = false
    disc.addSubview(bloom)

    let logo = UIImageView(image: UIImage(named: "SplashTopLogo"))
    logo.translatesAutoresizingMaskIntoConstraints = false
    logo.contentMode = .scaleAspectFit
    disc.addSubview(logo)

    NSLayoutConstraint.activate([
      outerRing.centerXAnchor.constraint(equalTo: logoPulseBox.centerXAnchor),
      outerRing.centerYAnchor.constraint(equalTo: logoPulseBox.centerYAnchor),
      outerRing.widthAnchor.constraint(equalToConstant: 162),
      outerRing.heightAnchor.constraint(equalToConstant: 162),

      middleRing.centerXAnchor.constraint(equalTo: logoPulseBox.centerXAnchor),
      middleRing.centerYAnchor.constraint(equalTo: logoPulseBox.centerYAnchor),
      middleRing.widthAnchor.constraint(equalToConstant: 126),
      middleRing.heightAnchor.constraint(equalToConstant: 126),

      disc.centerXAnchor.constraint(equalTo: logoPulseBox.centerXAnchor),
      disc.centerYAnchor.constraint(equalTo: logoPulseBox.centerYAnchor),
      disc.widthAnchor.constraint(equalToConstant: 104),
      disc.heightAnchor.constraint(equalToConstant: 104),

      // radius 0.65 * 104 = 67.6 → 135.2 across, centred 18pt below centre.
      bloom.centerXAnchor.constraint(equalTo: disc.centerXAnchor),
      bloom.centerYAnchor.constraint(equalTo: disc.centerYAnchor, constant: 18),
      bloom.widthAnchor.constraint(equalToConstant: 135.2),
      bloom.heightAnchor.constraint(equalToConstant: 135.2),

      // Compose pads the artwork by 18dp inside the 104dp disc.
      logo.leadingAnchor.constraint(equalTo: disc.leadingAnchor, constant: 18),
      logo.trailingAnchor.constraint(equalTo: disc.trailingAnchor, constant: -18),
      logo.topAnchor.constraint(equalTo: disc.topAnchor, constant: 18),
      logo.bottomAnchor.constraint(equalTo: disc.bottomAnchor, constant: -18),
    ])

    heroStack.setCustomSpacing(28, after: logoFloatBox)

    let titleLabel = UILabel()
    titleLabel.attributedText = NSAttributedString(
      string: "Hamro Futsal",
      attributes: [
        .font: UIFont.systemFont(ofSize: 34, weight: .black),
        .foregroundColor: UIColor.white,
        .kern: -0.8,
      ]
    )
    titleLabel.textAlignment = .center
    heroStack.addArrangedSubview(titleLabel)
    heroStack.setCustomSpacing(20, after: titleLabel)

    let pill = UIView()
    pill.translatesAutoresizingMaskIntoConstraints = false
    pill.backgroundColor = SplashPalette.secondaryLight.withAlphaComponent(0.16)
    pill.layer.cornerRadius = 10
    pill.layer.borderWidth = 1
    pill.layer.borderColor = SplashPalette.secondaryLight.withAlphaComponent(0.34).cgColor
    heroStack.addArrangedSubview(pill)

    let tagline = UILabel()
    tagline.text = "Book courts. Play harder. Manage better."
    tagline.textColor = UIColor(white: 1, alpha: 0.92)
    tagline.font = .systemFont(ofSize: 12, weight: .bold)
    tagline.textAlignment = .center
    tagline.numberOfLines = 0
    tagline.translatesAutoresizingMaskIntoConstraints = false
    pill.addSubview(tagline)
    NSLayoutConstraint.activate([
      tagline.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 16),
      tagline.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -16),
      tagline.topAnchor.constraint(equalTo: pill.topAnchor, constant: 9),
      tagline.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -9),
    ])
  }

  private func buildCard() {
    cardView.translatesAutoresizingMaskIntoConstraints = false
    cardView.alpha = 0
    cardView.backgroundColor = UIColor(white: 1, alpha: 0.12)
    cardView.layer.cornerRadius = 10
    cardView.layer.borderWidth = 1
    cardView.layer.borderColor = UIColor(white: 1, alpha: 0.18).cgColor

    let stack = UIStackView()
    stack.axis = .vertical
    stack.alignment = .center
    stack.translatesAutoresizingMaskIntoConstraints = false
    cardView.addSubview(stack)

    let dotsRow = UIStackView()
    dotsRow.axis = .horizontal
    dotsRow.alignment = .center
    dotsRow.spacing = 8  // Compose: 4dp padding either side of each 8dp dot.
    for index in 0..<4 {
      let dot = UIView()
      dot.translatesAutoresizingMaskIntoConstraints = false
      dot.layer.cornerRadius = 4
      dot.backgroundColor = index % 2 == 0 ? SplashPalette.secondaryLight : .white
      NSLayoutConstraint.activate([
        dot.widthAnchor.constraint(equalToConstant: 8),
        dot.heightAnchor.constraint(equalToConstant: 8),
      ])
      dotsRow.addArrangedSubview(dot)
      dotViews.append(dot)
    }
    stack.addArrangedSubview(dotsRow)
    stack.setCustomSpacing(14, after: dotsRow)

    let title = UILabel()
    title.text = "Play or Manage"
    title.textColor = .white
    title.font = .systemFont(ofSize: 14, weight: .heavy)
    title.textAlignment = .center
    stack.addArrangedSubview(title)
    stack.setCustomSpacing(6, after: title)

    let subtitle = UILabel()
    subtitle.text = "Continue as Player or Vendor"
    subtitle.textColor = UIColor(white: 1, alpha: 0.8)
    subtitle.font = .systemFont(ofSize: 11, weight: .regular)
    subtitle.textAlignment = .center
    subtitle.numberOfLines = 0
    stack.addArrangedSubview(subtitle)

    NSLayoutConstraint.activate([
      // Compose applies 22/22/22/20 padding around a 112dp content box.
      stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 22),
      stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -22),
      stack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
      cardView.heightAnchor.constraint(equalToConstant: 154),
    ])
  }

  // MARK: - Animation

  private func startAnimations() {
    // contentAlpha: 0 → 1 over 820 ms, with the 24pt rise Compose applies.
    heroStack.transform = CGAffineTransform(translationX: 0, y: 24)
    UIView.animate(withDuration: 0.82, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) {
      self.heroStack.alpha = 1
      self.heroStack.transform = .identity
    }

    // cardProgress: 250 ms delay, then 850 ms alpha + 36pt rise.
    cardView.transform = CGAffineTransform(translationX: 0, y: 36)
    UIView.animate(
      withDuration: 0.85, delay: 0.25, options: [.curveEaseInOut, .allowUserInteraction]
    ) {
      self.cardView.alpha = 1
      self.cardView.transform = .identity
    }

    // logoEntryScale: 0.72 → 1 over 700 ms, held afterwards.
    let entry = CABasicAnimation(keyPath: "transform.scale")
    entry.fromValue = 0.72
    entry.toValue = 1.0
    entry.duration = 0.7
    entry.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    entry.fillMode = .both
    entry.isRemovedOnCompletion = false
    logoEntryBox.layer.add(entry, forKey: "logo_entry")

    // logoScale: 0.94 ↔ 1.03, 1600 ms, reversing — multiplies with the entry
    // scale because it lives on a nested layer, exactly as Compose composes them.
    logoPulseBox.layer.add(
      loop(keyPath: "transform.scale", from: 0.94, to: 1.03, duration: 1.6), forKey: "logo_pulse")

    // ringPulse: 0.92 ↔ 1.1 on the 162pt ring only.
    outerRing.layer.add(
      loop(keyPath: "transform.scale", from: 0.92, to: 1.1, duration: 1.6), forKey: "ring_pulse")

    // logoFloat: -9 ↔ 9pt vertical drift, shared by the logo and the second glow.
    for target in [logoFloatBox] + glowFloatViews {
      target.layer.add(
        loop(keyPath: "transform.translation.y", from: -9, to: 9, duration: 1.6), forKey: "float")
    }

    startDotAnimations()
  }

  private func loop(keyPath: String, from: CGFloat, to: CGFloat, duration: CFTimeInterval)
    -> CABasicAnimation
  {
    let animation = CABasicAnimation(keyPath: keyPath)
    animation.fromValue = from
    animation.toValue = to
    animation.duration = duration
    animation.autoreverses = true
    animation.repeatCount = .infinity
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    return animation
  }

  /// Compose drives the dots off one 1200 ms ramp, offsetting each by 0.18 of a
  /// cycle and shaping it with sin(π·p): scale 0.62…1.14, alpha 0.24…1.
  private func startDotAnimations() {
    let cycle: CFTimeInterval = 1.2
    let steps = 24

    for (index, dot) in dotViews.enumerated() {
      var scales: [CGFloat] = []
      var alphas: [CGFloat] = []
      var times: [NSNumber] = []

      for step in 0...steps {
        let phase = CGFloat(step) / CGFloat(steps)
        let progress = ((phase - CGFloat(index) * 0.18).truncatingRemainder(dividingBy: 1) + 1)
          .truncatingRemainder(dividingBy: 1)
        let wave = sin(progress * .pi)
        scales.append(0.62 + wave * 0.52)
        alphas.append(0.24 + wave * 0.76)
        times.append(NSNumber(value: Double(phase)))
      }

      let scale = CAKeyframeAnimation(keyPath: "transform.scale")
      scale.values = scales
      scale.keyTimes = times
      scale.duration = cycle
      scale.repeatCount = .infinity
      scale.calculationMode = .linear
      dot.layer.add(scale, forKey: "dot_scale")

      let opacity = CAKeyframeAnimation(keyPath: "opacity")
      opacity.values = alphas
      opacity.keyTimes = times
      opacity.duration = cycle
      opacity.repeatCount = .infinity
      opacity.calculationMode = .linear
      dot.layer.add(opacity, forKey: "dot_opacity")
    }
  }
}
