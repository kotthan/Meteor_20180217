//
//  GameCamera.swift
//  Meteor
//
//  Created by Ryota on 2018/03/29.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class GameCamera: SKCameraNode {
    let maxY : CGFloat = 1450   //カメラの上限
    let player: Player
    let defaultY: CGFloat
    
    init(player: Player, defaultY: CGFloat){
        self.player = player
        self.defaultY = defaultY
        super.init()
    }
    
    func update(){

        if (player.actionStatus != .Standing) && (self.player.position.y + 200 > self.defaultY) {
            if( self.player.position.y < self.maxY ){ //カメラの上限を超えない範囲で動かす
                self.position.y = self.player.position.y + 150
            }
        }
        else {
            self.position.y = self.defaultY
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
