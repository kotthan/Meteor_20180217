//
//  PauseView.swift
//  Meteor
//
//  Created by Ryota on 2018/02/12.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

@available(iOS 9.0, *)
class PauseView: SKNode {
    
    init(frame: CGRect) {
        super.init()
        //カメラノードに追加する前提で
        //画面の左下が原点になるように移動しておく
        self.position.x -= frame.size.width / 2
        self.position.y -= frame.size.height / 2
        self.zPosition = 10000
        //背景ノード追加
        let background = SKShapeNode(rect: frame)
        background.name = "backgound"
        //背景色
        background.fillColor = UIColor.black.withAlphaComponent(0.3)
        //枠線の太さ
        background.lineWidth = 0
        self.addChild(background)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

