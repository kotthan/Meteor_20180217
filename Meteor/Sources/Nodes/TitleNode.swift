//
//  File.swift
//  Meteor
//
//  Created by Kazuaki Oe on 2018/02/28.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

@available(iOS 9.0, *)
class TitleNode: SKNode {
    var TitleNode: SKSpriteNode!
    var TitleMeteorNode: SKSpriteNode!
    override init() {
        super.init()
        //TitleNode
        TitleNode = SKSpriteNode(imageNamed: "nasilogo_312")
        TitleNode.name = "TitleNode"
        TitleNode.xScale = 1 / 10
        TitleNode.yScale = 1 / 10
        TitleNode.position = CGPoint(
            x: 189.836, y: 1003.673 )
        TitleNode.setzPos(.Title)
        //TitleMeteorNode
        TitleMeteorNode = SKSpriteNode(imageNamed: "niki_312")
        TitleMeteorNode.name = "TitleMeteorNode"
        TitleMeteorNode.xScale = 1 / 10
        TitleMeteorNode.yScale = 1 / 10
        TitleMeteorNode.position = CGPoint(
            x: TitleNode.position.x + 62, y:997)
        TitleMeteorNode.setzPos(.TitleMeteor)
        //Function
        func scaleLoopAction(_ node: SKSpriteNode){
            let actions = SKAction.sequence(
                [ SKAction.scale(to: 0.58, duration: 0.3),
                  //SKAction.wait(forDuration: 0.1),
                    SKAction.scale(to: 0.55, duration: 0.3),
                    //SKAction.wait(forDuration: 0.1),
                    SKAction.scale(to: 0.52, duration: 0.3),
                    //SKAction.wait(forDuration: 0.1),
                    SKAction.scale(to: 0.55, duration: 0.3)
                    //SKAction.run{self.isPaused = true},
                ])
            let loopAction = SKAction.repeatForever(actions)
            node.run(loopAction)
        }
        
       //addChild
        self.addChild(TitleNode)
        scaleLoopAction(self.TitleNode)
        self.addChild(TitleMeteorNode)
        scaleLoopAction(self.TitleMeteorNode)
        }
    
    class func TapAction(_ node1: SKSpriteNode, node2: SKSpriteNode){
        let actions1 = SKAction.sequence(
            [ SKAction.fadeOut(withDuration: 1.0),
              SKAction.run{ node1.isHidden = true }
            ])
        let actions2 = SKAction.sequence(
            [ SKAction.moveBy(x: +10, y: 0, duration: 0.05),
              SKAction.moveBy(x: -20, y: 0, duration: 0.1),
              SKAction.moveBy(x: +20, y: 0, duration: 0.1),
              SKAction.moveBy(x: -20, y: 0, duration: 0.1),
              SKAction.wait(forDuration: 0.3),
              SKAction.moveBy(x: -100, y: +1000, duration: 1.0),
              SKAction.run{ node2.isHidden = true }
            ])
        node1.run(actions1)
        node2.run(actions2)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

