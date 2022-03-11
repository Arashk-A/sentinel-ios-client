//
//  Formatters.swift
//  DVPNApp
//
//  Created by Lika Vorobyeva on 9.08.2021.
//

import Foundation
import SentinelWallet

private struct Constants {
    let denomFull = "udvpn"
    let denomShort = "dvpn"
}

private let constants = Constants()

// MARK: - PriceFormatter

enum PriceFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 0
        formatter.decimalSeparator = "."

        return formatter
    }()
    
    static func fullFormat(amount: Int) -> String {
        prettyFormat(amount: Double(amount), denom: "")
    }
    
    static func fullFormat(amount: String, denom: String, fee: Double? = nil) -> String {
        var amount = Double(amount) ?? 0
        if let fee = fee {
            amount += fee
        }
        
        return prettyFormat(amount: amount, denom: denom)
    }

    /// - Parameter price: Amount with denom
    static func fullFormat(price: String, fee: Double? = nil) -> String {
        let denom = price.components(separatedBy: CharacterSet.decimalDigits).joined()
        var amount = Double(price.components(separatedBy: CharacterSet.letters).joined()) ?? 0
        if let fee = fee {
            amount += fee
        }

        return prettyFormat(amount: amount, denom: denom)
    }

    static func rawFormat(price: String) -> (denom: String, price: Int) {
        let denom = price.components(separatedBy: CharacterSet.decimalDigits).joined()
        let amount = price.components(separatedBy: CharacterSet.letters).joined()
        let price = denom == constants.denomFull ? Int(amount) : (Int(amount) ?? 0 * 1_000_000)
        return (constants.denomFull, price ?? 0)
    }
}

// MARK: - Private PriceFormatter func

extension PriceFormatter {
    private static func convertUDVPNtoDVPN(amount: Double) -> String {
        formatter.string(from: NSNumber(value: amount * 0.000001)) ?? "?"
    }
    
    private static func prettyFormat(amount: Double, denom: String) -> String {
        // For this moment we use dvpn only
        let denomString = denom == constants.denomShort ? " " + constants.denomShort.uppercased() : ""
        return PriceFormatter.convertUDVPNtoDVPN(amount: amount) + denomString
    }
}

// MARK: - CountryFormatter

enum CountryFormatter {
    static func code(for fullCountryName: String) -> String? {
        NSLocale.isoCountryCodes.first(where: { code in
            let identifier = NSLocale(localeIdentifier: "en_US")
            let countryName = identifier.displayName(forKey: NSLocale.Key.countryCode, value: code)
            return fullCountryName.lowercased() == countryName?.lowercased()
        })
    }
}

// MARK: - TimeFormatter

enum TimeFormatter {
    static func duration(from interval: Double) -> String {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_US")
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.allowedUnits = [.year, .month, .day]
        formatter.unitsStyle = .full

        return formatter.string(from: interval) ?? ""
    }
}
