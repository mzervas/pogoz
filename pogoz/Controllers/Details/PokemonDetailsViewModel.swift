//
//  PokemonDetailsViewModel.swift
//  pogoz
//
//  Created by Merri Zervas on 12/30/21.
//

import RxSwift
import RxCocoa
import pogozServices

class PokemonDetailsViewModel {
    
    struct Input { }
    
    struct Output {
        let titleText: Observable<String>
        let dataSource: Observable<[String.SubSequence]>
    }
    
    let input: Input
    let output: Output
    
    // Input
    
    // Output
    let titleText = BehaviorSubject<String>(value: "")
    let dataSource = BehaviorRelay<[String.SubSequence]>(value: [])

    let pokemonShinyDetails: PokemonShinyDetails
    
    init(pokemonShinyDetails: PokemonShinyDetails) {
        self.pokemonShinyDetails = pokemonShinyDetails
        
        self.input = Input()
        self.output = Output(titleText: titleText.asObservable(), dataSource: dataSource.asObservable())
        
        // dataSource
        let all = Bundle.main.paths(forResourcesOfType: "png", inDirectory: nil)
        var files = all.compactMap { $0.split(separator: "/").last }
        
        files = files.filter({ String($0).contains("pokemon_icon_\(String(format: "%03d", pokemonShinyDetails.id))") })
        dataSource.accept(files.sorted())
        
        // pokemon title
        titleText.onNext(pokemonShinyDetails.name)
    }
}

extension NSRegularExpression {
    
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
    
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}

extension String {
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
}
