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
        backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        // Container
        containerView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 3
        containerView.layer.borderColor = UIColor(red: 0.8, green: 0.7, blue: 0.4, alpha: 1.0).cgColor
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.5
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // Title label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = UIColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Message label
        messageLabel.font = UIFont.systemFont(ofSize: 18)
        messageLabel.textColor = .white
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
    
    func configure(title: String, message: String) {
        titleLabel.text = title
        messageLabel.text = message
    }
    
    func addButton(title: String, action: @escaping () -> Void) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor(red: 0.8, green: 0.7, blue: 0.4, alpha: 1.0)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        button.addAction(UIAction { _ in
            action()
            self.dismiss()
        }, for: .touchUpInside)
        
        stackView.addArrangedSubview(button)
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
        
        dialog.alpha = 0
        UIView.animate(withDuration: 0.3) {
            dialog.alpha = 1
        }
        
        return dialog
    }
}

