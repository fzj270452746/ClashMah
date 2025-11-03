//
//  ThreshCardView.swift
//  ClashMah
//
//  Created by Hades on 11/3/25.
//

import UIKit

class ThreshCardView: UIImageView {
    var tile: ZephyrTile?
    var isBack: Bool = false
    private var selectionOverlay: UIView?
    private var glowLayer: CALayer?

    var isSelected: Bool = false {
        didSet {
            if isSelected {
                setupSelectionEffect()
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
                    self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                }
            } else {
                removeSelectionEffect()
                UIView.animate(withDuration: 0.2) {
                    self.transform = .identity
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        contentMode = .scaleAspectFit
        clipsToBounds = false

        // Add subtle shadow to all cards
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.4

        // Add border effect
        layer.cornerRadius = 4
        layer.borderWidth = 0.5
        layer.borderColor = UIColor(white: 1.0, alpha: 0.2).cgColor
    }

    private func setupSelectionEffect() {
        if selectionOverlay == nil {
            // Create glow effect
            let glow = UIView()
            glow.backgroundColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 0.4)
            glow.layer.cornerRadius = 4
            glow.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(glow, at: 0)

            NSLayoutConstraint.activate([
                glow.topAnchor.constraint(equalTo: topAnchor),
                glow.leadingAnchor.constraint(equalTo: leadingAnchor),
                glow.trailingAnchor.constraint(equalTo: trailingAnchor),
                glow.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])

            selectionOverlay = glow

            // Add pulsing glow animation
            let pulse = CABasicAnimation(keyPath: "opacity")
            pulse.fromValue = 0.4
            pulse.toValue = 0.8
            pulse.duration = 0.8
            pulse.autoreverses = true
            pulse.repeatCount = .infinity
            glow.layer.add(pulse, forKey: "pulse")
        }

        // Enhanced shadow for selection
        layer.shadowColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0).cgColor
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.8

        selectionOverlay?.isHidden = false
    }

    private func removeSelectionEffect() {
        selectionOverlay?.isHidden = true
        selectionOverlay?.layer.removeAllAnimations()

        // Restore normal shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.4
    }
    
    func configure(with tile: ZephyrTile?, isBack: Bool = false) {
        self.tile = tile
        self.isBack = isBack
        
        if isBack {
            image = UIImage(named: "cover")
        } else if let tile = tile {
            image = UIImage(named: tile.imageName)
        }
    }
    
    func animateFlip() {
        UIView.transition(with: self, duration: 0.5, options: .transitionFlipFromLeft) {
            // Animation completes
        }
    }

    func animateEntry(delay: TimeInterval = 0) {
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

        UIView.animate(withDuration: 0.5, delay: delay, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            self.alpha = 1
            self.transform = .identity
        }
    }

    func animateRemoval(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { _ in
            completion?()
        })
    }
}

