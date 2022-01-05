//
//  SubwayManager.swift
//  MGoesZServices
//
//  Created by Merri Zervas on 12/19/21.
//

import Foundation

enum Subway: String, CaseIterable {
    case ACE = "ace"
    case BDFM = "bdfm"
    case G = "g"
    case JZ = "jz"
    case NQRW = "nqrw"
    case L = "l"
    case NUMBERS = "1234567"
    case SIR = "si"
}

public class SubwayManager {
    
    private let subways = Subway.allCases
    
    private let networker: MGZNetworker
    
    public init() {
        self.networker = MGZNetworker()
    }
    
    public func getSubwayFeeds() {
        let urls = subways.map { URL(string: "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs-" + $0.rawValue) }
        
        if let url = urls.first, let url = url {
            networker.request(url: url)
        }
    }
    
}
