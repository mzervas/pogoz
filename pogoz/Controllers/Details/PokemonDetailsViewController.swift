//
//  PokemonDetailsViewController.swift
//  pogoz
//
//  Created by Merri Zervas on 12/30/21.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import SDWebImage
import RxSwift
import RxDataSources

class PokemonDetailsViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 150)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(PokemonCollectionViewCell.self, forCellWithReuseIdentifier: "defCell")
        view.allowsSelection = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        
        return view
    }()
    
    var viewModel: PokemonDetailsViewModel
    
    private var bag = DisposeBag()
    
    init(viewModel: PokemonDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        setTitleLabel()
        setCollectionView()
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        
        viewModel.output.titleText
            .bind(to: titleLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.output.dataSource
            .bind(to: collectionView.rx
                    .items(cellIdentifier: "defCell", cellType: PokemonCollectionViewCell.self)) { _, imageName, cell in
                cell.set(name: String(imageName))
            }.disposed(by: bag)
    }
}

// MARK: UI Setup

extension PokemonDetailsViewController {
    
    private func setProperties() {
        view.backgroundColor = .black
    }
    
    private func setTitleLabel() {
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.top.equalTo(200)
        }
    }
    
    private func setCollectionView() {
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().inset(50)
            make.top.equalTo(titleLabel.snp.bottom).offset(100)
            make.centerX.bottom.equalToSuperview()
        }
    }
}

extension PokemonDetailsViewController: UICollectionViewDelegate { }
