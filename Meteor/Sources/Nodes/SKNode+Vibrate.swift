//
//  SKNode+Vibrate.swift
//  Meteor
//
//  Created by Ryota on 2018/03/21.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit
import AudioToolbox

extension SKNode {
    
    func vibrate() {
        AudioServicesPlaySystemSound(1519)
        AudioServicesDisposeSystemSoundID(1519)
    }
}
