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
        scoreLabel.font = UIFont(name: "GillSansStd-ExtraBold", size: 50)
        scoreLabel.layer.anchorPoint = CGPoint(x: 0, y: 0)//左上
        scoreLabel.layer.position = CGPoint(x: 23, y: 58)//iPhoneX基準で調整
        addSubview(scoreLabel)
        scoreLabel.isHidden = false
        scoreLabel.sizeToFit()
        scoreLabel.frame.size.height += 4
        //highScoreLabel
        highScoreLabel.textColor = UIColor.black
        highScoreLabel.text = "00000000000"
        //highScoreLabel.font = UIFont.boldSystemFont(ofSize: 17)
        highScoreLabel.font = UIFont(name: "GillSansStd-ExtraBold", size: 17)
        highScoreLabel.layer.anchorPoint = CGPoint(x: 0, y: 0)
        highScoreLabel.layer.position = CGPoint(x: 23, y: 38)
        addSubview(highScoreLabel)
        highScoreLabel.isHidden = false
        highScoreLabel.sizeToFit()
        highScoreLabel.frame.size.height += 3
}
    
    func stringSizeChange() {
        self.scoreLabel.font = UIFont(name: "GillSansStd-ExtraBold", size: 55)
        self.scoreLabel.sizeToFit()
        self.scoreLabel.frame.size.height += 5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scoreLabel.font = UIFont(name: "GillSansStd-ExtraBold", size: 50)
            self.scoreLabel.sizeToFit()
            self.scoreLabel.frame.size.height += 5
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
