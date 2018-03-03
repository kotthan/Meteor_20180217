//
//  File.swift
//  Meteor
//
//  Created by Kazuaki Oe on 2018/03/03.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//


import SpriteKit

@available(iOS 9.0, *)
class LowestShape: SKNode
{
    var LowestShape: SKShapeNode!
    init(frame: CGRect)
    {
        super.init()
        let positionY: CGFloat = 139.125
        LowestShape = SKShapeNode(rect: CGRect(x: 0, y: positionY, width: frame.size.width, height: 1))
        LowestShape.fillColor = UIColor.clear
        LowestShape.strokeColor = UIColor.clear
        LowestShape.name = "LowestShape"
        LowestShape.zPosition = -10000
        LowestShape.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: LowestShape.frame.size.width, height: LowestShape.frame.size.height),center: CGPoint(x: 0 + frame.size.width/2, y: positionY))
        LowestShape.physicsBody?.affectedByGravity = false      //重力判定を無視
        LowestShape.physicsBody?.isDynamic = false              //固定物に設定
        LowestShape.physicsBody?.categoryBitMask = 0b0010       //接触判定用マスク設定
        LowestShape.physicsBody?.collisionBitMask = 0b0000      //接触対象をなしに設定
        LowestShape.physicsBody?.contactTestBitMask = 0b1000    //接触対象をmeteorに設定
        self.addChild(LowestShape)
    }
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

