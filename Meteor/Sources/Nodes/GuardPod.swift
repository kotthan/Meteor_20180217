//
//  GuardPod.swift
//  SKGameSample
//
//  Created by Ryota on 2018/02/13.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class GuardPod: SKNode {
    
    var podSprites:[SKSpriteNode] = []
    let gaugeMask = SKCropNode()
    enum guardState{    //ガード状態
        case enable     //ガード可
        case disable    //ガード不可
        case guarding   //ガード中
    }
    var guardStatus = guardState.enable //ガード状態
    let maxCount = 3    //最大ガード回数
    var count = 0
    let recoverCountTime:Double = 2.0 //ガードを１回復するまでの時間
    let recoverBrokenTime:Double = 5.0  //破壊状態から回復するまでの時間
    let actionKey = "recover"
    let countLabel = SKLabelNode()  //テスト表示用
    override init() {
        super.init()
        //画像作成
        for i in 0...maxCount {
            let pod = SKSpriteNode(imageNamed: "Pod"+String(i))
            pod.xScale /= 5
            pod.yScale /= 5
            podSprites.append(pod)
            pod.isHidden = true
            self.addChild(pod)
        }
        self.podSprites[0].isHidden = false
        //ふわふわ
        let act1 = SKAction.moveBy(x: 0, y: 20, duration: 2)
        act1.timingMode = .easeInEaseOut
        let acts = SKAction.sequence([act1,act1.reversed()])
        self.run(SKAction.repeatForever(acts))
        //デバッグ用ラベル
        countLabel.text = String(self.count)
        countLabel.position = CGPoint(x: -10, y: -10) //ポッドの左下
        countLabel.zPosition = self.zPosition + 1
        //self.addChild(countLabel)
    }
    
    //回復開始
    func startRecover(){
        let act1 = SKAction.wait(forDuration: self.recoverCountTime)
        let act2 = SKAction.run{self.addCount()}
        let acts = SKAction.sequence([act1,act2])
        self.run(acts, withKey: self.actionKey)
    }

    //ガード回復
    @objc func addCount(_ num: Int = 1){
        podSprites[self.count].isHidden = true
        self.count += num
        countLabel.text = String(self.count)
        //最大値を超える場合は最大値にする
        if( self.count >= self.maxCount ){
            self.count = self.maxCount
            //ガード可とする
            self.guardStatus = .enable
        }
        else{
            startRecover()
        }
        podSprites[self.count].isHidden = false
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
    func subCount(_ num: Int = 1){
        podSprites[self.count].isHidden = true
        self.count -= num
        countLabel.text = String(self.count)
        if( self.count <= 0 ){
            self.broken()
        }
        //回復のAcitonが予定されていない場合
        if( self.action(forKey: actionKey) == nil ){
            //回復Action追加
            let act1 = SKAction.wait(forDuration: self.recoverCountTime)
            let act2 = SKAction.run{self.addCount()}
            let acts = SKAction.sequence([act1,act2])
            self.run(acts, withKey: self.actionKey)
        }
        podSprites[self.count].isHidden = false
    }
    
    //ガード破損
    func broken(){
        self.count = 0
        countLabel.text = String(self.count)
        //通常の回復Actionをキャンセル
        self.removeAction(forKey: self.actionKey)
        //全快までのスケジュール追加
        let act1 = SKAction.wait(forDuration: self.recoverBrokenTime)
        let act2 = SKAction.run{self.addCount(self.maxCount)}
        let acts = SKAction.sequence([act1,act2])
        self.run(acts, withKey: self.actionKey)
        //ガード不可状態にする
        self.guardStatus = .disable
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
