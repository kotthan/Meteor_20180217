//
//  File.swift
//  Meteor
//
//  Created by Kazuaki Oe on 2018/03/02.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

@available(iOS 9.0, *)
class Ground: SKNode
{
    var Ground: SKShapeNode!
    init(frame: CGRect)
    {
        super.init()
        let GroundY: CGFloat = 145
        Ground = SKShapeNode(rect: CGRect(x: 0, y: GroundY, width: frame.size.width, height: 1))
        Ground.fillColor = UIColor.clear
        Ground.strokeColor = UIColor.clear
        Ground.name = "ground"
        Ground.setzPos(.Ground)
        Ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: Ground.frame.size.width, height: Ground.frame.size.height),center: CGPoint(x: 0 + frame.size.width/2, y: GroundY))
        Ground.physicsBody?.isDynamic = false
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
