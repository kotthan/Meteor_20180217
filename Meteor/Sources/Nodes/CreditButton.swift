//
//  GameOverView.swift
//  Meteor
//
//  Created by Kazuaki Oe on 2018/02/19.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

@available(iOS 9.0, *)
class CreditButton: SKNode
{
    var creditButton: SKSpriteNode!
    
    init(frame: CGRect)
    {
        super.init()

        creditButton.fontName = "GillSansStd-ExtraBold"
        creditButton.fontSize = 30
        creditButton.text = "Credits"
        creditButton.position.x = self.frame.size.width / 2
        creditButton.position.y += 720 //適当
        creditButton.setzPos(.CreditButton)
        //タッチ判定用SpriteNode
        let creditButtonNode = SKSpriteNode(color: UIColor.clear, size: creditButton.frame.size)
        creditButtonNode.position.y += creditButton.frame.size.height / 2
        creditButtonNode.xScale = 1.2
        creditButtonNode.yScale = 1.5
        creditButtonNode.name = "credit"
        creditButton.addChild(creditButtonNode)
        self.baseNode.addChild(self.creditButton)
        
        self.position.x = -frame.size.width/2
        self.position.y = -frame.size.height/2
        self.setzPos(.GameOverView)
        //背景ノード追加
        let background = SKSpriteNode(imageNamed: "gameover_back")
        background.name = "backgound"
        background.position.x = +frame.size.width/2
        background.position.y = +frame.size.height/2
        background.zPosition = 10000
        self.addChild(background)
        //広告
        adBanner.frame.origin.x = frame.size.width / 2 - adBanner.frame.size.width / 2
        adBanner.frame.origin.y = 0 + frame.size.height - adBanner.frame.size.height - 20
        adBanner.isHidden = false
        //スコアラベル
        let scoreLabel = SKLabelNode()
        scoreLabel.zPosition = 10001
        scoreLabel.fontName = "GillSansStd-ExtraBold"
        scoreLabel.fontSize = 60
        scoreLabel.text = "Score: " + String( score )
        scoreLabel.fontColor = UIColor.black
        scoreLabel.position.x = +frame.size.width/2
        scoreLabel.position.y = frame.size.height/2 - 30
        self.addChild(scoreLabel)
        //ハイスコアラベル
        let highScoreLabel = SKLabelNode()
        highScoreLabel.zPosition = 100001
        highScoreLabel.fontName = "GillSansStd-ExtraBold"
        highScoreLabel.fontSize = 30
        highScoreLabel.text = "High Score: " + String( highScore )
        highScoreLabel.fontColor = UIColor.black
        highScoreLabel.position.x = +frame.size.width/2
        highScoreLabel.position.y = scoreLabel.position.y + scoreLabel.frame.size.height + 20
        self.addChild(highScoreLabel)
        //ホームボタン
        HomeButton = SKSpriteNode(imageNamed: "home")
        HomeButton.name = "HomeButton"
        HomeButton.size.width = 75.0
        HomeButton.size.height = 75.0
        HomeButton.zPosition = 100001
        HomeButton.position.x = +frame.size.width/2 - 100
        HomeButton.position.y = scoreLabel.position.y + scoreLabel.frame.size.height + 20 + 100
        HomeButton.xScale = 1
        HomeButton.yScale = 1
        self.addChild(HomeButton)
        //リスタートボタン
        ReStartButton = SKSpriteNode(imageNamed: "restart")
        ReStartButton.name = "ReStartButton"
        ReStartButton.size.width = 75.0
        ReStartButton.size.height = 75.0
        ReStartButton.zPosition = 100001
        ReStartButton.position.x = +frame.size.width/2 + 100
        ReStartButton.position.y = scoreLabel.position.y + scoreLabel.frame.size.height + 20 + 100
        ReStartButton.xScale = 1
        ReStartButton.yScale = 1
        self.addChild(ReStartButton)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
