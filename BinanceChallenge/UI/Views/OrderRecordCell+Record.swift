//
//  OrderRecordCell+Record.swift
//  BinanceChallenge
//
//  Created by Vlad Berkuta on 29.09.2020.
//  Copyright © 2020 Vlad Berkuta. All rights reserved.
//

import UIKit

extension OrderRecordCell {
    func configure(with record: Record) {
        if let bidQuantity = record.bid?.quantity {
            self.bidQuantity = NumberFormatter.quantityFormatter.string(for: bidQuantity)
        }
        if let bidPrice = record.bid?.price {
            self.bidPrice = NumberFormatter.priceFormatter.string(for: bidPrice)
        }
        if let askPrice = record.ask?.price {
            self.askPrice = NumberFormatter.priceFormatter.string(for: askPrice)
        }
        if let askQuantity = record.ask?.quantity {
            self.askQuantity = NumberFormatter.quantityFormatter.string(for: askQuantity)
        }
    }
}
