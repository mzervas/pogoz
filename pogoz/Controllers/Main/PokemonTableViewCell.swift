//
//  PokemonTableViewCell.swift
//  pogoz
//
//  Created by Merri Zervas on 12/28/21.
//

import UIKit
import RxSwift
import pogozServices
import SnapKit

class PokemonTableViewCell: UITableViewCell {
    
    lazy var image: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "shiny"))
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
        
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width, height: 50)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentConfiguration = nil
        accessoryView = .none
    }
    
    func configure(viewModel: PokemonShinyDetails) {
        var content = defaultContentConfiguration()
        
        if viewModel.foundEgg || viewModel.foundEvolution
            || viewModel.foundPhotobomb || viewModel.foundRaid
            || viewModel.foundWild || viewModel.foundResearch {
            accessoryView = image
            accessoryView?.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        }
        
        content.text = viewModel.name
        content.textProperties.color = .white
        contentConfiguration = content
    }
}

// MARK: UI Setup

extension PokemonTableViewCell {
    
    private func setProperties() {
        backgroundColor = .black
    }
    
    private func setImageView() {
        contentView.addSubview(image)
        
        image.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5)
            make.right.bottom.equalToSuperview().inset(5)
        }
    }
}
