//
//  Player.swift
//  Meteor
//
//  Created by Ryota on 2018/02/18.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class Player: SKNode {
    
    var velocity: CGFloat = 0.0
    var ultraPower: Int = 0         //必殺技判定用
    let gravity: CGFloat = -900
    var sprite: SKSpriteNode!
    var size: CGSize!
    let halfSize: CGFloat = 20 // playerPhisicsBody / 2 の実測値
    let standAnimationTextureNames = ["stand01","stand02"]
    let attackAnimationTextureNames = ["attack01","attack02","stand01"]
    let guardStartAnimationTextureNames = ["guard01"]
    let guardEndAnimationTextureNames = ["player00"]
    let jumpAnimationTextureNames = ["jump00","jump01"]
    let fallAnimationTextureNames = ["fall01","fall02"]
    let jumpVelocity:CGFloat = 1500  //プレイヤーのジャンプ時の初速
    var defaultYPosition : CGFloat = 0.0
    var jumping: Bool = false   //ジャンプ中フラグ
    var moving: Bool = false                                        //移動中フラグ
    let moveSound = SKAction.playSoundFileNamed("move1", waitForCompletion: true)
    let jumpSound = SKAction.playSoundFileNamed("jump10", waitForCompletion: true)
    let landingSound = SKAction.playSoundFileNamed("tyakuti1", waitForCompletion: true)
    //横位置
    enum PosState: CGFloat {
        case left = 93.75
        case center = 187.5
        case right = 281.25
    }
    var posStatus = PosState.center
    var meteorCollisionFlg = false  /* 隕石衝突フラグ */
    enum ActionState{
        case Standing
        case Jumping
        case Falling
    }
    var actionStatus = ActionState.Standing
    var attackFlg : Bool = false                                    //攻撃フラグ
    var attackShape: AttackShape!                                   //攻撃判定シェイプノード
    let ultraAttackSpped : CGFloat = 9.8 * 150 * 2            //プレイヤーの必殺技ジャンプ時の初速
    enum UltraAttackState{ //必殺技の状態
        case none       //未発動
        case landing    //最初の着地
        case attacking  //攻撃中
    }
    var ultraAttackStatus = UltraAttackState.none   //必殺技発動中フラグ
    var gaugeview: GaugeView?
    
    override init() {
        super.init()
        setSprite()
        self.stand()
    }
    
    func setSprite(){
        
        //MARK: SKSファイルを読み込み
        if let scene = SKScene(fileNamed: "GameScene.sks")
        {
            scene.enumerateChildNodes(withName: "player", using: { (node, stop) -> Void in
                self.sprite = node as! SKSpriteNode
            })
        }
        //self.sprite = SKSpriteNode(imageNamed: "player00")
        //baseNodeをspriteの位置にする
        self.position = self.sprite.position
        sprite.position = CGPoint(x:0,y:0)
        sprite.name = "player"
        //sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64), center: CGPoint(x: 0, y: 0))
        let texture = SKTexture(imageNamed: "player00")
        let physicsBody = SKPhysicsBody(texture: texture, size: sprite.size)
        physicsBody.friction = 1.0                      //摩擦
        physicsBody.allowsRotation = false              //回転禁止
        physicsBody.restitution = 0.0                   //跳ね返り値
        physicsBody.mass = 0.03                         //質量
        physicsBody.categoryBitMask = 0b0100            //接触判定用マスク設定
        physicsBody.collisionBitMask = 0b0001           //接触対象を地面に設定
        physicsBody.contactTestBitMask = 0b1000 | 0b0001//接触対象を地面｜meteorに設定
        self.physicsBody = physicsBody
        //シーンから削除して再配置
        sprite.removeFromParent()
        sprite.isPaused = false
        //スプライトのサイズをbaseのサイズにする
        self.size = sprite.size
        let groundY: CGFloat = 145.5
        self.defaultYPosition = groundY + 27
        self.addChild(sprite)
        self.position.x = PosState.center.rawValue
        //攻撃判定用シェイプ
        self.attackShape = AttackShape(size: self.size)
        self.attackShape.position.y = self.size.height
    }

    func update(meteor: SKSpriteNode?, meteorSpeed: CGFloat){
        //地面に立っている場合は計算しない
        guard actionStatus != .Standing else { return }
        // 次の位置を計算する
        self.velocity += self.gravity / 60   // [pixcel/s^2] / 60[fps]
        self.position.y += CGFloat( self.velocity / 60 )           // [pixcel/s] / 60[fps]
        //初期位置（地面）より下なら地面にする
        if self.position.y < self.defaultYPosition {
            self.position.y = self.defaultYPosition
        }

        //隕石衝突時の位置修正
        guard self.meteorCollisionFlg  == true else { return }
        guard let meteor = meteor else { return }
        
        let meteorMinY = meteor.position.y - (meteor.size.height/2)
        self.position.y = meteorMinY - self.halfSize
        self.velocity -= meteorSpeed / 60
        if( self.velocity < meteorSpeed ){
            //playerが上昇中にfalseにすると何度も衝突がおきてplayeerがぶれるので
            //落下速度が隕石より早くなってからfalseにする
            self.meteorCollisionFlg = false
        }
    }

    func didSimulatePhysics(){
        // 隕石と衝突してなくて速度が-ならFallingとする 
        if( meteorCollisionFlg == false ) && ( velocity < 0 ){
            fall()
        }
        //初期位置（地面）より下なら地面にする
        if self.actionStatus == .Standing {
            self.position.y = self.defaultYPosition
        }
        self.sprite.position = CGPoint.zero //playerの位置がだんだん上に上がる対策
    }
    
    //ジャンプ
    func jump() {
        //地面にたっている時だけジャンプする
        guard self.actionStatus == .Standing else { return }
        
        self.jumpAnimation()
        self.moving = false
        self.actionStatus = .Jumping
        self.velocity = self.jumpVelocity
        self.run(self.jumpSound)
    }
    
    func jumpAnimation() {
        self.sprite.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in self.jumpAnimationTextureNames {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: false, restore: false)
        self.sprite.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }
    
    func fall() {
        //すでにFallingならなにもしない
        guard actionStatus != .Falling else{ return }

        actionStatus = .Falling
        fallAinmation()
    }
    
    func fallAinmation(){
        self.sprite.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in self.fallAnimationTextureNames {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: false, restore: false)
        self.sprite.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }
    
    //着地
    func landing(){
        self.actionStatus = .Standing
        self.velocity = 0.0
        self.position.y = self.defaultYPosition
        //SE
        self.run(landingSound)
        //着地エフェクト
        let landingEffect = LandingEffect()
        landingEffect.position.y -= self.size.height / 2
        self.addChild(landingEffect)
        //必殺技処理
        switch ( self.ultraAttackStatus )
        {
        case .landing:
            self.ultraAttackStatus = .attacking
            self.position.y = self.defaultYPosition
            self.ultraAttackJump()
            break
        case .attacking:
            self.ultraAttackEnd()

            break
        case .none:
            //何もしない
            break
        }
        //アニメーション
        if self.attackFlg == false{
            self.stand()
        }
    }
    
    //立ちアニメ
    func stand() {
        sprite.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in self.standAnimationTextureNames {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 1.0, resize: false, restore: false)
        sprite.run(SKAction.repeatForever(action), withKey: "textureAnimation")
    }
    
    //MARK:攻撃
    func attack() {
        //すでにAttack中なら何もせず抜ける
        guard self.attackFlg == false else{ return }
        //AttackフラグON
        self.attackFlg = true
        self.sprite.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in self.attackAnimationTextureNames {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: false, restore: false)
        let stand = SKAction.run{
            if( self.actionStatus == .Standing ){
                self.stand()
            }
        }
        let actions = SKAction.sequence([action,stand])
        self.sprite.run(SKAction.repeat(actions, count:1), withKey: "textureAnimation")
        //attackShape処理
        if self.childNode(withName: self.attackShape.name!) == nil {
            self.addChild(attackShape)
            //print("add attackShape")
            let action1 = SKAction.wait(forDuration: 0.3)
            let action2 = SKAction.removeFromParent()
            let action3 = SKAction.run{
                self.attackFlg = false
                //print("remove attackShape")
            }
            let actions = SKAction.sequence([action1,action2,action3])
            attackShape.run(actions)
        }
        self.playSound("attack03")
    }
    
    func attackMeteor(){
        if self.ultraAttackStatus == .none //必殺技のときは続けて攻撃するため
        {
            //attackShapeオフ
            if let attackNode = self.childNode(withName: self.attackShape.name!)
            {
                attackNode.removeAllActions()
                attackNode.removeFromParent()
            }
            self.attackFlg = false
            //print("---アタックフラグをOFF---")
            //必殺技ゲージ増加
            self.ultraPower += 1
            self.gaugeview?.setMeteorGaugeScale(to: CGFloat(self.ultraPower) / 10.0 )
        }
        //隕石と接触していたら速度を0にする
        if( self.meteorCollisionFlg )
        {
            self.meteorCollisionFlg = false
            self.velocity = 0;
        }
    }
    
    //MARK:必殺技
    func ultraAttack(){
        //print("!!!!!!!!!!ultraAttack!!!!!!!!!")
        self.ultraPower = 0
        gaugeview?.setMeteorGaugeScale(to: 0)
        //入力を受け付けないようにフラグを立てる
        self.ultraAttackStatus = .landing
        if( self.actionStatus != .Standing ) //空中にいる場合
        {
            //地面に戻る
            self.velocity = -2000
        }
        else
        {
            self.ultraAttackStatus = .attacking
            //大ジャンプ
            self.ultraAttackJump()
        }
        //ultraAttackフラグは地面に着いた時に落とす
    }
    func ultraAttackJump(){
        //攻撃Shapeを出す
        self.attackFlg = true
        if let attackNode = self.childNode(withName: self.attackShape.name!) {
            attackNode.removeAllActions()
            attackNode.removeFromParent()
        }
        self.addChild(self.attackShape)
        //print("add ultra attackShape")
        //大ジャンプ
        self.moving = false
        self.actionStatus = .Jumping
        self.velocity = self.ultraAttackSpped
        //サウンド
        self.playSound("jump10")
    }
    func ultraAttackEnd(){
        self.attackFlg = false
        //attackShapeを消す
        if let attackNode = self.childNode(withName: self.attackShape.name!)
        {
            attackNode.removeFromParent()
            //print("remove ultra attackShape")
        }
        //フラグを落とす
        self.ultraAttackStatus = .none
    }
    
    func guardStart() {
        self.sprite.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in self.guardStartAnimationTextureNames {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: false, restore: false)
        self.sprite.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }
    
    func guardEnd() {
        self.sprite.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        if( self.actionStatus != .Standing ){
            for name in guardEndAnimationTextureNames {
                ary.append(SKTexture(imageNamed: name))
            }
        }
        else{
            for name in standAnimationTextureNames {
                ary.append(SKTexture(imageNamed: name))
            }
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: false, restore: false)
        self.sprite.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }

    func moveToRight()
    {
        switch self.posStatus {
        case .center:
            moveTo(.right)
        case .left:
            moveTo(.center)
        case .right:
            break
        }
    }

    func moveToLeft()
    {
        switch self.posStatus {
        case .center:
            moveTo(.left)
        case .right:
            moveTo(.center)
        case .left:
            break
        }
    }
    
    func moveTo(_ pos: PosState){
        guard self.actionStatus == .Standing else{return}
        guard self.moving == false else{return}
        
        self.posStatus = pos
        let move = SKAction.moveTo(x: CGFloat(pos.rawValue), duration: 0.15)
        let stop = SKAction.run(moveStop)
        self.run(self.moveSound)
        self.run(SKAction.sequence([move,stop]))
    }
    
    //MARK: - 停止
    func moveStop() {
        self.moving = false
        self.stand()
    }
    
    //隕石との衝突
    func collisionMeteor(){
        self.meteorCollisionFlg = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
