//
//  Item.swift
//  tax-manager
//
//  Created by Murat AKMAMEDAU on 29.08.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
