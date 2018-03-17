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
    private let pauseTexture: SKTexture
    private let resumeTexture: SKTexture
    var isPushed = false
    init(frame: CGRect)
    {
        pauseTexture = SKTexture(imageNamed: "pause")
        resumeTexture = SKTexture(imageNamed: "restart")
        super.init()
        PauseButton = SKSpriteNode(texture: pauseTexture)
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
    
    func pauseAction(){
        isPushed = true
        PauseButton.texture = resumeTexture
        self.pause?()
    }
    func resumeAction(){
        isPushed = false
        PauseButton.texture = pauseTexture
        self.resume?()
    }
    
    func tapped() {
        isPushed = !isPushed
        print("pausebutton.tapped()したよ")
        if( isPushed == true ){//動作中からポーズ
            pauseAction()
        }
        else{//ポーズから動作
            resumeAction()
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
