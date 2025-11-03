//
//  AurelionGameViewController.swift
//  ClashMah
//
//  Created by Hades on 11/3/25.
//

import UIKit

class AurelionGameViewController: UIViewController {
    private var gameState: VexilGameState
    private var remainingDeck: [ZephyrTile] = []
    
    // UI Components
    private let mainContainerView = UIView()
    private let challengeScoreLabel = UILabel()
    private let playerHandContainerStackView = UIStackView()
    private let middleDeckStackView = UIStackView()
    private let computerHandContainerStackView = UIStackView()
    private let skipButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let backButton = UIButton(type: .system)
    
    private var playerCardViews: [ThreshCardView] = []
    private var middleCardViews: [ThreshCardView] = []
    private var computerCardViews: [ThreshCardView] = []
    private var selectedMiddleIndex: Int?
    private var playerPickedThisRound = false
    private var computerPickedThisRound = false
    
    // Layout properties
    private var cardSize: CGSize = CGSize(width: 60, height: 90)
    private var cardSpacing: CGFloat = 8
    private var sectionSpacing: CGFloat = 15
    
    init(gameMode: AxiomGameMode) {
        self.gameState = VexilGameState(gameMode: gameMode)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculateLayout()
        setupView()
        startNewRound()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Recalculate layout for device rotation or size changes
        let oldWidth = cardSize.width
        let oldHeight = cardSize.height
        calculateLayout()
        if abs(oldWidth - cardSize.width) > 0.1 || abs(oldHeight - cardSize.height) > 0.1 {
            updateCardSizes()
        }
    }
    
    private func calculateLayout() {
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
        let challengeScoreHeight: CGFloat = gameState.gameMode == .challenge ? (isSmallDevice ? 35 : 40) : 0
        let labelHeight: CGFloat = isSmallDevice ? 20 : 22
        let statusHeight: CGFloat = isSmallDevice ? 20 : 24
        let buttonHeight: CGFloat = isSmallDevice ? 36 : 40
        
        // Calculate ALL fixed elements height FIRST (this is priority)
        // We need: back button + spacing + challenge score (if exists) + spacing
        // + 3 labels (player, middle, computer) + 3 label spacings
        // + status label + spacing + button + bottom padding
        let fixedElementsHeight = backButtonHeight + sectionSpacing + 
            challengeScoreHeight + (challengeScoreHeight > 0 ? sectionSpacing : 0) +
            (labelHeight * 3) + (labelSpacing * 3) + // 3 labels with spacing
            statusHeight + sectionSpacing + buttonHeight + 12
        
        // Now calculate available space for cards - cards are flexible
        let availableForCards = max(availableHeight - fixedElementsHeight, 80) // Minimum space for cards
        
        // IMPORTANT: Set card spacing first before calculating card dimensions
        cardSpacing = isSmallDevice ? 5 : (isIPad ? 10 : 6)
        
        // Calculate card dimensions - cards should be smaller to leave room for labels
        let handRows = 2
        let handCols = gameState.gameMode.handColumns
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
        self.sectionSpacing = sectionSpacing
    }
    
    private func updateCardSizes() {
        for cardView in playerCardViews + middleCardViews + computerCardViews {
            for constraint in cardView.constraints {
                if constraint.firstAttribute == .width {
                    constraint.constant = cardSize.width
                } else if constraint.firstAttribute == .height {
                    constraint.constant = cardSize.height
                }
            }
        }
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        
        // Create gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0).cgColor,
            UIColor(red: 0.2, green: 0.15, blue: 0.2, alpha: 1.0).cgColor,
            UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Main container (no scrolling)
        mainContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainContainerView)
        
