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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
