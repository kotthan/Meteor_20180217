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
        TitleNode = SKSpriteNode(imageNamed: "notlogo")
        TitleNode.name = "TitleNode"
        TitleNode.position = CGPoint(
            x: 189.836, y: 1003.673 )
        TitleNode.zPosition = 50
        //TitleMeteorNode
        TitleMeteorNode = SKSpriteNode(imageNamed: "title_meteor")
        TitleMeteorNode.name = "TitleMeteorNode"
        TitleMeteorNode.position = CGPoint(
            x: 189.836, y:1003.673)
        TitleMeteorNode.zPosition = 51
        //Function
        func scaleLoopAction(_ node: SKSpriteNode){
            let actions = SKAction.sequence(
                [ SKAction.scale(to: 1.03, duration: 0.3),
                  //SKAction.wait(forDuration: 0.1),
                    SKAction.scale(to: 1.0, duration: 0.3),
                    //SKAction.wait(forDuration: 0.1),
                    SKAction.scale(to: 0.97, duration: 0.3),
                    //SKAction.wait(forDuration: 0.1),
                    SKAction.scale(to: 1.0, duration: 0.3)
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
            [ SKAction.moveBy(x: +10, y: 0, duration: 0.2),
              SKAction.moveBy(x: -20, y: 0, duration: 0.4),
              SKAction.moveBy(x: +20, y: 0, duration: 0.4),
              SKAction.moveBy(x: -20, y: 0, duration: 0.4),
              SKAction.wait(forDuration: 0.3),
              SKAction.moveBy(x: -20, y: +1000, duration: 1.0),
              SKAction.run{ node2.isHidden = true }
            ])
        node1.run(actions1)
        node2.run(actions2)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

