import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    showNativeSplash(over: flutterViewController.view)

    super.awakeFromNib()
  }

  private func showNativeSplash(over parentView: NSView) {
    let splashView = MacNativeSplashView()
    splashView.translatesAutoresizingMaskIntoConstraints = false
    parentView.addSubview(splashView)
    NSLayoutConstraint.activate([
      splashView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
      splashView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
      splashView.topAnchor.constraint(equalTo: parentView.topAnchor),
      splashView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
    ])
    splashView.start()
  }
}

private enum SplashPalette {
  static let secondary = NSColor(
    calibratedRed: 0x2C / 255,
    green: 0x79 / 255,
    blue: 0x69 / 255,
    alpha: 1
  )
  static let secondaryLight = NSColor(
    calibratedRed: 0x5E / 255,
    green: 0xE6 / 255,
    blue: 0xA8 / 255,
    alpha: 1
  )
  static let primarySoft = NSColor(
    calibratedRed: 0x6E / 255,
    green: 0xE7 / 255,
    blue: 0xB7 / 255,
    alpha: 1
  )
}

private final class MacNativeSplashView: NSView {
  private let logoBox = NSView()
  private let contentStack = NSStackView()
  private let cardView = NSView()
  private var dotLayers: [CALayer] = []

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    wantsLayer = true
    layer?.backgroundColor = SplashPalette.secondary.cgColor
    setupBackdrop()
    setupContent()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func start() {
    alphaValue = 0
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.28
      animator().alphaValue = 1
    }
    startLogoPulse()
    startLoadingDots()

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      guard let self else { return }
      NSAnimationContext.runAnimationGroup { context in
        context.duration = 0.22
        self.animator().alphaValue = 0
      } completionHandler: {
        self.removeFromSuperview()
      }
    }
  }

  private func setupBackdrop() {
    let field = FieldLinesView()
    field.translatesAutoresizingMaskIntoConstraints = false
    addSubview(field)
    NSLayoutConstraint.activate([
      field.leadingAnchor.constraint(equalTo: leadingAnchor),
      field.trailingAnchor.constraint(equalTo: trailingAnchor),
      field.topAnchor.constraint(equalTo: topAnchor),
      field.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

    addGlow(sizeMultiplier: 0.62, alpha: 0.16, x: 0.76, y: -0.12, color: SplashPalette.secondaryLight)
    addGlow(sizeMultiplier: 0.50, alpha: 0.42, x: -0.18, y: 0.22, color: SplashPalette.primarySoft)
    addGlow(sizeMultiplier: 0.68, alpha: 0.07, x: 0.66, y: 0.74, color: .white)
  }

  private func addGlow(sizeMultiplier: CGFloat, alpha: CGFloat, x: CGFloat, y: CGFloat, color: NSColor) {
    let glow = NSView()
    glow.wantsLayer = true
    glow.translatesAutoresizingMaskIntoConstraints = false
    let gradient = CAGradientLayer()
    gradient.type = .radial
    gradient.colors = [
      color.withAlphaComponent(alpha).cgColor,
      color.withAlphaComponent(0).cgColor,
    ]
    gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
    gradient.endPoint = CGPoint(x: 1, y: 1)
    glow.layer = gradient
    addSubview(glow, positioned: .below, relativeTo: subviews.first)
    NSLayoutConstraint.activate([
      glow.widthAnchor.constraint(equalTo: widthAnchor, multiplier: sizeMultiplier),
      glow.heightAnchor.constraint(equalTo: glow.widthAnchor),
      glow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
      glow.topAnchor.constraint(equalTo: topAnchor, constant: 0),
    ])
    glow.postsFrameChangedNotifications = true
    NotificationCenter.default.addObserver(
      forName: NSView.frameDidChangeNotification,
      object: self,
      queue: .main
    ) { [weak self, weak glow] _ in
      guard let self, let glow else { return }
      glow.frame.origin = CGPoint(x: self.bounds.width * x, y: self.bounds.height * y)
      gradient.frame = glow.bounds
    }
  }

  private func setupContent() {
    contentStack.orientation = .vertical
    contentStack.alignment = .centerX
    contentStack.spacing = 18
    contentStack.translatesAutoresizingMaskIntoConstraints = false
    addSubview(contentStack)
    NSLayoutConstraint.activate([
      contentStack.centerXAnchor.constraint(equalTo: centerXAnchor),
      contentStack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -12),
      contentStack.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.82),
      contentStack.widthAnchor.constraint(lessThanOrEqualToConstant: 430),
    ])

    buildLogo()
    contentStack.addArrangedSubview(logoBox)

    contentStack.addArrangedSubview(label("Hamro Futsal", size: 34, weight: .black, alpha: 1))

    let tagline = paddedLabel(
      "Book courts. Play harder. Manage better.",
      size: 12,
      weight: .bold,
      background: SplashPalette.secondaryLight.withAlphaComponent(0.16),
      border: SplashPalette.secondaryLight.withAlphaComponent(0.34)
    )
    contentStack.addArrangedSubview(tagline)

    buildCard()
    contentStack.addArrangedSubview(cardView)
    cardView.widthAnchor.constraint(equalTo: contentStack.widthAnchor).isActive = true

    contentStack.addArrangedSubview(label("Version \(appVersion)", size: 10, weight: .heavy, alpha: 0.9))
  }

  private func buildLogo() {
    logoBox.wantsLayer = true
    logoBox.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      logoBox.widthAnchor.constraint(equalToConstant: 168),
      logoBox.heightAnchor.constraint(equalToConstant: 168),
    ])

    let outerRing = circle(size: 162, border: SplashPalette.secondaryLight.withAlphaComponent(0.22), lineWidth: 1)
    let innerRing = circle(size: 126, border: NSColor.white.withAlphaComponent(0.14), lineWidth: 1.3)
    let logoCircle = circle(size: 104, fill: .white)
    let imageView = NSImageView(image: NSImage(named: "SplashTopLogo") ?? NSImage())
    imageView.imageScaling = .scaleProportionallyUpOrDown
    imageView.translatesAutoresizingMaskIntoConstraints = false

    [outerRing, innerRing, logoCircle].forEach {
      logoBox.addSubview($0)
      center($0, in: logoBox)
    }
    logoCircle.addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: logoCircle.leadingAnchor, constant: 18),
      imageView.trailingAnchor.constraint(equalTo: logoCircle.trailingAnchor, constant: -18),
      imageView.topAnchor.constraint(equalTo: logoCircle.topAnchor, constant: 18),
      imageView.bottomAnchor.constraint(equalTo: logoCircle.bottomAnchor, constant: -18),
    ])
  }

  private func buildCard() {
    cardView.wantsLayer = true
    cardView.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.12).cgColor
    cardView.layer?.borderColor = NSColor.white.withAlphaComponent(0.18).cgColor
    cardView.layer?.borderWidth = 1
    cardView.layer?.cornerRadius = 10
    cardView.translatesAutoresizingMaskIntoConstraints = false
    cardView.heightAnchor.constraint(equalToConstant: 112).isActive = true

    let stack = NSStackView()
    stack.orientation = .vertical
    stack.alignment = .centerX
    stack.spacing = 8
    stack.translatesAutoresizingMaskIntoConstraints = false
    cardView.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
    ])

    let dots = NSView()
    dots.wantsLayer = true
    dots.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      dots.widthAnchor.constraint(equalToConstant: 72),
      dots.heightAnchor.constraint(equalToConstant: 18),
    ])
    for index in 0..<4 {
      let dot = CALayer()
      dot.backgroundColor = (index.isMultiple(of: 2) ? SplashPalette.secondaryLight : NSColor.white).cgColor
      dot.cornerRadius = 4
      dot.frame = CGRect(x: 8 + (index * 16), y: 5, width: 8, height: 8)
      dots.layer?.addSublayer(dot)
      dotLayers.append(dot)
    }

    stack.addArrangedSubview(dots)
    stack.addArrangedSubview(label("Play or Manage", size: 14, weight: .heavy, alpha: 1))
    stack.addArrangedSubview(label("Continue as Player or Vendor", size: 11, weight: .regular, alpha: 0.8))
  }

  private func startLogoPulse() {
    let animation = CABasicAnimation(keyPath: "transform.scale")
    animation.fromValue = 0.94
    animation.toValue = 1.03
    animation.duration = 1.6
    animation.autoreverses = true
    animation.repeatCount = .infinity
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    logoBox.layer?.add(animation, forKey: "logoPulse")
  }

  private func startLoadingDots() {
    for (index, dot) in dotLayers.enumerated() {
      let animation = CAKeyframeAnimation(keyPath: "transform.scale")
      animation.values = [0.62, 1.14, 0.62]
      animation.keyTimes = [0, 0.5, 1]
      animation.duration = 1.2
      animation.beginTime = CACurrentMediaTime() + (Double(index) * 0.18)
      animation.repeatCount = .infinity
      dot.add(animation, forKey: "dotPulse")
    }
  }

  private func circle(size: CGFloat, fill: NSColor? = nil, border: NSColor? = nil, lineWidth: CGFloat = 0) -> NSView {
    let view = NSView()
    view.wantsLayer = true
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer?.cornerRadius = size / 2
    view.layer?.backgroundColor = fill?.cgColor
    view.layer?.borderColor = border?.cgColor
    view.layer?.borderWidth = lineWidth
    NSLayoutConstraint.activate([
      view.widthAnchor.constraint(equalToConstant: size),
      view.heightAnchor.constraint(equalToConstant: size),
    ])
    return view
  }

  private func center(_ child: NSView, in parent: NSView) {
    NSLayoutConstraint.activate([
      child.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
      child.centerYAnchor.constraint(equalTo: parent.centerYAnchor),
    ])
  }

  private func label(_ text: String, size: CGFloat, weight: NSFont.Weight, alpha: CGFloat) -> NSTextField {
    let label = NSTextField(labelWithString: text)
    label.font = .systemFont(ofSize: size, weight: weight)
    label.textColor = NSColor.white.withAlphaComponent(alpha)
    label.alignment = .center
    label.maximumNumberOfLines = 2
    return label
  }

  private func paddedLabel(
    _ text: String,
    size: CGFloat,
    weight: NSFont.Weight,
    background: NSColor,
    border: NSColor
  ) -> NSView {
    let box = NSView()
    box.wantsLayer = true
    box.layer?.backgroundColor = background.cgColor
    box.layer?.borderColor = border.cgColor
    box.layer?.borderWidth = 1
    box.layer?.cornerRadius = 10
    let textLabel = label(text, size: size, weight: weight, alpha: 0.92)
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    box.addSubview(textLabel)
    NSLayoutConstraint.activate([
      textLabel.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16),
      textLabel.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -16),
      textLabel.topAnchor.constraint(equalTo: box.topAnchor, constant: 9),
      textLabel.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -9),
    ])
    return box
  }

  private var appVersion: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
  }
}

private final class FieldLinesView: NSView {
  override func draw(_ dirtyRect: NSRect) {
    NSColor.white.withAlphaComponent(0.07).setStroke()
    let path = NSBezierPath(roundedRect: bounds.insetBy(dx: bounds.width * 0.04, dy: bounds.height * 0.08), xRadius: 12, yRadius: 12)
    path.lineWidth = 1
    path.stroke()

    let halfway = NSBezierPath()
    halfway.move(to: CGPoint(x: 0, y: bounds.midY))
    halfway.line(to: CGPoint(x: bounds.maxX, y: bounds.midY))
    halfway.lineWidth = 1
    halfway.stroke()

    let circle = NSBezierPath(
      ovalIn: CGRect(
        x: bounds.midX - bounds.width * 0.24,
        y: bounds.midY - bounds.width * 0.24,
        width: bounds.width * 0.48,
        height: bounds.width * 0.48
      )
    )
    circle.lineWidth = 1
    circle.stroke()
  }
}
