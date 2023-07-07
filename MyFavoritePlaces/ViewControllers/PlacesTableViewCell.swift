//
//  PlacesTableViewCell.swift
//  MyFavoritePlaces
//
//  Created by алексей ганзицкий on 17.02.2023.
//

import UIKit
import Cosmos

class PlacesTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel! 
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace.clipsToBounds = true
        }
    }
    var cosmosView = CosmosView()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setCosmosView()
        setConfigCosmosview()
    }
    
   private func setCosmosView() {
        contentView.addSubview(cosmosView)
        cosmosView.translatesAutoresizingMaskIntoConstraints = false
         let right = NSLayoutConstraint(item: cosmosView,
                                                 attribute: .trailing,
                                                 relatedBy: .equal,
                                                 toItem: contentView,
                                                 attribute: .trailing,
                                                 multiplier: 1,
                                                 constant: -10)
        let bottom = NSLayoutConstraint(item: cosmosView,
                                                attribute: .bottom,
                                                relatedBy: .equal,
                                                toItem: contentView,
                                                attribute: .bottom,
                                                multiplier: 1,
                                                constant: 0)
        let heigh = NSLayoutConstraint(item: cosmosView,
                                                attribute: .height,
                                                relatedBy: .equal,
                                                toItem: contentView,
                                                attribute: .height,
                                                multiplier: 0.25,
                                                constant: 0)
        let wibth = NSLayoutConstraint(item: cosmosView,
                                                attribute: .width,
                                                relatedBy: .equal,
                                                toItem: contentView,
                                                attribute: .width,
                                                multiplier: 0.25,
                                                constant: 0)
        NSLayoutConstraint.activate([right,bottom,heigh,wibth])
    }
    
   private func setConfigCosmosview() {
        cosmosView.settings.starSize = 16
        cosmosView.settings.starMargin = 3
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.emptyBorderColor = .black
        cosmosView.settings.filledBorderColor = .black
    }
}
