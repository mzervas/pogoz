//
//  AppCoordinator.swift
//  pogoz
//
//  Created by Merri Zervas on 12/19/21.
//

import Foundation
import UIKit
import pogozServices

class AppCoordinator: NSObject, UINavigationControllerDelegate {
    
    lazy var navigationController = UINavigationController()
    
    lazy var mainViewController = MainTableViewController(viewModel: mainViewModel)
    
    lazy var mainViewModel = MainTableViewViewModel(pokemonManager: pokemonManager)
    
    var window: UIWindow
    
    let pokemonManager = PokemonManager()
        
    init(window: UIWindow) {
        self.window = window
        super.init()
        navigationController.delegate = self

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func start() {
        mainViewModel.delegate = self
        navigationController.pushViewController(mainViewController, animated: true)
    }
}

extension AppCoordinator: PokemonDetailsViewDelegate {
    
    func showPokemonDetails(for pokemon: PokemonShinyDetails) {
        let viewModel = PokemonDetailsViewModel(pokemonShinyDetails: pokemon)
        navigationController.pushViewController(PokemonDetailsViewController(viewModel: viewModel), animated: true)
    }
}
