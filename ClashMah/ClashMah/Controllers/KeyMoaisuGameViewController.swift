

import UIKit
import Combine

final class KeyMoaisuGameViewController: UIViewController {

    // MARK: - UI Components

    private let mainContainerView = UIView()
    private let backButton = UIButton(type: .system)
    private let scoreLabel = UILabel()
    private let playerLabel = UILabel()
    private let playerHandStackView = UIStackView()
    private let middleLabel = UILabel()
    private let middlePoolStackView = UIStackView()
    private let aiLabel = UILabel()
    private let aiHandStackView = UIStackView()
    private let statusLabel = UILabel()
    private let skipButton = UIButton(type: .system)

    private var playerCardViews: [ThreshCardView] = []
    private var middleCardViews: [ThreshCardView] = []
    private var aiCardViews: [ThreshCardView] = []

    // MARK: - Layout Properties

    private var cardSize: CGSize = CGSize(width: 60, height: 90)
    private var cardSpacing: CGFloat = 8

    // MARK: - Visual Effects

    private var gradientLayer: CAGradientLayer?
    private var particleLayer: CAEmitterLayer?

    // MARK: - View Model

    private let viewModel: GameViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        calculateCardLayout()
        configureUI()
        bindViewModel()
        viewModel.startNewGame()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        recalculateLayoutIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientFrame()
    }

    // MARK: - UI Configuration

    private func configureUI() {
        view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        setupGradientBackground()
        setupBackButton()
        setupMainContainer()
        setupLabels()
        setupHandViews()
        setupStatusAndControls()
        setupConstraints()
    }

    private func setupGradientBackground() {
        let gradient = CAGradientLayer()
        // 游戏页面使用更深沉但更鲜艳的紫蓝渐变，与首页呼应
        gradient.colors = [
            UIColor(red: 0.10, green: 0.05, blue: 0.30, alpha: 1.0).cgColor,  // 深紫
            UIColor(red: 0.25, green: 0.10, blue: 0.45, alpha: 1.0).cgColor,  // 鲜艳紫
            UIColor(red: 0.12, green: 0.18, blue: 0.50, alpha: 1.0).cgColor,  // 蓝紫
            UIColor(red: 0.08, green: 0.12, blue: 0.35, alpha: 1.0).cgColor,  // 深蓝紫
            UIColor(red: 0.18, green: 0.08, blue: 0.40, alpha: 1.0).cgColor   // 紫红
        ]
        gradient.locations = [0.0, 0.25, 0.5, 0.75, 1.0]
        gradient.frame = view.bounds
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient

        // 添加背景动画
        animateBackgroundGradient()
    }

    private func animateBackgroundGradient() {
        let animation = CABasicAnimation(keyPath: "colors")
        animation.duration = 8.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.fromValue = gradientLayer?.colors
        animation.toValue = [
            UIColor(red: 0.12, green: 0.18, blue: 0.50, alpha: 1.0).cgColor,
            UIColor(red: 0.30, green: 0.08, blue: 0.48, alpha: 1.0).cgColor,
            UIColor(red: 0.15, green: 0.12, blue: 0.55, alpha: 1.0).cgColor,
            UIColor(red: 0.10, green: 0.15, blue: 0.40, alpha: 1.0).cgColor,
            UIColor(red: 0.22, green: 0.05, blue: 0.45, alpha: 1.0).cgColor
        ]
        gradientLayer?.add(animation, forKey: "backgroundColorShift")
    }

    private func setupBackButton() {
        backButton.setTitle("← Back", for: .normal)
        backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        backButton.backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 0.8)
        backButton.setTitleColor(.white, for: .normal)
        backButton.layer.cornerRadius = 6
        backButton.layer.borderWidth = 2
        backButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
    }

    private func setupMainContainer() {
        mainContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainContainerView)
    }

    private func setupLabels() {
        scoreLabel.font = UIFont(name: "Avenir-Heavy", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        scoreLabel.textColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
        scoreLabel.textAlignment = .center
        scoreLabel.numberOfLines = 0
        scoreLabel.layer.shadowColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0).cgColor
        scoreLabel.layer.shadowRadius = 8
        scoreLabel.layer.shadowOpacity = 0.6
        scoreLabel.layer.shadowOffset = .zero
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        mainContainerView.addSubview(scoreLabel)

        [playerLabel, middleLabel, aiLabel].forEach { label in
            label.font = UIFont(name: "Avenir-Heavy", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
            label.textColor = UIColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0)
            label.textAlignment = .center
            label.layer.shadowColor = UIColor.cyan.cgColor
            label.layer.shadowRadius = 5
            label.layer.shadowOpacity = 0.4
            label.layer.shadowOffset = .zero
            label.translatesAutoresizingMaskIntoConstraints = false
            mainContainerView.addSubview(label)
        }

        playerLabel.text = "👤 YOUR HAND"
        middleLabel.text = "🎴 MIDDLE DECK"
        aiLabel.text = "🤖 COMPUTER HAND"
    }

    private func setupHandViews() {
        [playerHandStackView, middlePoolStackView, aiHandStackView].forEach { stackView in
            stackView.axis = .vertical
            stackView.spacing = cardSpacing
            stackView.alignment = .center
            stackView.distribution = .fillEqually
            stackView.translatesAutoresizingMaskIntoConstraints = false
            mainContainerView.addSubview(stackView)
        }
    }

    private func setupStatusAndControls() {
        statusLabel.font = UIFont(name: "Avenir-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        statusLabel.textColor = UIColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.layer.shadowColor = UIColor.white.cgColor
        statusLabel.layer.shadowRadius = 3
        statusLabel.layer.shadowOpacity = 0.3
        statusLabel.layer.shadowOffset = .zero
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        mainContainerView.addSubview(statusLabel)

        skipButton.setTitle("⏭ Skip Turn", for: .normal)
        skipButton.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)

        let buttonGradient = CAGradientLayer()
        buttonGradient.colors = [
            UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 0.9).cgColor,
            UIColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 0.8).cgColor
        ]
        buttonGradient.startPoint = CGPoint(x: 0, y: 0)
        buttonGradient.endPoint = CGPoint(x: 1, y: 1)
        buttonGradient.cornerRadius = 8

        skipButton.layer.insertSublayer(buttonGradient, at: 0)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.layer.cornerRadius = 8
        skipButton.layer.borderWidth = 2
        skipButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        skipButton.layer.shadowColor = UIColor.black.cgColor
        skipButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        skipButton.layer.shadowRadius = 8
        skipButton.layer.shadowOpacity = 0.5
        skipButton.clipsToBounds = false
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        mainContainerView.addSubview(skipButton)
    }

    private func setupConstraints() {
        let screenSize = view.bounds.size
        let isSmallDevice = screenSize.height < 700
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad

        let labelSpacing: CGFloat = isSmallDevice ? 6 : 8
        let sectionSpacing: CGFloat = isSmallDevice ? 10 : 12
        let backButtonHeight: CGFloat = isSmallDevice ? 36 : 40
        let buttonHeight: CGFloat = isSmallDevice ? 36 : 40
        let horizontalPadding: CGFloat = isIPad ? 30 : 20

        let handHeight = (cardSize.height * 2) + cardSpacing

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: isSmallDevice ? 80 : 90),
            backButton.heightAnchor.constraint(equalToConstant: backButtonHeight),

            mainContainerView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: sectionSpacing),
            mainContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            scoreLabel.topAnchor.constraint(equalTo: mainContainerView.topAnchor, constant: 4),
            scoreLabel.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: horizontalPadding),
            scoreLabel.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -horizontalPadding),
            scoreLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: isSmallDevice ? 30 : 35),

            playerLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: sectionSpacing),
            playerLabel.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: horizontalPadding),
            playerLabel.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -horizontalPadding),
            playerLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: isSmallDevice ? 18 : 20),

            playerHandStackView.topAnchor.constraint(equalTo: playerLabel.bottomAnchor, constant: labelSpacing),
            playerHandStackView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: horizontalPadding),
            playerHandStackView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -horizontalPadding),
            playerHandStackView.heightAnchor.constraint(equalToConstant: handHeight),

            middleLabel.topAnchor.constraint(equalTo: playerHandStackView.bottomAnchor, constant: sectionSpacing),
            middleLabel.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: horizontalPadding),
            middleLabel.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -horizontalPadding),
            middleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: isSmallDevice ? 18 : 20),

            middlePoolStackView.topAnchor.constraint(equalTo: middleLabel.bottomAnchor, constant: labelSpacing),
            middlePoolStackView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: horizontalPadding),
            middlePoolStackView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -horizontalPadding),
            middlePoolStackView.heightAnchor.constraint(equalToConstant: handHeight),

            aiLabel.topAnchor.constraint(equalTo: middlePoolStackView.bottomAnchor, constant: sectionSpacing),
            aiLabel.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: horizontalPadding),
            aiLabel.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -horizontalPadding),
            aiLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: isSmallDevice ? 18 : 20),

            aiHandStackView.topAnchor.constraint(equalTo: aiLabel.bottomAnchor, constant: labelSpacing),
            aiHandStackView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: horizontalPadding),
            aiHandStackView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -horizontalPadding),
            aiHandStackView.heightAnchor.constraint(equalToConstant: handHeight),

            statusLabel.topAnchor.constraint(equalTo: aiHandStackView.bottomAnchor, constant: sectionSpacing),
            statusLabel.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: horizontalPadding),
            statusLabel.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -horizontalPadding),
            statusLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: isSmallDevice ? 18 : 20),

            skipButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            skipButton.centerXAnchor.constraint(equalTo: mainContainerView.centerXAnchor),
            skipButton.widthAnchor.constraint(equalToConstant: isSmallDevice ? 120 : 140),
            skipButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            skipButton.bottomAnchor.constraint(lessThanOrEqualTo: mainContainerView.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - View Model Binding

    private func bindViewModel() {
        viewModel.$playerHand
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updatePlayerHandUI() }
            .store(in: &cancellables)

        viewModel.$aiHand
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateAIHandUI() }
            .store(in: &cancellables)

        viewModel.$middlePool
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateMiddlePoolUI() }
            .store(in: &cancellables)

        viewModel.$statusMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in self?.statusLabel.text = message }
            .store(in: &cancellables)

        viewModel.$roundNumber
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateScoreLabel() }
            .store(in: &cancellables)

        viewModel.$playerScore
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateScoreLabel() }
            .store(in: &cancellables)

        viewModel.$aiScore
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateScoreLabel() }
            .store(in: &cancellables)

        viewModel.$currentTurn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] turn in
                self?.skipButton.isEnabled = (turn == .player)
            }
            .store(in: &cancellables)

        viewModel.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in self?.handleGameEvent(event) }
            .store(in: &cancellables)
    }

    // MARK: - UI Updates

    private func updatePlayerHandUI() {
        rebuildHandView(playerHandStackView, tiles: viewModel.playerHand, showBack: false, cardViews: &playerCardViews)
    }

    private func updateAIHandUI() {
        rebuildHandView(aiHandStackView, tiles: viewModel.aiHand, showBack: true, cardViews: &aiCardViews)
    }

    private func updateMiddlePoolUI() {
        middleCardViews.forEach { $0.removeFromSuperview() }
        middleCardViews.removeAll()
        middlePoolStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let rows = 2
        let cols = 5

        for row in 0..<rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = cardSpacing
            rowStack.distribution = .fillEqually

            for col in 0..<cols {
                let index = row * cols + col
                if index < viewModel.middlePool.count {
                    let tile = viewModel.middlePool[index]
                    let cardView = createCardView(tile: tile, isBack: false)
                    cardView.tag = index
                    cardView.isSelected = (index == viewModel.selectedTileIndex)

                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(middleCardTapped(_:)))
                    cardView.addGestureRecognizer(tapGesture)
                    cardView.isUserInteractionEnabled = true

                    rowStack.addArrangedSubview(cardView)
                    middleCardViews.append(cardView)
                }
            }

            middlePoolStackView.addArrangedSubview(rowStack)
        }
    }

    private func updateScoreLabel() {
        scoreLabel.text = "Player: \(viewModel.playerScore) | AI: \(viewModel.aiScore) | Round: \(viewModel.roundNumber)"
    }

    private func rebuildHandView(_ stackView: UIStackView, tiles: [ZephyrTile], showBack: Bool, cardViews: inout [ThreshCardView]) {
        cardViews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let rows = 2
        let cols = 5

        for row in 0..<rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = cardSpacing
            rowStack.distribution = .fillEqually

            for col in 0..<cols {
                let index = row * cols + col
                if index < tiles.count {
                    let tile = tiles[index]
                    let cardView = createCardView(tile: showBack ? nil : tile, isBack: showBack)
                    rowStack.addArrangedSubview(cardView)
                    cardViews.append(cardView)
                } else {
                    let spacer = UIView()
                    rowStack.addArrangedSubview(spacer)
                }
            }

            stackView.addArrangedSubview(rowStack)
        }
    }

    // MARK: - Game Events

    private func handleGameEvent(_ event: GameEvent) {
        switch event {
        case .roundCompleted(let winner):
            handleRoundCompletion(winner: winner)
        case .gameCompleted(let winner, _):
            handleGameCompletion(winner: winner)
        default:
            break
        }
    }

    private func handleRoundCompletion(winner: PlayerType) {
        XerathDialogView.show(
            in: view,
            title: "Round Complete",
            message: "\(winner.displayName) won this round!",
            buttons: [("Next Round", { [weak self] in
                self?.viewModel.startNewRound()
            })]
        )
    }

    private func handleGameCompletion(winner: PlayerType) {
        let message = "\(winner.displayName) won the game!\n\nFinal Score:\nPlayer: \(viewModel.playerScore)\nAI: \(viewModel.aiScore)"

        XerathDialogView.show(
            in: view,
            title: "Game Over",
            message: message,
            buttons: [
                ("Play Again", { [weak self] in
                    self?.viewModel.startNewGame()
                }),
                ("Home", { [weak self] in
                    self?.dismiss(animated: true)
                })
            ]
        )
    }

    // MARK: - Actions

    @objc private func middleCardTapped(_ gesture: UITapGestureRecognizer) {
        guard let cardView = gesture.view as? ThreshCardView else { return }
        viewModel.selectTile(at: cardView.tag)
    }

    @objc private func skipButtonTapped() {
        viewModel.skipTurn()
    }

    @objc private func backButtonTapped() {
        XerathDialogView.show(
            in: view,
            title: "Exit Game",
            message: "Are you sure you want to exit?",
            buttons: [
                ("Yes, Exit", { [weak self] in
                    self?.dismiss(animated: true)
                }),
                ("Cancel", {})
            ]
        )
    }

    // MARK: - Layout Helpers

    private func calculateCardLayout() {
        let screenSize = view.bounds.size
        let safeAreaTop = view.safeAreaInsets.top
        let safeAreaBottom = view.safeAreaInsets.bottom
        let availableHeight = screenSize.height - safeAreaTop - safeAreaBottom

        // Determine device type
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let isSmallDevice = screenSize.height < 700 // iPhone SE, etc.

        // Proper spacing for labels and sections
        let labelSpacing: CGFloat = isSmallDevice ? 6 : 8
        let sectionSpacing: CGFloat = isSmallDevice ? 10 : 12

        // Reserve space for fixed UI elements first - these are NON-NEGOTIABLE
        let backButtonHeight: CGFloat = isSmallDevice ? 36 : 40
        let challengeScoreHeight: CGFloat = 40 // Always reserve space
        let labelHeight: CGFloat = isSmallDevice ? 20 : 22
        let statusHeight: CGFloat = isSmallDevice ? 20 : 24
        let buttonHeight: CGFloat = isSmallDevice ? 36 : 40

        // Calculate ALL fixed elements height FIRST (this is priority)
        // We need: back button + spacing + challenge score + spacing
        // + 3 labels (player, middle, computer) + 3 label spacings
        // + status label + spacing + button + bottom padding
        let fixedElementsHeight = backButtonHeight + sectionSpacing +
            challengeScoreHeight + sectionSpacing +
            (labelHeight * 3) + (labelSpacing * 3) + // 3 labels with spacing
            statusHeight + sectionSpacing + buttonHeight + 12

        // Now calculate available space for cards - cards are flexible
        let availableForCards = max(availableHeight - fixedElementsHeight, 80) // Minimum space for cards

        // IMPORTANT: Set card spacing first before calculating card dimensions
        cardSpacing = isSmallDevice ? 5 : (isIPad ? 10 : 6)

        // Calculate card dimensions - cards should be smaller to leave room for labels
        let handRows = 2
        let handCols = 5 // Always use max cols for layout calculation
        let middleCols = 5

        // Calculate max card width based on screen width
        let horizontalPadding: CGFloat = isIPad ? 60 : 40
        let maxCardWidthForHand = (screenSize.width - horizontalPadding - (cardSpacing * CGFloat(handCols - 1))) / CGFloat(handCols)
        let maxCardWidthForMiddle = (screenSize.width - horizontalPadding - (cardSpacing * CGFloat(middleCols - 1))) / CGFloat(middleCols)
        let maxCardWidth = min(maxCardWidthForHand, maxCardWidthForMiddle)

        // Calculate card height based on available vertical space
        // We have: player hand (2 rows) + middle deck (2 rows) + computer hand (2 rows) = 6 rows total
        let totalCardRows: CGFloat = 6
        let verticalSpacingActual = cardSpacing * CGFloat(totalCardRows - 1)
        let maxCardHeight = max((availableForCards - verticalSpacingActual) / totalCardRows, 25) // Minimum 25pt height

        // Determine final card size - prioritize fitting everything over card size
        let aspectRatio: CGFloat = 1.5 // height / width
        var cardWidth = min(maxCardWidth, maxCardHeight / aspectRatio)
        var cardHeight = cardWidth * aspectRatio

        // Ensure cards fit in available space - reduce if needed
        let totalCardHeight = cardHeight * totalCardRows + verticalSpacingActual
        if totalCardHeight > availableForCards {
            // Reduce card height to fit
            cardHeight = max((availableForCards - verticalSpacingActual) / totalCardRows, 25)
            cardWidth = cardHeight / aspectRatio
        }

        // Further reduce card size to ensure labels always fit
        // Cards should not take more than 70% of available height - leave 30% for safety margin
        let maxCardAreaHeight = availableForCards * 0.70
        if totalCardHeight > maxCardAreaHeight {
            cardHeight = max((maxCardAreaHeight - verticalSpacingActual) / totalCardRows, 25)
            cardWidth = cardHeight / aspectRatio
        }

        cardSize = CGSize(width: cardWidth, height: cardHeight)
    }

    private func recalculateLayoutIfNeeded() {
        let oldSize = cardSize
        calculateCardLayout()
        if abs(oldSize.width - cardSize.width) > 0.1 {
            updateCardSizes()
        }
    }

    private func updateCardSizes() {
        (playerCardViews + middleCardViews + aiCardViews).forEach { cardView in
            cardView.constraints.forEach { constraint in
                if constraint.firstAttribute == .width {
                    constraint.constant = cardSize.width
                } else if constraint.firstAttribute == .height {
                    constraint.constant = cardSize.height
                }
            }
        }
    }

    private func createCardView(tile: ZephyrTile?, isBack: Bool) -> ThreshCardView {
        let cardView = ThreshCardView(frame: .zero)
        cardView.configure(with: tile, isBack: isBack)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardView.widthAnchor.constraint(equalToConstant: cardSize.width),
            cardView.heightAnchor.constraint(equalToConstant: cardSize.height)
        ])

        return cardView
    }

    private func updateGradientFrame() {
        gradientLayer?.frame = view.bounds

        // Update skip button gradient
        if let buttonGradient = skipButton.layer.sublayers?.first as? CAGradientLayer {
            buttonGradient.frame = skipButton.bounds
        }
    }
}
