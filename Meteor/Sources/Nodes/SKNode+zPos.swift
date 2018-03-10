//
//  SKNode+zPos.swift
//  Meteor
//
//  Created by Ryota on 2018/03/10.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

extension SKNode {
    
    enum zPos : CGFloat{
        case HighScore = -1
        case Player = 0
    }
    
    func setzPos(_ zPos: zPos){
        self.zPosition = zPos.rawValue
    }
    
}
