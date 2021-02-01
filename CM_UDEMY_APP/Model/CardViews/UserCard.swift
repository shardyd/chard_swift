//
//  UserCard.swift
//  CM_UDEMY_APP
//
//  Created by Horr on 03/12/20.
//

import Foundation
import Shuffle_iOS

class UserCard: SwipeCard {
    
    func configure(withModel model:UserCardModel) {
        content = UserCardContent(withImage: model.image)
        footer = UserCardFooterView(withTitle: "\(model.name), \(model.age)", subTitle: model.occupation)
    }

    /*func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
      let card = SwipeCard()
      card.footerHeight = 80
      card.swipeDirections = [.left, .up, .right]
      for direction in card.swipeDirections {
        card.setOverlay(TinderCardOverlay(direction: direction), forDirection: direction)
      }

      let model = cardModels[index]
      card.content = TinderCardContentView(withImage: model.image)
      card.footer = TinderCardFooterView(withTitle: "\(model.name), \(model.age)", subtitle: model.occupation)

      return card
    }*/
    
}
    
