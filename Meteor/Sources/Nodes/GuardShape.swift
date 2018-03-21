//
//  GuardShape.swift
//  Meteor
//
//  Created by Ryota on 2018/03/19.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class GuardShape: SKShapeNode {
    
    init(size: CGSize){
        super.init()
        self.name = "guardShape"
        self.setzPos(.GuardShape)
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.affectedByGravity = false      //重力判定を無視
        self.physicsBody?.isDynamic = false              //固定物に設定
        self.physicsBody?.categoryBitMask = 0b100000     //接触判定用マスク設定
        self.physicsBody?.collisionBitMask = 0b0000      //接触対象をなしに設定
        self.physicsBody?.contactTestBitMask = 0b1000    //接触対象をmeteorに設定
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
