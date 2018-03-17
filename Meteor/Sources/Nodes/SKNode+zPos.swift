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
        case Ground = -10000
        case LowestShape = -9999
        case Sky = -20
        case Cloud_1 = -15
        case Cloud_2 = 30
        case Building = -10
        case HighScore = -2
        case GuadPod = -1
        case Player = 0
        case ComboLabel = 10
        case Meteor = 20
        case AttackShape = 1
        case GuardShape = 2
        case LandingEffect = 3
        case CreditButton = 50
        case CreditBuckButton = 51
        case Title = 60
        case TitleMeteor = 61
        case Gauge = 1000
        case GameOverCircle = 1500
        case PauseView = 9999
        case PauseButton = 10001
        case GameOverView = 10010
    }
    
    func setzPos(_ zPos: zPos){
        self.zPosition = zPos.rawValue
    }
    
}
