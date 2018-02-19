//
//  File.swift
//  Meteor
//
//  Created by Kazuaki Oe on 2018/02/19.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

@available(iOS 9.0, *)
class GameOverView_0: SKNode {
    
    init(frame: CGRect, score:Int, highScore:Int) {
        super.init()
        self.zPosition = 1000
        //背景ノード追加
        let background = SKSpriteNode(imageNamed: "gameOverPanel")
        background.name = "backgound"
        background.zPosition = 1000
        background.xScale = 1/2
        background.yScale = 1/2
        self.addChild(background)
        //スコアラベル
        let scoreLabel = SKLabelNode()
        scoreLabel.zPosition = 1010
        scoreLabel.fontName = "GillSansStd-ExtraBold"
        scoreLabel.fontSize = 50
        scoreLabel.text = "Score: " + String( score )
        scoreLabel.color = UIColor.black
        scoreLabel.position.x = self.frame.size.width/2
        scoreLabel.position.y = self.frame.size.height/4
        self.addChild(scoreLabel)
        //スコアラベル
        let highScoreLabel = SKLabelNode()
        highScoreLabel.zPosition = 1010
        highScoreLabel.fontName = "GillSansStd-ExtraBold"
        highScoreLabel.fontSize = 25
        highScoreLabel.text = "High Score: " + String( highScore )
        highScoreLabel.color = UIColor.black
        highScoreLabel.position.x = self.frame.size.width/2
        highScoreLabel.position.y = self.frame.size.height/4 + scoreLabel.frame.size.height + 20
        self.addChild(highScoreLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
