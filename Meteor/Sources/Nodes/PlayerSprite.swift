//
//  PlayerSprite.swift
//  Meteor
//
//  Created by Ryota on 2018/03/21.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class PlayerSprite: SKSpriteNode {
    
    var standTextures: [SKTexture] = []
    var squatTextures: [SKTexture] = []
    var jumpTextures: [SKTexture] = []
    var fallTextures: [SKTexture] = []
    var attackTextures: [SKTexture] = []
    var jumpAttackTextures: [SKTexture] = []
    var guardStartTextures: [SKTexture] = []
    var guardEndTextures: [SKTexture] = []
    var landingTextures: [SKTexture] = []

    enum AnimationState{
        case Standing
        case Jumping
        case Falling
    }
    var animationStatus = AnimationState.Standing
    
    init(){
        
        let texture = SKTexture(imageNamed: "player00")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        let standAnimationTextureNames = ["stand01","stand02"]
        let attackAnimationTextureNames = ["attack01","attack02","stand01"]
        let jumpAttackAnimationTextureNames = ["jumpattack01","jumpattack02"]
        let guardStartAnimationTextureNames = ["guard01"]
        let guardEndAnimationTextureNames = ["fall02"]
        let jumpAnimationTextureNames = ["jump00"]
        let fallAnimationTextureNames = ["fall01","fall02"]
        let landingAnimationTextureNames = ["landing"]
        let squatAnimationTextureNames = ["landing"]
        
        for name in standAnimationTextureNames {
            standTextures.append(SKTexture(imageNamed: name))
        }
        for name in squatAnimationTextureNames {
            squatTextures.append(SKTexture(imageNamed: name))
        }
        for name in jumpAnimationTextureNames {
            jumpTextures.append(SKTexture(imageNamed: name))
        }
        for name in fallAnimationTextureNames {
            fallTextures.append(SKTexture(imageNamed: name))
        }
        for name in landingAnimationTextureNames {
            landingTextures.append(SKTexture(imageNamed: name))
        }
        for name in attackAnimationTextureNames {
            attackTextures.append(SKTexture(imageNamed: name))
        }
        for name in jumpAttackAnimationTextureNames {
            jumpAttackTextures.append(SKTexture(imageNamed: name))
        }
        for name in guardStartAnimationTextureNames {
            guardStartTextures.append(SKTexture(imageNamed: name))
        }
        for name in guardEndAnimationTextureNames {
            guardEndTextures.append(SKTexture(imageNamed: name))
        }

        self.name = "player"
        self.stand()
    }
    
    //立ちアニメ
    func stand() {
        self.animationStatus = .Standing
        self.removeAction(forKey: "textureAnimation")
        let action = SKAction.animate(with: standTextures, timePerFrame: 1.0, resize: false, restore: false)
        self.run(SKAction.repeatForever(action), withKey: "textureAnimation")
    }

    func squat() {
        self.animationStatus = .Standing
        self.removeAction(forKey: "textureAnimation")
        let action = SKAction.animate(with: squatTextures, timePerFrame: 0.5, resize: false, restore: false)
        self.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }
    
    //ジャンプ
    func jumpAnimation() {
        self.animationStatus = .Jumping
        self.removeAction(forKey: "textureAnimation")
        let action = SKAction.animate(with: jumpTextures, timePerFrame: 0.1, resize: false, restore: false)
        self.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }
    
    //落下
    func fallAinmation(){
        self.animationStatus = .Falling
        self.removeAction(forKey: "textureAnimation")
        let action = SKAction.animate(with: fallTextures, timePerFrame: 0.1, resize: false, restore: false)
        self.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }

    //着地
    func landingAnimation(){
        print("landingAnimation")
        self.animationStatus = .Standing
        self.removeAction(forKey: "textureAnimation")
        let nextAction = SKAction.run{
            self.stand()
        }
        let action = SKAction.animate(with: landingTextures, timePerFrame: 0.3, resize: false, restore: false)
        let actions = SKAction.sequence([action,nextAction])
        self.run(SKAction.repeat(actions, count:1), withKey: "textureAnimation")
    }
    
    //攻撃
    func attackAnimation(){
        self.removeAction(forKey: "textureAnimation")
        let action = SKAction.animate(with: attackTextures, timePerFrame: 0.1, resize: false, restore: false)
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
        let action = SKAction.animate(with: jumpAttackTextures, timePerFrame: 0.1, resize: false, restore: false)
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

    func ultraAttackAnimation(){
        self.removeAction(forKey: "textureAnimation")
        let action = SKAction.animate(with: jumpAttackTextures, timePerFrame: 0.1, resize: false, restore: false)
        self.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }
    
    //ガード
    func guardStartAnimation(){
        self.removeAction(forKey: "textureAnimation")
        let action = SKAction.animate(with: guardStartTextures, timePerFrame: 0.1, resize: false, restore: false)
        self.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }
    func guardEndAnimation() {
        self.removeAction(forKey: "textureAnimation")
        let action = SKAction.animate(with: guardEndTextures, timePerFrame: 0.1, resize: false, restore: false)
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
