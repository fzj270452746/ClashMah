//
//  XerathDialogView.swift
//  ClashMah
//
//  Created by Hades on 11/3/25.
//

import UIKit

class XerathDialogView: UIView {
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let stackView = UIStackView()
    
    var onDismiss: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor(white: 0, alpha: 0.90)

        // Container with vibrant gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.25, green: 0.10, blue: 0.40, alpha: 1.0).cgColor,  // 鲜艳紫
            UIColor(red: 0.18, green: 0.12, blue: 0.50, alpha: 1.0).cgColor,  // 深紫蓝
            UIColor(red: 0.30, green: 0.08, blue: 0.45, alpha: 1.0).cgColor,  // 紫红
            UIColor(red: 0.15, green: 0.15, blue: 0.48, alpha: 1.0).cgColor   // 蓝紫
        ]
        gradientLayer.locations = [0.0, 0.35, 0.65, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        containerView.layer.insertSublayer(gradientLayer, at: 0)
        containerView.layer.cornerRadius = 24
        containerView.layer.borderWidth = 3
        containerView.layer.borderColor = UIColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 0.8).cgColor

        // 外发光效果 - 金色
        containerView.layer.shadowColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0).cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.shadowRadius = 30
        containerView.layer.shadowOpacity = 0.9

        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        // 添加边框脉冲动画
        animateBorderGlow()

        // Title label with glow
        titleLabel.font = UIFont(name: "Avenir-Black", size: 28) ?? UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.layer.shadowColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0).cgColor
        titleLabel.layer.shadowRadius = 10
        titleLabel.layer.shadowOpacity = 0.8
        titleLabel.layer.shadowOffset = .zero
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Message label
        messageLabel.font = UIFont(name: "Avenir-Medium", size: 18) ?? UIFont.systemFont(ofSize: 18)
        messageLabel.textColor = UIColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Stack view
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.8),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
        
        // Tap gesture to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTapped))
        addGestureRecognizer(tapGesture)
    }
    
    private func animateBorderGlow() {
        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.fromValue = 20
        glowAnimation.toValue = 35
        glowAnimation.duration = 1.5
        glowAnimation.autoreverses = true
        glowAnimation.repeatCount = .infinity
        containerView.layer.add(glowAnimation, forKey: "borderGlow")

        let opacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        opacityAnimation.fromValue = 0.7
        opacityAnimation.toValue = 1.0
        opacityAnimation.duration = 1.5
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        containerView.layer.add(opacityAnimation, forKey: "borderOpacity")
    }

    func configure(title: String, message: String) {
        titleLabel.text = title
        messageLabel.text = message
    }
    
    func addButton(title: String, action: @escaping () -> Void) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)

        // Create gradient for button
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 0.9).cgColor,
            UIColor(red: 0.9, green: 0.75, blue: 0.2, alpha: 0.9).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 12

        button.layer.insertSublayer(gradientLayer, at: 0)
        button.setTitleColor(UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0), for: .normal)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(red: 1.0, green: 0.95, blue: 0.6, alpha: 0.8).cgColor
        button.layer.shadowColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.5
        button.clipsToBounds = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true

        button.addAction(UIAction { _ in
            // Animate button press
            UIView.animate(withDuration: 0.1, animations: {
                button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    button.transform = .identity
                }
            }

            action()
            self.dismiss()
        }, for: .touchUpInside)

        stackView.addArrangedSubview(button)

        // Update gradient frame when layout changes
        DispatchQueue.main.async {
            gradientLayer.frame = button.bounds
        }
    }
    
    @objc private func dismissTapped() {
        dismiss()
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
            self.onDismiss?()
        }
    }
    
    static func show(in view: UIView, title: String, message: String, buttons: [(String, () -> Void)] = []) -> XerathDialogView {
        let dialog = XerathDialogView()
        dialog.configure(title: title, message: message)

        for (buttonTitle, action) in buttons {
            dialog.addButton(title: buttonTitle, action: action)
        }

        if buttons.isEmpty {
            dialog.addButton(title: "OK", action: {})
        }

        dialog.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dialog)

        NSLayoutConstraint.activate([
            dialog.topAnchor.constraint(equalTo: view.topAnchor),
            dialog.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dialog.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dialog.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Animate entrance with scale and fade
        dialog.alpha = 0
        dialog.containerView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            dialog.alpha = 1
            dialog.containerView.transform = .identity
        }

        // Update gradient layer frame after layout
        DispatchQueue.main.async {
            if let gradientLayer = dialog.containerView.layer.sublayers?.first as? CAGradientLayer {
                gradientLayer.frame = dialog.containerView.bounds
            }
        }

        return dialog
    }
}

