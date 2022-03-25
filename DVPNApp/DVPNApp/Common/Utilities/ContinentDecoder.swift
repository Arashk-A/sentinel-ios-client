//
//  ContinentDecoder.swift
//  DVPNApp
//
//  Created by Victoria Kostyleva on 22.10.2021.
//

import Foundation
import SentinelWallet

// MARK: - ContinentDecoder

final class ContinentDecoder {
    static let shared = ContinentDecoder()
    
    private var countryCodeToContinent: [String: String] = [:]
    
    init() {
        let fileName = "co.exidio.sentinellite.regional.countries_extras"
        guard let countriesExtraURL = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return
        }
        do {
            let countriesExtraData = try Data(contentsOf: countriesExtraURL, options: [])
            let countriesExtra = try JSONDecoder().decode([CountryExtra].self, from: countriesExtraData)
            
            for countryExtra in countriesExtra {
                countryCodeToContinent[countryExtra.alpha2.uppercased()] = countryExtra.continent
            }
        } catch {}
    }
    
    func getContinent(for node: Node) -> Continent? {
        let continentCode = countryCodeToContinent[
            CountryFormatter.code(for: node.info.location.country) ?? ""
        ]
        
        guard let continentCode = continentCode else {
            return nil
        }
        
        return Continent(rawValue: continentCode)
    }
}

// MARK: - CountryExtra

struct CountryExtra: Codable {
    let alpha2: String
    let capital: String?
    let area: String?
    let population: String?
    let continent: String
}
