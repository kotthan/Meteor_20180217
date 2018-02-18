//
//  LandingEffect.swift
//  Meteor
//
//  Created by Ryota on 2018/02/18.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class LandingEffect: SKNode {
    
    let imageName = "cloud_1"
    
    override init() {
        super.init()
        //zpositionを前に
        self.zPosition += 2
        //左右に出すスプライト生成
        let left = SKSpriteNode(imageNamed: imageName)
        let right = SKSpriteNode(imageNamed: imageName)
        //位置調整
        left.position.x -= 5
        right.position.x += 5
        left.anchorPoint.y = 0
        right.anchorPoint.y = 0
        //スケール調整
        left.setScale(0.05)
        left.xScale *= -1    //反転
        right.setScale(0.05)
        //ちょっとうすく
        left.alpha = 0.5
        right.alpha = 0.5
        //アニメーション
        let wait = SKAction.wait(forDuration: 0.0)
        let moveLeft = SKAction.moveBy(x: -60, y: 0, duration: 1)
        let moveRight = SKAction.moveBy(x: 60, y: 0, duration: 1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        let scale = SKAction.scale(by: 2.5, duration: 1)
        let removeBase = SKAction.run{self.removeFromParent()}
        let act1 = SKAction.sequence([wait,fadeOut,remove,removeBase])
        left.run(SKAction.group([act1,moveLeft,scale]))
        right.run(SKAction.group([act1,moveRight,scale]))
        self.addChild(left)
        self.addChild(right)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
