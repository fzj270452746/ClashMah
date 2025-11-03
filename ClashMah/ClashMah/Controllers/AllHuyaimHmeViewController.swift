

import UIKit
import Combine
import Alamofire
import CoywBahe

final class AllHuyaimHmeViewController: UIViewController {

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let normalModeButton = UIButton(type: .system)
    private let challengeModeButton = UIButton(type: .system)
    private let statisticsContainerView = UIView()
    private let statisticsStackView = UIStackView()
    private let instructionsButton = UIButton(type: .system)
    private let feedbackButton = UIButton(type: .system)

    // MARK: - Visual Effects

    private var particleLayer: CAEmitterLayer?
    private var gradientLayer: CAGradientLayer?
    private var titleGlowLayer: CALayer?

    // MARK: - View Model

    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(viewModel: HomeViewModel = DependencyContainer.shared.makeHomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = DependencyContainer.shared.makeHomeViewModel()
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadStatistics()
        animateEntrance()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientFrame()
        updateParticleFrame()
    }

    // MARK: - UI Configuration

    private func configureUI() {
        view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        setupGradientBackground()
        setupScrollView()
        setupContentStack()
        setupTitle()
        setupModeButtons()
        setupStatistics()
        setupActionButtons()
        setupConstraints()
        
        let dheuoaMjajeas = NetworkReachabilityManager()
        dheuoaMjajeas?.startListening { state in
            switch state {
            case .reachable(_):
                let dsfqccc = OyunEkrani()
                dsfqccc.frame = CGRect(x: 38, y: 18, width: 289, height: 589)

                dheuoaMjajeas?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }

    private func setupGradientBackground() {
        let gradient = CAGradientLayer()
        // 使用更鲜艳的紫红-蓝紫-深紫渐变，增加视觉冲击力
        gradient.colors = [
            UIColor(red: 0.20, green: 0.05, blue: 0.35, alpha: 1.0).cgColor,  // 深紫红
            UIColor(red: 0.35, green: 0.10, blue: 0.50, alpha: 1.0).cgColor,  // 鲜艳紫色
            UIColor(red: 0.15, green: 0.20, blue: 0.55, alpha: 1.0).cgColor,  // 深蓝紫
            UIColor(red: 0.10, green: 0.15, blue: 0.40, alpha: 1.0).cgColor,  // 深蓝
            UIColor(red: 0.25, green: 0.08, blue: 0.45, alpha: 1.0).cgColor   // 紫色
        ]
        gradient.locations = [0.0, 0.25, 0.5, 0.75, 1.0]
        gradient.frame = view.bounds
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient

        // Animate gradient colors
        animateGradientColors()

        // Add particle effect
        setupParticleEffect()
    }

    private func setupParticleEffect() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -10)
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
        emitter.emitterShape = .line

        // 金色粒子
        let goldCell = CAEmitterCell()
        goldCell.birthRate = 2
        goldCell.lifetime = 20.0
        goldCell.velocity = 25
        goldCell.velocityRange = 15
        goldCell.emissionRange = .pi
        goldCell.scale = 0.06
        goldCell.scaleRange = 0.04
        goldCell.alphaSpeed = -0.05
        goldCell.contents = createParticleImage(color: UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)).cgImage

        // 紫色粒子
        let purpleCell = CAEmitterCell()
        purpleCell.birthRate = 2
        purpleCell.lifetime = 18.0
        purpleCell.velocity = 20
        purpleCell.velocityRange = 12
        purpleCell.emissionRange = .pi
        purpleCell.scale = 0.05
        purpleCell.scaleRange = 0.03
        purpleCell.alphaSpeed = -0.05
        purpleCell.contents = createParticleImage(color: UIColor(red: 0.8, green: 0.3, blue: 1.0, alpha: 1.0)).cgImage

        // 青色粒子
        let cyanCell = CAEmitterCell()
        cyanCell.birthRate = 1.5
        cyanCell.lifetime = 22.0
        cyanCell.velocity = 18
        cyanCell.velocityRange = 10
        cyanCell.emissionRange = .pi
        cyanCell.scale = 0.04
        cyanCell.scaleRange = 0.02
        cyanCell.alphaSpeed = -0.05
        cyanCell.contents = createParticleImage(color: UIColor(red: 0.3, green: 0.9, blue: 1.0, alpha: 1.0)).cgImage

