//
//  GameOverView.swift
//  Meteor
//
//  Created by Kazuaki Oe on 2018/02/19.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

@available(iOS 9.0, *)
class GameOverView: SKNode {
    var HomeButton: SKSpriteNode!
    var ReStartButton: SKSpriteNode!
    
    init(frame: CGRect, score:Int, highScore:Int) {
        super.init()
        self.position.x = -frame.size.width/2
        self.position.y = -frame.size.height/2
        self.zPosition = 1000
        //背景ノード追加
        let background = SKSpriteNode(imageNamed: "buillding392")
        background.name = "backgound"
        background.position.x = +frame.size.width/2
        background.position.y = +frame.size.height/2
        background.zPosition = 1000
        background.size.width = frame.size.width
        background.size.height = frame.size.height
        self.addChild(background)
        //広告
        adBanner.frame.origin.x = frame.size.width / 2 - adBanner.frame.size.width / 2
        adBanner.frame.origin.y = frame.size.height / 2 //+ adBanner.frame.size.height / 2
        adBanner.isHidden = false
        //スコアラベル
        let scoreLabel = SKLabelNode()
        scoreLabel.zPosition = 1010
        scoreLabel.fontName = "GillSansStd-ExtraBold"
        scoreLabel.fontSize = 50
        scoreLabel.text = "Score: " + String( score )
        scoreLabel.color = UIColor.black
        scoreLabel.position.x = +frame.size.width/2
        scoreLabel.position.y = adBanner.frame.origin.y + 10
        self.addChild(scoreLabel)
        //スコアラベル
        let highScoreLabel = SKLabelNode()
        highScoreLabel.zPosition = 1010
        highScoreLabel.fontName = "GillSansStd-ExtraBold"
        highScoreLabel.fontSize = 30
        highScoreLabel.text = "High Score: " + String( highScore )
        highScoreLabel.color = UIColor.black
        highScoreLabel.position.x = +frame.size.width/2
        highScoreLabel.position.y = scoreLabel.position.y + scoreLabel.frame.size.height + 20
        self.addChild(highScoreLabel)
        //ホームボタン
        HomeButton = SKSpriteNode(imageNamed: "home")
        HomeButton.name = "HomeButton"
        HomeButton.size.width = 75.0
        HomeButton.size.height = 75.0
        HomeButton.zPosition = 1010
        HomeButton.position.x = +frame.size.width/2 - 100
        HomeButton.position.y = adBanner.frame.origin.y  - 292
        HomeButton.xScale = 1
        HomeButton.yScale = 1
        self.addChild(HomeButton)
        //リスタートボタン
        ReStartButton = SKSpriteNode(imageNamed: "restart")
        ReStartButton.name = "ReStartButton"
        ReStartButton.size.width = 100.0
        ReStartButton.size.height = 75.0
        ReStartButton.zPosition = 1010
        ReStartButton.position.x = +frame.size.width/2 + 100
        ReStartButton.position.y = adBanner.frame.origin.y  - 292
        ReStartButton.xScale = 1
        ReStartButton.yScale = 1
        self.addChild(ReStartButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
