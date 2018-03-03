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
    
    init(frame: CGRect) {
        super.init()
        self.position.x = -frame.size.width/2
        self.position.y = -frame.size.height/2
        //建物スプライト追加
        let Buillding = SKSpriteNode(imageNamed: "buillding392")
        Buillding.name = "Buillding"
        Buillding.anchorPoint = CGPoint(x: 0, y: 0)
        Buillding.position.x = 0 + frame.size.width/2 - 25
        Buillding.position.y = 185
        Buillding.zPosition = -10
        self.addChild(Buillding)
        //空スプライト追加
        let Sky = SKSpriteNode(imageNamed: "sky409")
        Sky.name = "Sky"
        Sky.anchorPoint = CGPoint(x:0, y:0)
        Sky.position.x = 0 + frame.size.width/2
        Sky.position.y = 620
        Sky.zPosition = -11
        self.addChild(Sky)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