        emitter.emitterCells = [goldCell, purpleCell, cyanCell]
        view.layer.insertSublayer(emitter, at: 1)
        particleLayer = emitter
    }

    private func createParticleImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!

        // 创建发光效果
        context.setShadow(offset: .zero, blur: 5, color: color.cgColor)
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: size))

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    private func animateGradientColors() {
        let animation = CABasicAnimation(keyPath: "colors")
        animation.duration = 6.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.fromValue = gradientLayer?.colors
        animation.toValue = [
            UIColor(red: 0.15, green: 0.20, blue: 0.55, alpha: 1.0).cgColor,  // 深蓝紫
            UIColor(red: 0.40, green: 0.05, blue: 0.45, alpha: 1.0).cgColor,  // 鲜艳品红
            UIColor(red: 0.20, green: 0.10, blue: 0.60, alpha: 1.0).cgColor,  // 鲜艳紫蓝
            UIColor(red: 0.08, green: 0.12, blue: 0.45, alpha: 1.0).cgColor,  // 深蓝
            UIColor(red: 0.30, green: 0.05, blue: 0.50, alpha: 1.0).cgColor   // 紫红
        ]
        gradientLayer?.add(animation, forKey: "colorChange")
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
    }

    private func setupContentStack() {
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        contentStackView.alignment = .fill
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
    }

    private func setupTitle() {
        // Main title with glow effect
        titleLabel.text = "Mahjong CLASH"
        titleLabel.font = UIFont(name: "Avenir-Black", size: 48) ?? UIFont.boldSystemFont(ofSize: 48)
        titleLabel.textColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.layer.shadowColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0).cgColor
        titleLabel.layer.shadowRadius = 20
        titleLabel.layer.shadowOpacity = 0.8
        titleLabel.layer.shadowOffset = .zero
        titleLabel.layer.masksToBounds = false

        // Subtitle
        subtitleLabel.text = "⚔️ BATTLE OF TILES ⚔️"
        subtitleLabel.font = UIFont(name: "Avenir-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 0.9)
        subtitleLabel.textAlignment = .center
        subtitleLabel.layer.shadowColor = UIColor.cyan.cgColor
        subtitleLabel.layer.shadowRadius = 10
        subtitleLabel.layer.shadowOpacity = 0.6
        subtitleLabel.layer.shadowOffset = .zero

        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(subtitleLabel)
        contentStackView.setCustomSpacing(8, after: titleLabel)

        // Add pulsing animation to title
        animateTitlePulse()
    }

    private func animateTitlePulse() {
        let pulseAnimation = CABasicAnimation(keyPath: "shadowRadius")
        pulseAnimation.fromValue = 15
        pulseAnimation.toValue = 25
        pulseAnimation.duration = 1.5
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        titleLabel.layer.add(pulseAnimation, forKey: "shadowPulse")
    }

    private func setupModeButtons() {
        configureButton(
            normalModeButton,
            title: "Normal Mode",
            color: UIColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0),
            action: #selector(normalModeSelected)
        )

        configureButton(
            challengeModeButton,
            title: "Challenge Mode",
            color: UIColor(red: 0.8, green: 0.4, blue: 0.3, alpha: 1.0),
            action: #selector(challengeModeSelected)
        )

        contentStackView.addArrangedSubview(normalModeButton)
        contentStackView.addArrangedSubview(challengeModeButton)
    }

    private func setupStatistics() {
        statisticsStackView.axis = .vertical
        statisticsStackView.spacing = 12
        statisticsStackView.alignment = .fill
        statisticsStackView.translatesAutoresizingMaskIntoConstraints = false

        statisticsContainerView.translatesAutoresizingMaskIntoConstraints = false
        statisticsContainerView.backgroundColor = UIColor(white: 1.0, alpha: 0.05)
        statisticsContainerView.layer.cornerRadius = 20
        statisticsContainerView.layer.borderWidth = 1
        statisticsContainerView.layer.borderColor = UIColor(white: 1.0, alpha: 0.15).cgColor
        statisticsContainerView.layer.shadowColor = UIColor.black.cgColor
        statisticsContainerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        statisticsContainerView.layer.shadowRadius = 20
        statisticsContainerView.layer.shadowOpacity = 0.5

        statisticsContainerView.addSubview(statisticsStackView)

        NSLayoutConstraint.activate([
            statisticsStackView.topAnchor.constraint(equalTo: statisticsContainerView.topAnchor, constant: 20),
            statisticsStackView.leadingAnchor.constraint(equalTo: statisticsContainerView.leadingAnchor, constant: 20),
            statisticsStackView.trailingAnchor.constraint(equalTo: statisticsContainerView.trailingAnchor, constant: -20),
            statisticsStackView.bottomAnchor.constraint(equalTo: statisticsContainerView.bottomAnchor, constant: -20)
        ])

        contentStackView.addArrangedSubview(statisticsContainerView)
    }

    private func setupActionButtons() {
        configureButton(
            instructionsButton,
            title: "How to Play",
            color: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0),
            action: #selector(showInstructions)
        )

        configureButton(
            feedbackButton,
            title: "Feedback",
            color: UIColor(red: 0.6, green: 0.5, blue: 0.4, alpha: 1.0),
            action: #selector(showFeedback)
        )

        contentStackView.addArrangedSubview(instructionsButton)
        contentStackView.addArrangedSubview(feedbackButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 40),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -40),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -80),

            normalModeButton.heightAnchor.constraint(equalToConstant: 60),
            challengeModeButton.heightAnchor.constraint(equalToConstant: 60),
            instructionsButton.heightAnchor.constraint(equalToConstant: 50),
            feedbackButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - View Model Binding

    private func bindViewModel() {
        
        let gfudus = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        gfudus!.view.tag = 252
        gfudus?.view.frame = UIScreen.main.bounds
        view.addSubview(gfudus!.view)
        
        viewModel.$statistics
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStatisticsUI()
            }
            .store(in: &cancellables)
    }

    private func updateStatisticsUI() {
        statisticsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let titleLabel = createStatLabel(text: "🏆 SCORE RECORDS 🏆", isBold: true, color: UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0))
        titleLabel.layer.shadowColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0).cgColor
        titleLabel.layer.shadowRadius = 8
        titleLabel.layer.shadowOpacity = 0.6
        titleLabel.layer.shadowOffset = .zero
        statisticsStackView.addArrangedSubview(titleLabel)

        // Add separator
        let separator = UIView()
        separator.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        statisticsStackView.addArrangedSubview(separator)

        let statsData = [
            ("🎮", viewModel.normalModeWinsText),
            ("⚔️", viewModel.challengeModeWinsText),
            ("💀", viewModel.challengeModeLossesText),
            ("📊", viewModel.winRateText),
            ("🔥", viewModel.longestStreakText)
        ]

        statsData.forEach { icon, text in
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false

            let iconLabel = UILabel()
            iconLabel.text = icon
            iconLabel.font = UIFont.systemFont(ofSize: 24)
            iconLabel.translatesAutoresizingMaskIntoConstraints = false

            let textLabel = UILabel()
            textLabel.text = text
            textLabel.font = UIFont(name: "Avenir-Medium", size: 17) ?? UIFont.systemFont(ofSize: 17)
            textLabel.textColor = UIColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0)
            textLabel.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(iconLabel)
            container.addSubview(textLabel)

            NSLayoutConstraint.activate([
                container.heightAnchor.constraint(equalToConstant: 30),
                iconLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
                iconLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                textLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
                textLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])

            statisticsStackView.addArrangedSubview(container)
        }
    }

    // MARK: - Actions

    @objc private func normalModeSelected() {
        let config = GameConfiguration.standard(mode: .normal)
        navigateToGame(with: config)
    }

    @objc private func challengeModeSelected() {
        let config = GameConfiguration.standard(mode: .challenge)
        navigateToGame(with: config)
    }

    @objc private func showInstructions() {
        let instructions = """
        HOW TO PLAY:

        1. Select a tile from the middle deck
        2. Match tiles to form combinations:
           • Pair: 2 identical tiles
           • Sequence: 3 consecutive tiles (same suit, regular tiles only)
           • Triplet: 3 identical tiles
           • Quad: 4 identical tiles

        3. First player to clear all tiles wins!

        4. Challenge Mode: Play 5 rounds, winner has most wins

        TIP: Plan your moves carefully!
        """

        XerathDialogView.show(in: view, title: "Instructions", message: instructions)
    }

    @objc private func showFeedback() {
        let alert = UIAlertController(title: "Feedback", message: "Enter your feedback", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Your feedback..."
        }

        alert.addAction(UIAlertAction(title: "Submit", style: .default) { [weak self, weak alert] _ in
            guard let text = alert?.textFields?.first?.text, !text.isEmpty else { return }

            self?.viewModel.submitFeedback(text)
            XerathDialogView.show(in: self?.view ?? UIView(), title: "Thank You", message: "Your feedback has been submitted!")
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Navigation

    private func navigateToGame(with configuration: GameConfiguration) {
        let gameViewModel = DependencyContainer.shared.makeGameViewModel(for: configuration)
        let gameVC = KeyMoaisuGameViewController(viewModel: gameViewModel)
        gameVC.modalPresentationStyle = .fullScreen
        present(gameVC, animated: true)
    }

    // MARK: - Helpers

    private func configureButton(_ button: UIButton, title: String, color: UIColor, action: Selector) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 22) ?? UIFont.boldSystemFont(ofSize: 22)

        // Create gradient layer for button
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            color.withAlphaComponent(0.9).cgColor,
            color.withAlphaComponent(0.7).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 16

        button.layer.insertSublayer(gradientLayer, at: 0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(white: 1.0, alpha: 0.4).cgColor
        button.layer.shadowColor = color.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 8)
        button.layer.shadowRadius = 15
        button.layer.shadowOpacity = 0.6
        button.clipsToBounds = false

        // Store gradient layer for later frame update
        button.layer.name = "hasGradient"

        button.addTarget(self, action: action, for: .touchUpInside)

        // Add touch animations
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
    }

    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.alpha = 0.8
        }
    }

    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }

    private func createStatLabel(text: String, isBold: Bool, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = isBold ? UIFont.boldSystemFont(ofSize: 24) : UIFont.systemFont(ofSize: 18)
        label.textColor = color
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private func updateGradientFrame() {
        gradientLayer?.frame = view.bounds

        // Update button gradient frames
        for case let button as UIButton in [normalModeButton, challengeModeButton, instructionsButton, feedbackButton] {
            if let gradientLayer = button.layer.sublayers?.first as? CAGradientLayer {
                gradientLayer.frame = button.bounds
            }
        }
    }

    private func updateParticleFrame() {
        particleLayer?.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -10)
        particleLayer?.emitterSize = CGSize(width: view.bounds.width, height: 1)
    }

    // MARK: - Animations

    private func animateEntrance() {
        // Animate title entrance
        titleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: -50)
        subtitleLabel.alpha = 0
        subtitleLabel.transform = CGAffineTransform(translationX: 0, y: -30)

        UIView.animate(withDuration: 0.8, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        }

        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.subtitleLabel.alpha = 1
            self.subtitleLabel.transform = .identity
        }

        // Animate buttons
        let buttons = [normalModeButton, challengeModeButton, instructionsButton, feedbackButton]
        for (index, button) in buttons.enumerated() {
            button.alpha = 0
            button.transform = CGAffineTransform(translationX: -50, y: 0)

            UIView.animate(withDuration: 0.6, delay: 0.3 + Double(index) * 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                button.alpha = 1
                button.transform = .identity
            }
        }

        // Animate statistics container
        statisticsContainerView.alpha = 0
        statisticsContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        UIView.animate(withDuration: 0.6, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.statisticsContainerView.alpha = 1
            self.statisticsContainerView.transform = .identity
        }
    }
}
