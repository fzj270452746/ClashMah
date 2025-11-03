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
    
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                if selectionOverlay == nil {
                    selectionOverlay = UIView()
                    selectionOverlay?.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
                    selectionOverlay?.translatesAutoresizingMaskIntoConstraints = false
                    addSubview(selectionOverlay!)
                    NSLayoutConstraint.activate([
                        selectionOverlay!.topAnchor.constraint(equalTo: topAnchor),
                        selectionOverlay!.leadingAnchor.constraint(equalTo: leadingAnchor),
                        selectionOverlay!.trailingAnchor.constraint(equalTo: trailingAnchor),
                        selectionOverlay!.bottomAnchor.constraint(equalTo: bottomAnchor)
                    ])
                }
                selectionOverlay?.isHidden = false
                transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } else {
                selectionOverlay?.isHidden = true
                transform = .identity
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
        UIView.transition(with: self, duration: 0.3, options: .transitionFlipFromLeft) {
            // Animation completes
        }
    }
}

