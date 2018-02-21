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
        //ホームボタン
        let homeButton = SKSpriteNode(imageNamed: "home")
        homeButton.name = "homeButton"
        homeButton.size.width = 75.0
        homeButton.size.height = 75.0
        homeButton.zPosition = 1010
        homeButton.xScale = 1
        homeButton.yScale = 1
        self.addChild(homeButton)
    }
    

    /*
    func gameOverViewCreate(){
     //ゲームオーバー画面
     gameOverView = GameOverView(frame: self.frame, score: self.score, highScore: self.highScore )
        var buttonX:CGFloat = 10    //左端の余白
        var buttonY = gameOverView.frame.size.height - 10    //下端の余白
        //Titleボタン
        let newGameBtn = IconButton(image:"home", color:UIColor(red: 0.1, green: 0.8, blue: 0.6, alpha: 1))
        newGameBtn.layer.position = CGPoint(x: buttonX, y: buttonY )
        newGameBtn.addTarget(self, action: #selector(self.newGameButtonAction), for: .touchUpInside)
        gameOverView.addSubview(newGameBtn)
        buttonX += newGameBtn.frame.size.width + 10
        //Retryボタン
        let retryBtn = IconButton(image: "restart", color: UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1))
        retryBtn.layer.position = CGPoint(x: buttonX, y: buttonY)
        retryBtn.addTarget(self, action: #selector(self.retryButtonAction), for: .touchUpInside)
        gameOverView.addSubview(retryBtn)
        self.view!.addSubview(gameOverView)
    }
 */
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
