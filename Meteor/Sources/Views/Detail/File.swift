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
        //カメラノードに追加する前提で
        //画面の左下が原点になるように移動しておく
        self.position.x -= frame.size.width / 2
        self.position.y -= frame.size.height / 2
        self.zPosition = 1000
        //背景ノード追加
        let background = SKSpriteNode(imageNamed: "gameOverPanel")
        background.name = "backgound"
        self.addChild(background)
        //スコアラベル
        let scoreLabel = SKLabelNode()
        //scoreLabel.fontName
        /*
        //スコアラベル
        let scoreLabel = UILabel( )
        scoreLabel.font = UIFont(name: "GillSansStd-ExtraBold", size: 50)
        scoreLabel.text = "Score: " + String( score )
        scoreLabel.sizeToFit()
        scoreLabel.frame.size.height += 5
        scoreLabel.textColor = UIColor.white
        scoreLabel.layer.position.y = self.frame.size.height/4
        scoreLabel.layer.position.x = self.frame.size.width/2
        self.add(scoreLabel)
        //ハイスコアラベル
        let highScoreLabel = UILabel( )
        highScoreLabel.font = UIFont(name: "GillSansStd-ExtraBold", size:25)
        highScoreLabel.text = "High Score: " + String( highScore )
        highScoreLabel.sizeToFit()
        highScoreLabel.frame.size.height += 3
        highScoreLabel.textColor = UIColor.white
        highScoreLabel.layer.position.y = self.frame.size.height/4 + scoreLabel.frame.size.height
        highScoreLabel.layer.position.x = self.frame.size.width/2
        self.addSubview(highScoreLabel)
 */
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
