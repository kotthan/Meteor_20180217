//
//  ComboLabel.swift
//  Meteor
//
//  Created by Ryota on 2018/02/18.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class ComboLabel: SKNode {
    init(_ combo:Int) {
        super.init()
        let value = SKLabelNode("GillSansStd-ExtraBold")
        value.text = String(combo)
        velue.fontSize = 50
        let combo = SKLabelNode("GillSansStd-ExtraBold")
        combo.text = "COMBO!"
        combo.fontSize = 20
        valur.position.y += combo.fontSize
        self.addChild(value)
        self.addChild(combo)
        //アクション
        self.zPosition = 10
        let move = SKAction.moveBy(x: 0, y: +60, duration: 1)
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        let group = SKAction.group([move,fadeOut])
        let remove = SKAction.removeFromParent()
        self.run(SKAction.sequence([group,remove]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
