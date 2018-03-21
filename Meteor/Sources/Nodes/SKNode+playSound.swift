//
//  SKNode+playSound.swift
//  Meteor
//
//  Created by Ryota on 2018/03/21.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

extension SKNode {
    //MARK: 音楽
    func playSound(_ soundName: String){
        let mAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        self.run(mAction)
    }
}
