//
//  File.swift
//  Meteor
//
//  Created by Kazuaki Oe on 2018/03/01.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//
import SpriteKit

@available(iOS 9.0, *)
class GaugeView: SKNode {
    var base: SKSpriteNode!
    
   init(frame: CGRect) {
        super.init()
        self.zPosition = 1000
        //ゲージベース追加
        let base = SKSpriteNode(imageNamed: "base")
        base.name = "base"
        base.xScale = 0.39
        base.yScale = 0.39
        base.position.x = 0
        base.position.y =  0 - frame.size.height / 2 + base.size.height / 2 
        base.zPosition = 1000
        self.addChild(base)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
