//
//  MainViewController.swift
//  MGoesZ
//
//  Created by Merri Zervas on 12/19/21.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxDataSources

class MainTableViewController: UIViewController {
    
    var viewModel: MainTableViewViewModel
    
    private var bag = DisposeBag()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(PokemonTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = 50
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    lazy var searchController: UISearchController = {
        let view = UISearchController(searchResultsController: nil)
        view.searchResultsUpdater = self
        view.obscuresBackgroundDuringPresentation = false
        view.searchBar.placeholder = "Search here..."
        view.searchBar.delegate = self
        return view
    }()
    
    init(viewModel: MainTableViewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setProperties()
        setTableView()
        
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.searchController = searchController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        tableView.rx.setDelegate(self)
            .disposed(by: bag)
        
        viewModel.output.dataSource
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: PokemonTableViewCell.self)) { row, model, cell in
                cell.configure(viewModel: model)
            }.disposed(by: bag)
        
        tableView.rx.itemSelected
            .bind(to: viewModel.input.didSelectSuggestion)
            .disposed(by: bag)
        
        searchController.searchBar.rx.text.orEmpty
            .bind(to: viewModel.input.didUpdateSearchText)
            .disposed(by: bag)
        
        searchController.searchBar.rx.cancelButtonClicked
            .do(onNext: { [weak self] in
                self?.tableView.reloadData()
            })
            .bind(to: viewModel.input.cancelButtonClicked)
            .disposed(by: bag)
        
        searchController.searchBar.rx.textDidBeginEditing
            .bind(to: viewModel.input.didBeginEditing)
            .disposed(by: bag)
                
        searchController.searchBar.rx.textDidEndEditing
            .bind(to: viewModel.input.didBeginEditing)
            .disposed(by: bag)
    }
}

// MARK: UI Setup

extension MainTableViewController {
    
    private func setProperties() {
        title = "pogoz"
        definesPresentationContext = true
    }
    
    private func setTableView() {
        view.addSubview(tableView)
    
        tableView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.width.centerX.equalToSuperview()
        }
    }
}

// MARK: UISearchResultsUpdating

extension MainTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        tableView.reloadData()
    }
}

// MARK: UITableViewDelegate

extension MainTableViewController: UITableViewDelegate { }

// MARK: UISearchBarDelegate

extension MainTableViewController: UISearchBarDelegate { }
