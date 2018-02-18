//
//  Player.swift
//  Meteor
//
//  Created by Ryota on 2018/02/18.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class Player: SKNode {
    
    var velocity: CGFloat = 0.0
    var sprite: SKSpriteNode!
    var size: CGSize!
    let halfSize: CGFloat = 20 // playerPhisicsBody / 2 の実測値
    let standAnimationTextureNames = ["stand01","stand02"]
    let attackAnimationTextureNames = ["attack01","attack02","player00"]
    let guardStartAnimationTextureNames = ["guard01"]
    let guardEndAnimationTextureNames = ["player00"]
    var jumpVelocity:CGFloat = 9.8 * 150 * 1.2  //プレイヤーのジャンプ時の初速
    var defaultYPosition : CGFloat = 0.0
    var jumping: Bool = false   //ジャンプ中フラグ
    var moving: Bool = false                                        //移動中フラグ
    let moveSound = SKAction.playSoundFileNamed("move", waitForCompletion: true)
    let jumpSound = SKAction.playSoundFileNamed("jump", waitForCompletion: true)
    let landingSound = SKAction.playSoundFileNamed("tyakuti", waitForCompletion: true)
    //横位置
    enum PosState: Double {
        case left = 93.75
        case center = 187.5
        case right = 281.25
    }
    var posStatus = PosState.center
    
    override init() {
        super.init()
    }
    
    func setSprite(sprite: SKSpriteNode){
        self.sprite = sprite
        //baseNodeをspriteの位置にする
        self.position = sprite.position
        sprite.position = CGPoint(x:0,y:0)
        self.defaultYPosition = self.position.y
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
    
    //MARK: - ジャンプ
    func jump() {
        if self.jumping == false {
            self.moving = false
            self.jumping = true
            self.velocity = self.jumpVelocity
            self.run(self.jumpSound)
        }
    }
    
    //着地
    func landing(){
        self.jumping = false
        self.velocity = 0.0
        self.position.y = self.defaultYPosition
        //SE
        self.run(landingSound)
        //着地エフェクト
        let landingEffect = LandingEffect()
        landingEffect.position.y -= self.size.height / 2
        self.addChild(landingEffect)
    }
    
    //立ちアニメ
    func stand() {
        sprite.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in self.standAnimationTextureNames {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 1.0, resize: false, restore: false)
        sprite.run(SKAction.repeatForever(action), withKey: "textureAnimation")
    }
    
    func attack() {
        self.sprite.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in self.attackAnimationTextureNames {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: false, restore: false)
        self.sprite.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }
    
    func guardStart() {
        self.sprite.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in self.guardStartAnimationTextureNames {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: false, restore: false)
        self.sprite.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }
    
    func guardEnd() {
        self.sprite.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in guardEndAnimationTextureNames {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: false, restore: false)
        self.sprite.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }

    func moveToRight()
    {
        switch self.posStatus {
        case .center:
            moveTo(.right)
        case .left:
            moveTo(.center)
        case .right:
            break
        }
    }

    func moveToLeft()
    {
        switch self.posStatus {
        case .center:
            moveTo(.left)
        case .right:
            moveTo(.center)
        case .left:
            break
        }
    }
    
    func moveTo(_ pos: PosState){
        guard self.jumping == false else{return}
        guard self.moving == false else{return}
        
        self.posStatus = pos
        let move = SKAction.moveTo(x: CGFloat(pos.rawValue), duration: 0.15)
        let stop = SKAction.run(moveStop)
        self.run(self.moveSound)
        self.run(SKAction.sequence([move,stop]))
    }
    
    //MARK: - 停止
    func moveStop() {
        self.moving = false
        if self.jumping == false {
            self.sprite.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        }
        self.stand()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
