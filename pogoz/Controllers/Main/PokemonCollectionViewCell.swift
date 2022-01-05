//
//  PokemonCollectionViewCell.swift
//  pogoz
//
//  Created by Merri Zervas on 1/5/22.
//

import Foundation
import UIKit

class PokemonCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
        return imageView
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setImageView()
        setMessageLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func set(name: String) {
        if name.contains("_51") {
            if name.contains("shiny") {
                messageLabel.text = "Mega Shiny"
            } else {
                messageLabel.text = "Mega"
            }
        } else if !name.contains("00.") && !name.contains("00_shiny.") {
            if name.contains("shiny") {
                messageLabel.text = "Event Shiny"
            } else {
                messageLabel.text = "Event"
            }
        } else {
            if name.contains("shiny") {
                messageLabel.text = "Shiny"
            } else {
                messageLabel.text = "Original"
            }
        }
        
        imageView.image = UIImage(named: name)
    }
    
}

// MARK: UI Setup

extension PokemonCollectionViewCell {

    private func setImageView() {
        contentView.addSubview(imageView)

        imageView.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(100)
        }
    }
    
    private func setMessageLabel() {
        contentView.addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom)//.offset(12)
            make.centerX.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
}
