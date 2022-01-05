//
//  MainTableViewViewModel.swift
//  MGoesZ
//
//  Created by Merri Zervas on 12/19/21.
//

import Foundation
import pogozServices
import RxSwift
import RxCocoa

public protocol PokemonDetailsViewDelegate: AnyObject {
    func showPokemonDetails(for pokemon: PokemonShinyDetails)
}

class MainTableViewViewModel {
    
    struct Input {
        let didSelectSuggestion: AnyObserver<IndexPath>
        let didUpdateSearchText: AnyObserver<String?>
        let didPressSearch: AnyObserver<String>
        let didBeginEditing: AnyObserver<Void>
        let cancelButtonClicked: AnyObserver<Void>
    }
    
    struct Output {
        let dataSource: Observable<[PokemonShinyDetails]>
    }
    
    let input: Input
    let output: Output
    
    // Input
    private let didSelectSuggestion = PublishSubject<IndexPath>()
    private let didUpdateSearchText = PublishSubject<String?>()
    private let didPressSearch = PublishSubject<String>()
    private let didBeginEditing = PublishSubject<Void>()
    private let cancelButtonClicked = PublishSubject<Void>()

    // Output
    let dataSource = BehaviorRelay<[PokemonShinyDetails]>(value: [])
    
    weak var delegate: PokemonDetailsViewDelegate?
    
    private let pokemonManager: PokemonManager
    private let bag = DisposeBag()
    
    init(pokemonManager: PokemonManager) {
        self.pokemonManager = pokemonManager
        self.input = Input(didSelectSuggestion: didSelectSuggestion.asObserver(), didUpdateSearchText: didUpdateSearchText.asObserver(),
                           didPressSearch: didPressSearch.asObserver(), didBeginEditing: didBeginEditing.asObserver(), cancelButtonClicked: cancelButtonClicked.asObserver())
        self.output = Output(dataSource: dataSource.asObservable())
        
        pokemonManager.getPokemonNames()
        
        pokemonManager.shinyDetails
            .subscribe(onNext: { [weak self] shinyDetails in
                self?.resetDataSource()
            }).disposed(by: bag)
        
        didBeginEditing
            .subscribe(onNext: { [weak self] in
                self?.resetDataSource()
            }).disposed(by: bag)
        
        didUpdateSearchText
            .throttle(.milliseconds(300), scheduler: SharingScheduler.make())
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.resetDataSource()
                
                let filteredDataSource = self.dataSource.value.filter { $0.name.lowercased().contains(text?.lowercased() ?? "") }
                self.dataSource.accept(filteredDataSource)
            }).disposed(by: bag)
        
        cancelButtonClicked.subscribe(onNext: { [weak self] in
            self?.resetDataSource()
        }).disposed(by: bag)
        
        didSelectSuggestion.subscribe(onNext: { [weak self] indexPath in
            guard let self = self else { return }
            let pokemon = self.dataSource.value[indexPath.row]
            self.delegate?.showPokemonDetails(for: pokemon)
        }).disposed(by: bag)
        
//        pokemonManager.shinyDetails
//            .subscribe(onNext: { [weak self] pokemon in
//                if let list = pokemon {
//                    self?.dataSource.onNext(list)
//                }
//            }).disposed(by: bag)

//        pokemonManager.sansRxGetPokemonNames() { pokedex in
//            print("!!! \(pokedex["1"]?.name)")
//        }
    }
    
    func resetDataSource() {
        let shinyDetails = pokemonManager.shinyDetails.value.keys
        let dataSource = shinyDetails.compactMap { pokemonManager.shinyDetails.value[$0] }.sorted(by: { $0.name < $1.name })
        self.dataSource.accept(dataSource)
    }
}
