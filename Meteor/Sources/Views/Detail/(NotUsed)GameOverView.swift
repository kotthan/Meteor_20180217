//
//  GameOverView.swift
//  Meteor
//
//  Created by Ryota on 2018/02/12.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
class NotusedGameOverView: UIView {
   
    init(frame: CGRect, score:Int, highScore:Int) {
        super.init(frame: frame)
        //背景色
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        let image1:UIImage = UIImage(named: "gameOverPanel")!
        let imageView = UIImageView(image:image1)
        let screenWidth:CGFloat = self.frame.size.width
        let screenHeight:CGFloat = self.frame.size.height
        imageView.center = CGPoint(x: screenWidth/2, y: screenHeight/2)
        // UIImageViewのインスタンスをビューに追加
        self.addSubview(imageView)

        //スコアラベル
        let scoreLabel = UILabel( )
        scoreLabel.font = UIFont(name: "GillSansStd-ExtraBold", size: 50)
        scoreLabel.text = "Score: " + String( score )
        scoreLabel.sizeToFit()
        scoreLabel.frame.size.height += 5
        scoreLabel.textColor = UIColor.white
        scoreLabel.layer.position.y = self.frame.size.height/4
        scoreLabel.layer.position.x = self.frame.size.width/2
        self.addSubview(scoreLabel)
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
