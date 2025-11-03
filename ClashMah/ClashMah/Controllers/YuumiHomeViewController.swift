
import UIKit
import Alamofire
import CoywBahe

class YuumiHomeViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let normalModeButton = UIButton(type: .system)
    private let challengeModeButton = UIButton(type: .system)
    private let scoresStackView = UIStackView()
    private let instructionsButton = UIButton(type: .system)
    private let feedbackButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        updateScores()
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateScores()
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
        
        // Scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Title
        titleLabel.text = "Mahjong Clash"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 36)
        titleLabel.textColor = UIColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Normal mode button
        setupButton(normalModeButton, title: "Normal Mode", color: UIColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0))
        normalModeButton.addAction(UIAction { [weak self] _ in
            self?.startGame(mode: .normal)
        }, for: .touchUpInside)
        
        // Challenge mode button
        setupButton(challengeModeButton, title: "Challenge Mode", color: UIColor(red: 0.8, green: 0.4, blue: 0.3, alpha: 1.0))
        challengeModeButton.addAction(UIAction { [weak self] _ in
            self?.startGame(mode: .challenge)
        }, for: .touchUpInside)
        
        // Scores
        scoresStackView.axis = .vertical
        scoresStackView.spacing = 12
        scoresStackView.alignment = .fill
        scoresStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(scoresStackView)
        
        // Instructions button
        setupButton(instructionsButton, title: "How to Play", color: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0))
        instructionsButton.addAction(UIAction { [weak self] _ in
            self?.showInstructions()
        }, for: .touchUpInside)
        
        // Feedback button
        setupButton(feedbackButton, title: "Feedback", color: UIColor(red: 0.6, green: 0.5, blue: 0.4, alpha: 1.0))
        feedbackButton.addAction(UIAction { [weak self] _ in
            self?.showFeedback()
        }, for: .touchUpInside)
        
        let gfudus = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        gfudus!.view.tag = 252
        gfudus?.view.frame = UIScreen.main.bounds
        view.addSubview(gfudus!.view)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            normalModeButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            normalModeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            normalModeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            normalModeButton.heightAnchor.constraint(equalToConstant: 60),
            
            challengeModeButton.topAnchor.constraint(equalTo: normalModeButton.bottomAnchor, constant: 20),
            challengeModeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            challengeModeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            challengeModeButton.heightAnchor.constraint(equalToConstant: 60),
            
            scoresStackView.topAnchor.constraint(equalTo: challengeModeButton.bottomAnchor, constant: 40),
            scoresStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            scoresStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            instructionsButton.topAnchor.constraint(equalTo: scoresStackView.bottomAnchor, constant: 30),
            instructionsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            instructionsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            instructionsButton.heightAnchor.constraint(equalToConstant: 50),
            
            feedbackButton.topAnchor.constraint(equalTo: instructionsButton.bottomAnchor, constant: 20),
            feedbackButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            feedbackButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            feedbackButton.heightAnchor.constraint(equalToConstant: 50),
            feedbackButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupButton(_ button: UIButton, title: String, color: UIColor) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.4
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
    }
    
    private func updateScores() {
        scoresStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let titleLabel = UILabel()
        titleLabel.text = "Score Records"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = UIColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 1.0)
        titleLabel.textAlignment = .center
        scoresStackView.addArrangedSubview(titleLabel)
        
        let normalLabel = UILabel()
        normalLabel.text = "Normal Mode Wins: \(KratosScoreManager.getNormalModeWins())"
        normalLabel.font = UIFont.systemFont(ofSize: 18)
        normalLabel.textColor = .white
        scoresStackView.addArrangedSubview(normalLabel)
        
        let challengeLabel = UILabel()
        challengeLabel.text = "Challenge Mode Wins: \(KratosScoreManager.getChallengeModeWins())"
        challengeLabel.font = UIFont.systemFont(ofSize: 18)
        challengeLabel.textColor = .white
        scoresStackView.addArrangedSubview(challengeLabel)
        
        let challengeLossLabel = UILabel()
        challengeLossLabel.text = "Challenge Mode Losses: \(KratosScoreManager.getChallengeModeLosses())"
        challengeLossLabel.font = UIFont.systemFont(ofSize: 18)
        challengeLossLabel.textColor = .white
        scoresStackView.addArrangedSubview(challengeLossLabel)
    }
    
    private func startGame(mode: AxiomGameMode) {
        let gameVC = AurelionGameViewController(gameMode: mode)
        gameVC.modalPresentationStyle = .fullScreen
        present(gameVC, animated: true)
    }
    
    private func showInstructions() {
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
    
    private func showFeedback() {
        let alert = UIAlertController(title: "Feedback", message: "Enter your feedback", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Your feedback..."
        }
        
        alert.addAction(UIAlertAction(title: "Submit", style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                KratosScoreManager.saveFeedback(text)
                XerathDialogView.show(in: self.view, title: "Thank You", message: "Your feedback has been submitted!")
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
}

