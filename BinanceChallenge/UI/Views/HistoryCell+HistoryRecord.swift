//
//  HistoryCell+HistoryRecord.swift
//  BinanceChallenge
//
//  Created by Vlad Berkuta on 29.09.2020.
//  Copyright © 2020 Vlad Berkuta. All rights reserved.
//

import UIKit

extension HistoryCell {
    private enum Const {
        static let millisecondsPerSecond = 1_000
    }
    
    func configure(with record: HistoryRecord) {
        let date = Date(timeIntervalSince1970: TimeInterval(record.time/Const.millisecondsPerSecond))
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        time = DateComponentsFormatter.time.string(from: components)
        
        price = NumberFormatter.priceFormatter.string(for: record.price)
        quantity = NumberFormatter.quantityFormatter.string(for: record.quantity)
        
        switch record.priceChange {
        case .raise:
            priceColor = .emerald
        case .fall:
            priceColor = .reddish
        }
    }
}
