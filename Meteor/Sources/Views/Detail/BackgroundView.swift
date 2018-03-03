//
//  File.swift
//  Meteor
//
//  Created by Kazuaki Oe on 2018/03/03.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

@available(iOS 9.0, *)
class BackgroundView: SKNode {
    var Buillding: SKSpriteNode!
    var Sky: SKSpriteNode!
    var cloud_1: SKSpriteNode!
    var cloud_2: SKSpriteNode!
    
    init(frame: CGRect) {
        super.init()
        self.position.x = -frame.size.width/2
        self.position.y = -frame.size.height/2
        //建物スプライト追加
        Buillding = SKSpriteNode(imageNamed: "buillding392")
        Buillding.name = "Buillding"
        Buillding.anchorPoint = CGPoint(x: 0, y: 0)
        Buillding.position.x = 0 + frame.size.width/2 - 25
        Buillding.position.y = 185
        Buillding.zPosition = -10
        self.addChild(Buillding)
        //空スプライト追加
        Sky = SKSpriteNode(imageNamed: "sky409")
        Sky.name = "Sky"
        Sky.anchorPoint = CGPoint(x:0, y:0)
        Sky.position.x = 0 + frame.size.width/2
        Sky.position.y = 620
        Sky.zPosition = -11
        self.addChild(Sky)
        //雲１（ビル付近）追加
        cloud_1 = SKSpriteNode(imageNamed: "cloud_1")
        cloud_1.position = CGPoint(x: 200,y: 800)
        cloud_1.zPosition = -15
        self.addChild(cloud_1)
        //雲２（上空）追加
        cloud_2 = SKSpriteNode(imageNamed: "cloud_2")
        cloud_2.position = CGPoint(x: 200,y: 5000)
        cloud_2.zPosition = 30
        self.addChild(cloud_2)
        
        //アニメーション実行
        cloudLoopAction(cloud_1)
        cloudLoopAction(cloud_2)
    }
    
    //アニメーション追加
    func cloudLoopAction(_ node: SKSpriteNode){
        let actions = SKAction.sequence(
            [ SKAction.moveTo(x: -1000, duration: 3000.0),
              SKAction.wait(forDuration: 1.0),
              SKAction.moveTo(x: 1000, duration: 0),
              SKAction.wait(forDuration: 1.0),
              //SKAction.run{self.isPaused = true},
            ])
        let loopAction = SKAction.repeatForever(actions)
        node.run(loopAction)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

