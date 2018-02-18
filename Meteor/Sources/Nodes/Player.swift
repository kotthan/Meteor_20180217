//
//  Player.swift
//  Meteor
//
//  Created by Ryota on 2018/02/18.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class Player: SKNode {
    
    var sprite: SKSpriteNode!
    var size: CGSize!
    
    override init() {
        super.init()
    }
    
    func setSprite(sprite: SKSpriteNode){
        self.sprite = sprite
        sprite.name = "player"
        //sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64), center: CGPoint(x: 0, y: 0))
        let texture = SKTexture(imageNamed: "player00")
        sprite.physicsBody = SKPhysicsBody(texture: texture, size: sprite.size)
        sprite.physicsBody!.friction = 1.0                      //摩擦
        sprite.physicsBody!.allowsRotation = false              //回転禁止
        sprite.physicsBody!.restitution = 0.0                   //跳ね返り値
        sprite.physicsBody!.mass = 0.03                         //質量
        sprite.physicsBody?.categoryBitMask = 0b0100            //接触判定用マスク設定
        sprite.physicsBody?.collisionBitMask = 0b0001           //接触対象を地面に設定
        sprite.physicsBody?.contactTestBitMask = 0b1000 | 0b0001//接触対象を地面｜meteorに設定
        //シーンから削除して再配置
        sprite.removeFromParent()
        sprite.isPaused = false
        //スプライトのサイズをbaseのサイズにする
        self.size = sprite.size
        self.addChild(sprite)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
