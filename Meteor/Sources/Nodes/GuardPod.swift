//
//  GuardPod.swift
//  SKGameSample
//
//  Created by Ryota on 2018/02/13.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class GuardPod: SKNode {
    
    var podSprite:SKSpriteNode!
    var podGaugeSprite:SKSpriteNode!
    let gaugeMask = SKCropNode()
    enum guardState{    //ガード状態
        case enable     //ガード可
        case disable    //ガード不可
        case guarding   //ガード中
    }
    var guardStatus = guardState.enable //ガード状態
    let maxCount:CGFloat = 90.0   //最大値
    var count:CGFloat = 0.0
    let recoverCountTime:Double = 2.0 //ガードを１回復するまでの時間
    let recoverBrokenTime:Double = 5.0  //破壊状態から回復するまでの時間
    let actionKey = "recover"
    var gaugeMaskShape: SKShapeNode!
    let countLabel = SKLabelNode()  //テスト表示用
    override init() {
        super.init()
        //マスク
        self.gaugeMaskShape = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 20, height: 20))
        self.gaugeMaskShape.position.x -= 10
        self.gaugeMaskShape.position.y -= 10
        self.gaugeMaskShape.fillColor = UIColor.white
        self.gaugeMask.maskNode = self.gaugeMaskShape
        self.addChild(gaugeMask)
        //画像作成
        podGaugeSprite = SKSpriteNode(imageNamed: "Pod3")
        podGaugeSprite.xScale /= 5
        podGaugeSprite.yScale /= 5
        self.gaugeMask.addChild(podGaugeSprite)
        podSprite = SKSpriteNode(imageNamed: "Pod0")
        podSprite.xScale /= 5
        podSprite.yScale /= 5
        self.addChild(podSprite)
        //ふわふわ
        let act1 = SKAction.moveBy(x: 0, y: 20, duration: 2)
        act1.timingMode = .easeInEaseOut
        let acts = SKAction.sequence([act1,act1.reversed()])
        self.run(SKAction.repeatForever(acts))
        //デバッグ用ラベル
        countLabel.text = String(describing: self.count)
        countLabel.position = CGPoint(x: -10, y: -10) //ポッドの左下
        countLabel.zPosition = self.zPosition + 1
        //self.addChild(countLabel)
    }
    
    //回復開始
    func startRecover(){
        let act1 = SKAction.wait(forDuration: 0.02)
        let act2 = SKAction.run{self.addCount()}
        let acts = SKAction.sequence([act1,act2])
        self.run(SKAction.repeatForever(acts), withKey: self.actionKey)
    }
    //回復停止
    func stopRecover(){
        self.removeAction(forKey: actionKey)
    }
    
    //ガード回復
    @objc func addCount(_ num: CGFloat = 0.1){
        self.count += num
        countLabel.text = String(describing: self.count)
        //最大値を超える場合は最大値にする
        if( self.count >= self.maxCount ){
            self.count = self.maxCount
            //ガード可とする
            self.guardStatus = .enable
            stopRecover()
        }
        else{
            startRecover()
        }
        self.gaugeMaskShape.yScale = CGFloat(self.count) / CGFloat(self.maxCount)
    }
    
    //ガード
    func guardMeteor() -> Bool{
        //ガードできる状態ではない場合
        if self.guardStatus == .enable{
            self.subCount()
            return true
        }
        else{
            return false
        }

    }

    //ガード減らす
    func subCount(_ num: CGFloat = 30.0){
        self.count -= num
        countLabel.text = String(describing: self.count)
        if( self.count <= 0 ){
            self.broken()
        }
        //回復のAcitonが予定されていない場合
        if( self.action(forKey: actionKey) == nil ){
            startRecover()
        }
        self.gaugeMaskShape.yScale = CGFloat(self.count) / CGFloat(self.maxCount)
    }
    
    //ガード破損
    func broken(){
        self.count = 0
        countLabel.text = String(describing: self.count)
        //ガード不可状態にする
        self.guardStatus = .disable
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
