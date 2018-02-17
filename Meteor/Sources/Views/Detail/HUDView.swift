//
//  HUDView.swift
//  SKGameSample
//
//  Created by Ryota on 2018/02/15.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import UIKit

class HUDView: UIView {
    var scoreLabel = UILabel()
    var highScoreLabel = UILabel()
    override init(frame:CGRect){
        super.init(frame:frame)
        //scoreLabel
        scoreLabel.textColor = UIColor.black
        scoreLabel.text = "0"
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 30)
        scoreLabel.layer.anchorPoint = CGPoint(x: 0, y: 0)//左上
        scoreLabel.layer.position = CGPoint(x: 25, y: 65 )//iPhoneX基準で調整
        addSubview(scoreLabel)
        scoreLabel.isHidden = true
        scoreLabel.sizeToFit()
        //highScoreLabel
        highScoreLabel.textColor = UIColor.black
        highScoreLabel.text = "00000000000"
        highScoreLabel.font = UIFont.boldSystemFont(ofSize: 20)
        highScoreLabel.layer.anchorPoint = CGPoint(x: 0, y: 0)
        highScoreLabel.layer.position = CGPoint(x: 25, y: 45)
        addSubview(highScoreLabel)
        highScoreLabel.isHidden = true
        highScoreLabel.sizeToFit()
}
    
    func stringSizeChange() {
        self.scoreLabel.font = UIFont.boldSystemFont(ofSize: 33)
        self.scoreLabel.sizeToFit()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scoreLabel.font = UIFont.boldSystemFont(ofSize: 30)
            self.scoreLabel.sizeToFit()
        }
    }

    func drawScore(score: Int){
        scoreLabel.text = String(score)
        stringSizeChange()
        scoreLabel.sizeToFit()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
