//
//  File.swift
//  Meteor
//
//  Created by Kazuaki Oe on 2018/03/02.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

@available(iOS 9.0, *)

class PauseButton: SKNode
{
    var PauseButton: SKSpriteNode!
    private var resume: (() -> Void)?               //再開時に呼ばれる関数
    private var pause: (() -> Void)?                //停止時に呼ばれる関数
    let pauseAnimation = "pause"
    let restartAnimation = "restart"
    init(frame: CGRect)
    {
        super.init()
        PauseButton = SKSpriteNode(imageNamed: "pause")
        PauseButton.name = "PauseButton"
        PauseButton.size.width = 50.0
        PauseButton.size.height = 50.0
        PauseButton.setzPos(.PauseButton)
        PauseButton.position = CGPoint(
            x: frame.size.width/2 - PauseButton.size.width/2 - 15, y: frame.size.height/2 - PauseButton.size.width/2 - 15)
        PauseButton.xScale = 1
        PauseButton.yScale = 1
        self.addChild(PauseButton)
        print("pauseButtonを作ったよ\(PauseButton.position)")
    }
    
    //ポーズ時の動作を設定する関数
    func setPauseFunc(action: @escaping () -> Void) {
        self.pause = action
    }
    
    //ポーズ解除時の動作を設定する関数
    func setResumeFunc(action: @escaping () -> Void) {
        self.resume = action
    }
    
    func animation(name: String) {
        var ary: [SKTexture] = []
            ary.append(SKTexture(imageNamed: name))
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: false, restore: false)
        self.PauseButton.run(action)
    }
    
    func pauseAction(){
        isPaused = true
        animation(name: pauseAnimation)
        self.pause?()
    }
    func resumeAction(){
        isPaused = false
        animation(name: restartAnimation)
        self.resume?()
    }
    
    func tapped() {
        isPaused = !isPaused
        print("pausebutton.tapped()したよ")
        if( isPaused == true ){
            animation(name:  restartAnimation)
            self.pause?()
        }
        else{
            animation(name: pauseAnimation)
            self.resume?()
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
