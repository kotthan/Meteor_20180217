//
//  File.swift
//  Meteor
//
//  Created by Kazuaki Oe on 2018/03/02.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

@available(iOS 9.0, *)
class Ground: SKShapeNode
{
    var Ground: SKShapeNode!
    init(frame: CGRect)
    {
        super.init()
        Ground = SKShapeNode(rect: CGRect(x: frame.width/2, y: 0.0, width: 500, height: 1))
        Ground.fillColor = UIColor.red
        Ground.name = "ground"
        Ground.position.x = 0
        Ground.position.y = 0
        Ground.zPosition = 10000
        Ground.physicsBody?.categoryBitMask = 0b0001
        Ground.physicsBody?.collisionBitMask = 0b0000 | 0b0000
        Ground.physicsBody?.contactTestBitMask = 0b0100
        self.addChild(Ground)
    }
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
