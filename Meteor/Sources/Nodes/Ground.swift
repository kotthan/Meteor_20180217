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
    
    //ジャンプ時のパーティクル
    func jumpParticle(pos: CGPoint){
        //パーティクル
        let particles = SKEmitterNode(fileNamed: "jump.sks")
        particles!.setzPos(.Player)
        //接触座標にパーティクルを放出するようにする。
        particles!.position = pos
        //0.7秒後にシーンから消すアクションを作成する。
        let action11 = SKAction.wait(forDuration: 0.5)
        let action21 = SKAction.removeFromParent()
        let actionAll1 = SKAction.sequence([action11, action21])
        //パーティクルをシーンに追加する。
        self.addChild(particles!)
        //アクションを実行する。
        particles!.run(actionAll1)
    }
    
    func jumpSprite(pos: CGPoint){
        //パーティクル
        let sprite = SKSpriteNode(imageNamed: "jump2.sks")
        sprite.setzPos(.Player)
        sprite.xScale = 2
        sprite.yScale = 2
        //接触座標にパーティクルを放出するようにする。
        sprite.position = pos
        //0.7秒後にシーンから消すアクションを作成する。
        let action11 = SKAction.wait(forDuration: 0.3)
        let action21 = SKAction.removeFromParent()
        let actionAll1 = SKAction.sequence([action11, action21])
        //パーティクルをシーンに追加する。
        self.addChild(sprite)
        //アクションを実行する。
        sprite.run(actionAll1)
    }
    
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
