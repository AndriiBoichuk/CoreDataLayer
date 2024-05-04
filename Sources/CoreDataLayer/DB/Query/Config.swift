//
//  Config.swift
//
//  Created by Andrii Boichuk on 02.04.2024.
//

import Foundation

public struct Config {
    public static var defaultBatchSize: Int = 20
    public static var defaultComparisonOptions: NSComparisonPredicate.Options = [.caseInsensitive, .diacriticInsensitive]
}
