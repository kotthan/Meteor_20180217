//
//  PlayerSprite.swift
//  Meteor
//
//  Created by Ryota on 2018/03/21.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class PlayerSprite: SKSpriteNode {
    
    let standAnimationTextureNames = ["stand01","stand02"]
    let attackAnimationTextureNames = ["attack01","attack02","stand01"]
    let jumpAttackAnimationTextureNames = ["jumpattack01","jumpattack02"]
    let guardStartAnimationTextureNames = ["guard01"]
    let guardEndAnimationTextureNames = ["player00"]
    let jumpAnimationTextureNames = ["jump00"]
    let fallAnimationTextureNames = ["fall01","fall02"]
    let landingAnimationTextureNames = ["landing"]
    let squatAnimationTextureNames = ["squat"]
    
    enum AnimationState{
        case Standing
        case Jumping
        case Falling
    }
    var animationStatus = AnimationState.Standing
    
    init(){
        let texture = SKTexture(imageNamed: "player00")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        self.name = "player"
        self.stand()
    }
    
    //立ちアニメ
    func stand() {
        self.animationStatus = .Standing
        self.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in self.standAnimationTextureNames {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 1.0, resize: false, restore: false)
        self.run(SKAction.repeatForever(action), withKey: "textureAnimation")
    }

    func squat() {
        self.animationStatus = .Standing
        self.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in self.squatAnimationTextureNames {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.5, resize: false, restore: false)
        self.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }
    
    //ジャンプ
    func jumpAnimation() {
        self.animationStatus = .Jumping
        self.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in self.jumpAnimationTextureNames {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: false, restore: false)
        self.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }
    
    //落下
    func fallAinmation(){
        self.animationStatus = .Falling
        self.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in self.fallAnimationTextureNames {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: false, restore: false)
        self.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }

    //着地
    func landingAnimation(){
        print("landingAnimation")
        self.animationStatus = .Standing
        self.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in self.landingAnimationTextureNames {
            ary.append(SKTexture(imageNamed: name))
        }
        let nextAction = SKAction.run{
            self.stand()
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.3, resize: false, restore: false)
        let actions = SKAction.sequence([action,nextAction])
        self.run(SKAction.repeat(actions, count:1), withKey: "textureAnimation")
    }
    
    //攻撃
    func attackAnimation(){
        self.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in self.attackAnimationTextureNames {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: false, restore: false)
        let nextAction = SKAction.run{
            switch self.animationStatus {
            case .Standing:
                self.stand()
            case .Jumping:
                self.jumpAnimation()
            case .Falling:
                self.fallAinmation()
            }
        }
        let actions = SKAction.sequence([action,nextAction])
        self.run(SKAction.repeat(actions, count:1), withKey: "textureAnimation")
    }
    
    func jumpAttackAnimation(){
        self.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in self.jumpAttackAnimationTextureNames {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: false, restore: false)
        let nextAction = SKAction.run{
            switch self.animationStatus {
            case .Standing:
                self.stand()
            case .Jumping:
                self.jumpAnimation()
            case .Falling:
                self.fallAinmation()
            }
        }
        let actions = SKAction.sequence([action,nextAction])
        self.run(SKAction.repeat(actions, count:1), withKey: "textureAnimation")
    }
    
    //ガード
    func guardStartAnimation(){
        self.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in self.guardStartAnimationTextureNames {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: false, restore: false)
        self.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }
    func guardEndAnimation() {
        self.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        if( self.animationStatus != .Standing ){
            for name in guardEndAnimationTextureNames {
                ary.append(SKTexture(imageNamed: name))
            }
        }
        else{
            for name in standAnimationTextureNames {
                ary.append(SKTexture(imageNamed: name))
            }
        }
        let nextAction = SKAction.run{
            switch self.animationStatus {
            case .Standing:
                self.stand()
            case .Jumping:
                self.jumpAnimation()
            case .Falling:
                self.fallAinmation()
            }
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: false, restore: false)
        let actions = SKAction.sequence([action,nextAction])
        self.run(SKAction.repeat(actions, count:1), withKey: "textureAnimation")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