        // Back button
        backButton.setTitle("← Back", for: .normal)
        let isSmallDevice = view.bounds.height < 700
        backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: isSmallDevice ? 14 : 16)
        backButton.backgroundColor = UIColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 0.8)
        backButton.setTitleColor(.white, for: .normal)
        backButton.layer.cornerRadius = 6
        backButton.layer.borderWidth = 2
        backButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addAction(UIAction { [weak self] _ in
            self?.showExitConfirmation()
        }, for: .touchUpInside)
        view.addSubview(backButton)
        
        // Challenge score (only for challenge mode)
        if gameState.gameMode == .challenge {
            challengeScoreLabel.text = "Player: \(gameState.challengePlayerScore) | Computer: \(gameState.challengeComputerScore) | Round: \(gameState.challengeRound + 1)/5"
            challengeScoreLabel.font = UIFont.boldSystemFont(ofSize: isSmallDevice ? 13 : 15)
            challengeScoreLabel.textColor = UIColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 1.0)
            challengeScoreLabel.textAlignment = .center
            challengeScoreLabel.numberOfLines = 0
            challengeScoreLabel.adjustsFontSizeToFitWidth = true
            challengeScoreLabel.minimumScaleFactor = 0.7
            challengeScoreLabel.translatesAutoresizingMaskIntoConstraints = false
            mainContainerView.addSubview(challengeScoreLabel)
        }
        
        // Player hand label
        let playerLabel = UILabel()
        playerLabel.text = "Your Hand"
        playerLabel.font = UIFont.boldSystemFont(ofSize: isSmallDevice ? 13 : 15)
        playerLabel.textColor = .white
        playerLabel.translatesAutoresizingMaskIntoConstraints = false
        mainContainerView.addSubview(playerLabel)
        
        // Player hand container (grid layout)
        playerHandContainerStackView.axis = .vertical
        playerHandContainerStackView.spacing = cardSpacing
        playerHandContainerStackView.alignment = .center
        playerHandContainerStackView.distribution = .fillEqually
        playerHandContainerStackView.translatesAutoresizingMaskIntoConstraints = false
        mainContainerView.addSubview(playerHandContainerStackView)
        
        // Middle deck label
        let middleLabel = UILabel()
        middleLabel.text = "Middle Deck"
        middleLabel.font = UIFont.boldSystemFont(ofSize: isSmallDevice ? 13 : 15)
        middleLabel.textColor = .white
        middleLabel.translatesAutoresizingMaskIntoConstraints = false
        mainContainerView.addSubview(middleLabel)
        
        // Middle deck stack view (no container)
        middleDeckStackView.axis = .vertical
        middleDeckStackView.spacing = cardSpacing
        middleDeckStackView.alignment = .center
        middleDeckStackView.distribution = .fillEqually
        middleDeckStackView.translatesAutoresizingMaskIntoConstraints = false
        mainContainerView.addSubview(middleDeckStackView)
        
        // Computer hand label
        let computerLabel = UILabel()
        computerLabel.text = "Computer Hand"
        computerLabel.font = UIFont.boldSystemFont(ofSize: isSmallDevice ? 13 : 15)
        computerLabel.textColor = .white
        computerLabel.translatesAutoresizingMaskIntoConstraints = false
        mainContainerView.addSubview(computerLabel)
        
        // Computer hand container (grid layout)
        computerHandContainerStackView.axis = .vertical
        computerHandContainerStackView.spacing = cardSpacing
        computerHandContainerStackView.alignment = .center
        computerHandContainerStackView.distribution = .fillEqually
        computerHandContainerStackView.translatesAutoresizingMaskIntoConstraints = false
        mainContainerView.addSubview(computerHandContainerStackView)
        
        // Status label
        statusLabel.text = "Your turn"
        statusLabel.font = UIFont.systemFont(ofSize: isSmallDevice ? 12 : 14)
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.minimumScaleFactor = 0.8
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        mainContainerView.addSubview(statusLabel)
        
        // Skip button
        skipButton.setTitle("Skip Turn", for: .normal)
        skipButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: isSmallDevice ? 14 : 16)
        skipButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.layer.cornerRadius = 6
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.addAction(UIAction { [weak self] _ in
            self?.skipTurn()
        }, for: .touchUpInside)
        mainContainerView.addSubview(skipButton)
        
        // Calculate hand height (2 rows)
        let handHeight = (cardSize.height * 2) + cardSpacing
        let labelSpacing: CGFloat = isSmallDevice ? 6 : 8
        
        // Layout constraints with proper spacing
        var constraints: [NSLayoutConstraint] = [
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: isSmallDevice ? 80 : 90),
            backButton.heightAnchor.constraint(equalToConstant: isSmallDevice ? 36 : 40),

            mainContainerView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: sectionSpacing),
            mainContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            playerLabel.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: 20),
            playerLabel.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -20),
            playerLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: isSmallDevice ? 18 : 20),

            playerHandContainerStackView.topAnchor.constraint(equalTo: playerLabel.bottomAnchor, constant: labelSpacing),
            playerHandContainerStackView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: 20),
            playerHandContainerStackView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -20),
            playerHandContainerStackView.heightAnchor.constraint(equalToConstant: handHeight),

            middleLabel.topAnchor.constraint(equalTo: playerHandContainerStackView.bottomAnchor, constant: sectionSpacing),
            middleLabel.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: 20),
            middleLabel.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -20),
            middleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: isSmallDevice ? 18 : 20),

            middleDeckStackView.topAnchor.constraint(equalTo: middleLabel.bottomAnchor, constant: labelSpacing),
            middleDeckStackView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: 20),
            middleDeckStackView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -20),
            middleDeckStackView.heightAnchor.constraint(equalToConstant: handHeight),

            computerLabel.topAnchor.constraint(equalTo: middleDeckStackView.bottomAnchor, constant: sectionSpacing),
            computerLabel.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: 20),
            computerLabel.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -20),
            computerLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: isSmallDevice ? 18 : 20),

            computerHandContainerStackView.topAnchor.constraint(equalTo: computerLabel.bottomAnchor, constant: labelSpacing),
            computerHandContainerStackView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: 20),
            computerHandContainerStackView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -20),
            computerHandContainerStackView.heightAnchor.constraint(equalToConstant: handHeight),

            statusLabel.topAnchor.constraint(equalTo: computerHandContainerStackView.bottomAnchor, constant: sectionSpacing),
            statusLabel.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -20),
            statusLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: isSmallDevice ? 18 : 20),

            skipButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            skipButton.centerXAnchor.constraint(equalTo: mainContainerView.centerXAnchor),
            skipButton.widthAnchor.constraint(equalToConstant: isSmallDevice ? 120 : 140),
            skipButton.heightAnchor.constraint(equalToConstant: isSmallDevice ? 36 : 40),
            skipButton.bottomAnchor.constraint(lessThanOrEqualTo: mainContainerView.bottomAnchor, constant: -12)
        ]

        // Add mode-specific constraints
        if gameState.gameMode == .challenge {
            constraints.append(contentsOf: [
                challengeScoreLabel.topAnchor.constraint(equalTo: mainContainerView.topAnchor, constant: 4),
                challengeScoreLabel.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: 20),
                challengeScoreLabel.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -20),
                challengeScoreLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: isSmallDevice ? 30 : 35),
                playerLabel.topAnchor.constraint(equalTo: challengeScoreLabel.bottomAnchor, constant: sectionSpacing)
            ])
        } else {
            // Normal mode: playerLabel anchored to top of container
            constraints.append(
                playerLabel.topAnchor.constraint(equalTo: mainContainerView.topAnchor, constant: sectionSpacing)
            )
        }

        NSLayoutConstraint.activate(constraints)
    }
    
    private func startNewRound() {
        // Generate new deck
        remainingDeck = NoxusDeckManager.shared.generateFullDeck()
        
        // Deal hands
        let (playerHand, computerHand) = NoxusDeckManager.shared.dealHands(deck: &remainingDeck, handSize: gameState.gameMode.handSize)
        gameState.playerHand = playerHand
        gameState.computerHand = computerHand
        sortPlayerHand()
        
        // Deal middle deck
        gameState.middleDeck = NoxusDeckManager.shared.dealMiddleDeck(deck: &remainingDeck, count: gameState.gameMode.totalMiddleCards)
        gameState.remainingDeck = remainingDeck
        gameState.currentPlayer = .human
        selectedMiddleIndex = nil
        playerPickedThisRound = false
        computerPickedThisRound = false

        updateUI()
        updateStatusLabel()
    }
    
    private func updateUI() {
        // Clear existing views
        playerCardViews.forEach { $0.removeFromSuperview() }
        middleCardViews.forEach { $0.removeFromSuperview() }
        computerCardViews.forEach { $0.removeFromSuperview() }
        playerCardViews.removeAll()
        middleCardViews.removeAll()
        computerCardViews.removeAll()
        
        // Clear stack views
        playerHandContainerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        middleDeckStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        computerHandContainerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Update player hand (grid layout: 2 rows x 4/5 columns)
        sortPlayerHand()
        let handRows = gameState.gameMode.handRows
        let handCols = gameState.gameMode.handColumns
        
        for row in 0..<handRows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = cardSpacing
            rowStack.distribution = .fillEqually
            rowStack.alignment = .fill
            
            for col in 0..<handCols {
                let index = row * handCols + col
                if index < gameState.playerHand.count {
                    let tile = gameState.playerHand[index]
                    let cardView = createCardView(tile: tile, isBack: false)
                    rowStack.addArrangedSubview(cardView)
                    playerCardViews.append(cardView)
                } else {
                    // Add empty spacer to maintain grid layout
                    let spacer = UIView()
                    spacer.translatesAutoresizingMaskIntoConstraints = false
                    rowStack.addArrangedSubview(spacer)
                }
            }
            
            playerHandContainerStackView.addArrangedSubview(rowStack)
        }
        
        // Update middle deck
        let middleRows = gameState.gameMode.middleDeckRows
        let middleCols = gameState.gameMode.middleDeckColumns
        
        for row in 0..<middleRows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = cardSpacing
            rowStack.distribution = .fillEqually
            rowStack.alignment = .fill
            
            for col in 0..<middleCols {
                let index = row * middleCols + col
                if index < gameState.middleDeck.count {
                    let tile = gameState.middleDeck[index]
                    let cardView = createCardView(tile: tile, isBack: false)
                    cardView.tag = index
                    cardView.isSelected = (index == selectedMiddleIndex)
                    
                    if gameState.currentPlayer == .human {
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(middleCardTapped(_:)))
                        cardView.addGestureRecognizer(tapGesture)
                        cardView.isUserInteractionEnabled = true
                    } else {
                        cardView.isUserInteractionEnabled = false
                    }
                    
                    rowStack.addArrangedSubview(cardView)
                    middleCardViews.append(cardView)
                }
            }
            
            middleDeckStackView.addArrangedSubview(rowStack)
        }
        
        // Update computer hand (grid layout: 2 rows x 4/5 columns)
        for row in 0..<handRows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = cardSpacing
            rowStack.distribution = .fillEqually
            rowStack.alignment = .fill
            
            for col in 0..<handCols {
                let index = row * handCols + col
                if index < gameState.computerHand.count {
                    let cardView = createCardView(tile: nil, isBack: true)
                    rowStack.addArrangedSubview(cardView)
                    computerCardViews.append(cardView)
                } else {
                    // Add empty spacer to maintain grid layout
                    let spacer = UIView()
                    spacer.translatesAutoresizingMaskIntoConstraints = false
                    rowStack.addArrangedSubview(spacer)
                }
            }
            
            computerHandContainerStackView.addArrangedSubview(rowStack)
        }
        
        // Update challenge score
        if gameState.gameMode == .challenge {
            challengeScoreLabel.text = "Player: \(gameState.challengePlayerScore) | Computer: \(gameState.challengeComputerScore) | Round: \(gameState.challengeRound + 1)/5"
        }
    }
    
    private func createCardView(tile: ZephyrTile?, isBack: Bool) -> ThreshCardView {
        let cardView = ThreshCardView(frame: .zero)
        cardView.configure(with: tile, isBack: isBack)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.heightAnchor.constraint(equalToConstant: cardSize.height).isActive = true
        cardView.widthAnchor.constraint(equalToConstant: cardSize.width).isActive = true
        return cardView
    }
    
    @objc private func middleCardTapped(_ gesture: UITapGestureRecognizer) {
        guard let cardView = gesture.view as? ThreshCardView,
              gameState.currentPlayer == .human else { return }

        let index = cardView.tag
        guard index < gameState.middleDeck.count else { return }

        // If clicking the same card that's already selected, confirm the selection
        if selectedMiddleIndex == index {
            confirmMiddleCardSelection(at: index)
            return
        }

        // Update selection to new card (automatically deselects previous)
        updateMiddleSelection(selectedIndex: index)

        let selectedTile = gameState.middleDeck[index]

        // Check if can select this tile
        if !RivenMatchingEngine.canSelectTile(tile: selectedTile, hand: gameState.playerHand, maxHandSize: gameState.gameMode.handSize) {
            statusLabel.text = "Cannot select: Hand is full and no valid meld!"
            updateMiddleSelection(selectedIndex: nil)
            return
        }

        // Find possible melds
        let melds = RivenMatchingEngine.findPossibleMelds(hand: gameState.playerHand, selectedTile: selectedTile)

        if melds.isEmpty {
            statusLabel.text = "Selected. Tap again to pick this card."
        } else {
            let meldTypes = melds.map { meldTypeString($0.type) }.joined(separator: ", ")
            statusLabel.text = "Can form: \(meldTypes). Tap again to confirm."
        }
    }

    private func confirmMiddleCardSelection(at index: Int) {
        guard index < gameState.middleDeck.count else { return }

        let selectedTile = gameState.middleDeck[index]

        // Find possible melds
        let melds = RivenMatchingEngine.findPossibleMelds(hand: gameState.playerHand, selectedTile: selectedTile)

        if melds.isEmpty {
            // No meld possible, just add to hand if not full
            if gameState.playerHand.count < gameState.gameMode.handSize {
                gameState.playerHand.append(selectedTile)
                gameState.middleDeck.remove(at: index)
                sortPlayerHand()
                markPlayerPicked()
                updateMiddleSelection(selectedIndex: nil)
                proceedToComputerTurn()
            }
        } else {
            // Select best meld automatically
            let bestMeld = selectBestMeld(from: melds)
            executeMeld(meld: bestMeld, selectedTile: selectedTile, index: index)
        }
    }

    private func selectBestMeld(from melds: [RivenMeld]) -> RivenMeld {
        // Priority: Quad (4 tiles) > Triplet/Sequence (3 tiles) > Pair (2 tiles)
        // Within same tile count, prioritize by type: Quad > Triplet > Sequence > Pair
        let sorted = melds.sorted { meld1, meld2 in
            let count1 = meld1.tiles.count
            let count2 = meld2.tiles.count

            if count1 != count2 {
                return count1 > count2
            }

            // Same tile count, prioritize by type
            let priority1 = meldTypePriority(meld1.type)
            let priority2 = meldTypePriority(meld2.type)
            return priority1 > priority2
        }

        return sorted[0]
    }

    private func meldTypePriority(_ type: RivenMeldType) -> Int {
        switch type {
        case .quad: return 4
        case .triplet: return 3
        case .sequence: return 2
        case .pair: return 1
        }
    }

    private func proceedToComputerTurn() {
        gameState.currentPlayer = .computer
        updateUI()
        updateStatusLabel()

        // Computer turn
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.computerTurn()
        }
    }
    
    private func meldTypeString(_ type: RivenMeldType) -> String {
        switch type {
        case .pair: return "Pair"
        case .sequence: return "Sequence"
        case .triplet: return "Triplet"
        case .quad: return "Quad"
        }
    }
    
    private func executeMeld(meld: RivenMeld, selectedTile: ZephyrTile, index: Int) {
        gameState.playerHand = RivenMatchingEngine.removeMeldedTiles(from: gameState.playerHand, meld: meld)
        gameState.middleDeck.remove(at: index)
        sortPlayerHand()
        markPlayerPicked()
        updateMiddleSelection(selectedIndex: nil)

        let meldType = meldTypeString(meld.type)
        statusLabel.text = "Formed \(meldType)!"

        // Check win
        if gameState.playerHand.isEmpty {
            handleWin(player: .human)
            return
        }

        proceedToComputerTurn()
    }
    
    private func computerTurn() {
        statusLabel.text = "Computer is thinking..."

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            self.computerPickedThisRound = false

            if let moveIndex = SylasAIController.selectBestMove(hand: self.gameState.computerHand, middleDeck: self.gameState.middleDeck, maxHandSize: self.gameState.gameMode.handSize) {
                let selectedTile = self.gameState.middleDeck[moveIndex]
                let melds = RivenMatchingEngine.findPossibleMelds(hand: self.gameState.computerHand, selectedTile: selectedTile)

                if let bestMeld = SylasAIController.selectBestMeld(hand: self.gameState.computerHand, selectedTile: selectedTile) {
                    self.gameState.computerHand = RivenMatchingEngine.removeMeldedTiles(from: self.gameState.computerHand, meld: bestMeld)
                    self.gameState.middleDeck.remove(at: moveIndex)
                    self.computerPickedThisRound = true

                    let meldType = self.meldTypeString(bestMeld.type)
                    self.statusLabel.text = "Computer formed \(meldType)!"

                    if self.gameState.computerHand.isEmpty {
                        self.handleWin(player: .computer)
                        return
                    }
                } else {
                    // No meld, just add to hand if not full
                    if self.gameState.computerHand.count < self.gameState.gameMode.handSize {
                        self.gameState.computerHand.append(selectedTile)
                        self.gameState.middleDeck.remove(at: moveIndex)
                        self.computerPickedThisRound = true
                    }
                }
            }

            // Always refresh middle deck after each complete round
            // This ensures cards change when both players skip
            self.refreshFullMiddleDeck()
            self.playerPickedThisRound = false
            self.computerPickedThisRound = false
            self.gameState.currentPlayer = .human
            self.updateMiddleSelection(selectedIndex: nil)
            self.updateUI()
            self.updateStatusLabel()
        }
    }
    
    private func refreshFullMiddleDeck() {
        if !gameState.middleDeck.isEmpty {
            gameState.remainingDeck.append(contentsOf: gameState.middleDeck)
        }
        gameState.middleDeck.removeAll()
        gameState.remainingDeck.shuffle()
        
        while gameState.middleDeck.count < gameState.gameMode.totalMiddleCards && !gameState.remainingDeck.isEmpty {
            gameState.middleDeck.append(gameState.remainingDeck.removeFirst())
        }
    }
    
    private func skipTurn() {
        // Player skipped - no need to refresh here, will be done after computer turn
        gameState.currentPlayer = .computer
        playerPickedThisRound = false
        updateMiddleSelection(selectedIndex: nil)
        updateUI()
        updateStatusLabel()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.computerTurn()
        }
    }
    
    private func updateStatusLabel() {
        if gameState.currentPlayer == .human {
            statusLabel.text = "Your turn - Select a tile from middle deck"
        } else {
            statusLabel.text = "Computer's turn"
        }
    }
    
    private func sortPlayerHand() {
        let typeOrder: [ZephyrTileType: Int] = [
            .fteyd: 0,
            .vnahue: 1,
            .poels: 2,
            .oeiue: 3
        ]
        
        gameState.playerHand.sort { lhs, rhs in
            let lhsTypeOrder = typeOrder[lhs.type] ?? Int.max
            let rhsTypeOrder = typeOrder[rhs.type] ?? Int.max
            
            if lhsTypeOrder != rhsTypeOrder {
                return lhsTypeOrder < rhsTypeOrder
            }
            return lhs.value < rhs.value
        }
    }
    
    private func updateMiddleSelection(selectedIndex: Int?) {
        selectedMiddleIndex = selectedIndex
        for cardView in middleCardViews {
            cardView.isSelected = (cardView.tag == selectedIndex)
        }
    }
    
    private func markPlayerPicked() {
        playerPickedThisRound = true
    }
    
    private func handleWin(player: VexilPlayerType) {
        if gameState.gameMode == .challenge {
            if player == .human {
                gameState.challengePlayerScore += 1
            } else {
                gameState.challengeComputerScore += 1
            }
            
            gameState.challengeRound += 1
            
            if gameState.challengeRound >= 5 {
                // Challenge mode complete
                let winner = gameState.challengePlayerScore > gameState.challengeComputerScore ? "Player" : "Computer"
                let message = "Challenge Complete!\n\nFinal Score:\nPlayer: \(gameState.challengePlayerScore)\nComputer: \(gameState.challengeComputerScore)\n\nWinner: \(winner)"
                
                if gameState.challengePlayerScore > gameState.challengeComputerScore {
                    KratosScoreManager.incrementChallengeModeWin()
                } else {
                    KratosScoreManager.incrementChallengeModeLoss()
                }
                
                XerathDialogView.show(in: view, title: "Game Over", message: message, buttons: [
                    ("Play Again", { [weak self] in
                        self?.restartChallenge()
                    }),
                    ("Home", { [weak self] in
                        self?.dismiss(animated: true)
                    })
                ])
            } else {
                // Next round
                XerathDialogView.show(in: view, title: "Round \(gameState.challengeRound) Complete", message: "\(player == .human ? "You" : "Computer") won this round!", buttons: [
                    ("Next Round", { [weak self] in
                        self?.startNewRound()
                    })
                ])
            }
        } else {
            // Normal mode
            if player == .human {
                KratosScoreManager.incrementNormalModeWin()
            }
            
            let message = "\(player == .human ? "You" : "Computer") won!"
            XerathDialogView.show(in: view, title: "Game Over", message: message, buttons: [
                ("Play Again", { [weak self] in
                    self?.startNewRound()
                }),
                ("Home", { [weak self] in
                    self?.dismiss(animated: true)
                })
            ])
        }
    }
    
    private func restartChallenge() {
        gameState.challengeRound = 0
        gameState.challengePlayerScore = 0
        gameState.challengeComputerScore = 0
        startNewRound()
    }
    
    private func showExitConfirmation() {
        let message = gameState.gameMode == .challenge && gameState.challengeRound > 0 
            ? "Are you sure you want to exit? Your progress will be lost."
            : "Are you sure you want to exit?"
        
        XerathDialogView.show(in: view, title: "Exit Game", message: message, buttons: [
            ("Yes, Exit", { [weak self] in
                self?.dismiss(animated: true)
            }),
            ("Cancel", {})
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
        
        // Update layout if needed (only on first layout or significant size change)
        if cardSize.width == 60 && cardSize.height == 90 {
            calculateLayout()
            updateCardSizes()
            
            // Update hand height constraints
            let handHeight = (cardSize.height * 2) + cardSpacing
            for constraint in playerHandContainerStackView.constraints {
                if constraint.firstAttribute == .height {
                    constraint.constant = handHeight
                }
            }
            for constraint in computerHandContainerStackView.constraints {
                if constraint.firstAttribute == .height {
                    constraint.constant = handHeight
                }
            }
            for constraint in middleDeckStackView.constraints {
                if constraint.firstAttribute == .height {
                    constraint.constant = handHeight
                }
            }
            
            // Update stack view spacing
            playerHandContainerStackView.spacing = cardSpacing
            middleDeckStackView.spacing = cardSpacing
            computerHandContainerStackView.spacing = cardSpacing
        }
    }
}
