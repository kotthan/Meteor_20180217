//
//  Meteor.swift
//  Meteor
//
//  Created by Ryota on 2018/03/09.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class Meteor: SKNode{
    
    var buildFlg:Bool = true
    var meteores: [SKSpriteNode] = []
    let texture: SKTexture
    var meteorSpeed : CGFloat = 0.0                                 //隕石のスピード[pixels/s]
    var meteorSpeedAtGuard: CGFloat = 100                           //隕石が防御された時の速度
    var meteorGravityCoefficient: CGFloat = 0.04                    //隕石が受ける重力の影響を調整する係数
    var meteorInt: Int = 0
    var meteorUpScale : CGFloat = 0.8                               //隕石の増加倍率
    var baseGravity : CGFloat = -900                                    //重力 9.8 [m/s^2] * 150 [pixels/m]
    
    override init(){
        self.texture = SKTexture(imageNamed: "normal_meteor")
        super.init()
        
    }
    
    //MARK: 隕石落下
    func buildMeteor(position: CGPoint){
        
        guard self.buildFlg == true else { return }
        
        self.buildFlg = false
        self.meteorSpeed = 0.0
        self.meteorGravityCoefficient = 0.05 + 0.01 * CGFloat(self.meteorInt)
        
        var meteorZ = SKNode.zPos.Meteor.rawValue
        for i in (0...meteorInt).reversed()
        {
            let size: CGFloat = 0.3 + CGFloat(i) * self.meteorUpScale
        
            let meteor = SKSpriteNode(texture: texture)
            meteor.zPosition = meteorZ
            meteor.size = CGSize(width: texture.size().width, height: texture.size().height)
            meteor.xScale = CGFloat(size)
            meteor.yScale = CGFloat(size)
            if meteores.isEmpty
            {
                meteor.position = position
                meteor.position.y +=  (meteor.size.height) / 2
            } else
            {
                meteor.position = CGPoint(x: 187, y: (meteores.first?.position.y)!)
            }
            meteor.physicsBody = SKPhysicsBody(texture: texture, size: meteor.size)
            meteor.physicsBody?.affectedByGravity = false
            meteor.physicsBody?.categoryBitMask = 0b1000                         //接触判定用マスク設定
            meteor.physicsBody?.collisionBitMask = 0b0000                        //接触対象をなしに設定
            meteor.physicsBody?.contactTestBitMask = 0b0010 | 0b10000 | 0b100000 | 0b0100 //接触対象を各Shapeとプレイヤーに設定
            meteor.name = "meteor"
            self.addChild(meteor)
            self.meteores.append(meteor)
            
            meteorZ -= 0.001
        }
        meteorInt += 1
    }

    func update(){
        if ( !self.meteores.isEmpty ){
            //速度計算
            self.meteorSpeed += self.baseGravity * self.meteorGravityCoefficient / 60
            //位置計算
            for m in self.meteores {
                m.position.y += self.meteorSpeed / 60
            }
        }
    }
    
    func broken(attackPos: CGPoint){
        self.meteores[0].physicsBody?.categoryBitMask = 0
        self.meteores[0].physicsBody?.contactTestBitMask = 0
        self.meteores[0].removeFromParent()
        //隕石を爆発させる
        let particle = SKEmitterNode(fileNamed: "MeteorBroken.sks")
        //接触座標にパーティクルを放出するようにする。
        particle!.position = attackPos
        //0.7秒後にシーンから消すアクションを作成する。
        let action1 = SKAction.wait(forDuration: 0.5)
        let action2 = SKAction.removeFromParent()
        let actionAll = SKAction.sequence([action1, action2])
        //パーティクルをシーンに追加する。
        self.addChild(particle!)
        particle!.run(actionAll)
        //隕石を爆発させる
        let impact = SKEmitterNode(fileNamed: "Impact.sks")
        //接触座標にパーティクルを放出するようにする。
        impact!.position = attackPos
        //0.7秒後にシーンから消すアクションを作成する。
        let action11 = SKAction.wait(forDuration: 0.5)
        let action21 = SKAction.removeFromParent()
        let actionAll1 = SKAction.sequence([action11, action21])
        //パーティクルをシーンに追加する。
        self.addChild(impact!)
        //アクションを実行する。
        impact!.run(actionAll1)
        //spriteを削除する
        self.meteores.remove(at: 0)

    }
    
    func guarded(guardPos: CGPoint){
        //隕石を爆発させる
        let impact = SKEmitterNode(fileNamed: "Impact.sks")
        //接触座標にパーティクルを放出するようにする。
        impact!.position = guardPos
        //0.7秒後にシーンから消すアクションを作成する。
        let action11 = SKAction.wait(forDuration: 0.5)
        let action21 = SKAction.removeFromParent()
        let actionAll1 = SKAction.sequence([action11, action21])
        //パーティクルをシーンに追加する。
        self.addChild(impact!)
        //アクションを実行する。
        impact!.run(actionAll1)
        for i in meteores
        {
            i.removeAllActions()
        }
        meteorSpeed = self.meteorSpeedAtGuard       //上に持ちあげる
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
