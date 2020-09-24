//
//  HistoryHeaderView.swift
//  BinanceChallenge
//
//  Created by Vlad Berkuta on 24.09.2020.
//  Copyright © 2020 Vlad Berkuta. All rights reserved.
//

import UIKit

class HistoryHeaderView: UIView {
    private enum Const {
        static let timeRelativeWidth: CGFloat = 0.3
        static let quantityRelativeWidth: CGFloat = 0.25
    }
    
    private enum Strings {
        static let time = "Time"
        static let price = "Price"
        static let quantity = "Quantity"
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let timeLabel = UILabel(text: Strings.time)
        let priceLabel = UILabel(text: Strings.price)
        let quantityLabel = UILabel(text: Strings.quantity)
        
        for label in [timeLabel, priceLabel, quantityLabel] {
            addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
         timeLabel.topAnchor.constraint(equalTo: topAnchor),
         timeLabel.widthAnchor.constraint(equalTo: widthAnchor,
                                          multiplier: Const.timeRelativeWidth),
         timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
         
         priceLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor),
         priceLabel.topAnchor.constraint(equalTo: timeLabel.topAnchor),
         priceLabel.widthAnchor.constraint(equalTo: timeLabel.widthAnchor),
         priceLabel.bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor),
         
         quantityLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
         quantityLabel.topAnchor.constraint(equalTo: timeLabel.topAnchor),
         quantityLabel.bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor),
         quantityLabel.widthAnchor.constraint(equalTo: widthAnchor,
                                              multiplier: Const.quantityRelativeWidth)
            
        ].activate()
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
