//
//  GuardPod.swift
//  SKGameSample
//
//  Created by Ryota on 2018/02/13.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class GuardPod: SKNode {
    
    enum guardState{    //ガード状態
        case enable     //ガード可
        case disable    //ガード不可
        case guarding   //ガード中
    }
    
    private let top: SKSpriteNode
    private let top_default: SKTexture
    private let top_broken: SKTexture
    private let glass: SKSpriteNode
    private let bottom: SKSpriteNode
    private let gauge = SKCropNode()
    private let gaugeMask: SKShapeNode
    private let podScale: CGFloat = 1 / 4
    private let gaugeHeight: CGFloat
    var gaugeView: GaugeView?
    
    var guardStatus = guardState.enable         //ガード状態
    let maxCount:CGFloat = 90.0                 //最大値
    var count:CGFloat = 0.0
    let recoverCountTime:Double = 2.0           //ガードを１回復するまでの時間
    let recoverBrokenTime:Double = 5.0          //破壊状態から回復するまでの時間
    let actionKey = "recover"
    
    override init() {
        //初期化
        top_default = SKTexture(imageNamed: "podTop_green")
        top_broken = SKTexture(imageNamed: "podTop_red")
        top = SKSpriteNode(texture: top_default)
        glass = SKSpriteNode(imageNamed: "podGlass")
        bottom = SKSpriteNode(imageNamed: "podBottom")
        gaugeHeight = glass.size.height - 24 //上下の枠は隠すために12ptずつ引く
        gaugeMask = SKShapeNode(rect: CGRect(origin: CGPoint.zero,
                                             size:CGSize(width: glass.size.width,
                                                         height: gaugeHeight)))
        super.init()
        let gaugeSprite = SKSpriteNode(imageNamed: "podGauge")
        gaugeSprite.yScale *= glass.size.height / gaugeSprite.size.height //ガラスいっぱいのサイズに伸ばす
        //ゲージ調整用マスク
        gaugeMask.fillColor = UIColor.black
        gauge.maskNode = gaugeMask
        gauge.addChild(gaugeSprite)
        //縮小
        xScale = podScale
        yScale = podScale
        //アンカーポイント
        top.anchorPoint.y = 18 / 167 //中央の丸を除いた下端あたり
        bottom.anchorPoint.y = 1.0
        gaugeMask.position.x -= glass.size.width / 2
        gaugeMask.position.y -= gaugeHeight / 2
        //グラスを中心に位置調整
        top.position.y += gaugeHeight / 2
        bottom.position.y -= gaugeHeight / 2
        //z座標
        glass.zPosition = zPosition
        bottom.zPosition = zPosition + 0.1
        top.zPosition = zPosition + 0.2
        gaugeMask.yScale = CGFloat(self.count) / CGFloat(self.maxCount)
        gaugeView?.guardGaugeMask.xScale = CGFloat(self.count) / CGFloat(self.maxCount)
        gaugeView?.podGaugeMask.yScale = CGFloat(self.count) / CGFloat(self.maxCount)
        //追加
        addChild(top)
        glass.addChild(gauge)
        addChild(glass)
        addChild(bottom)
        //ふわふわ
        let act1 = SKAction.moveBy(x: 0, y: 20, duration: 2)
        act1.timingMode = .easeInEaseOut
        let acts = SKAction.sequence([act1,act1.reversed()])
        self.run(SKAction.repeatForever(acts))
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
    @objc func addCount(_ num: CGFloat = 0.2){
        self.count += num
        //最大値を超える場合は最大値にする
        if( self.count >= self.maxCount ){
            self.count = self.maxCount
            //ガード可とする
            self.guardStatus = .enable
            //ふわふわ
            let act1 = SKAction.moveBy(x: 0, y: 20, duration: 2)
            act1.timingMode = .easeInEaseOut
            let acts = SKAction.sequence([act1,act1.reversed()])
            self.run(SKAction.repeatForever(acts))
            repairAnimation(duration: 1.0)
            stopRecover()
        }
        else{
            if( self.action(forKey: self.actionKey) == nil ){
                startRecover()
            }
        }
        if( self.guardStatus != .disable ){
            self.gaugeMask.yScale = CGFloat(self.count) / CGFloat(self.maxCount)
            gaugeView?.guardGaugeMask.xScale = CGFloat(self.count) / CGFloat(self.maxCount)
            gaugeView?.podGaugeMask.yScale = CGFloat(self.count) / CGFloat(self.maxCount)
        }
    }
    
    func repairAnimation(duration: TimeInterval){
        let duration = 1.0
        top.run(SKAction.animate(with: [top_default], timePerFrame: 0.1))
        top.run(SKAction.moveTo(y: gaugeHeight / 2, duration: duration))
        bottom.run(SKAction.moveTo(y: -gaugeHeight / 2, duration: duration))
        glass.run(SKAction.scaleY(to: 1.0, duration: duration))
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
        if( self.count <= 0 ){
            self.broken()
        }
        //回復のAcitonが予定されていない場合
        if( self.action(forKey: actionKey) == nil ){
            startRecover()
        }
        self.gaugeMask.yScale = CGFloat(self.count) / CGFloat(self.maxCount)
        gaugeView?.guardGaugeMask.xScale = CGFloat(self.count) / CGFloat(self.maxCount)
        gaugeView?.podGaugeMask.yScale = CGFloat(self.count) / CGFloat(self.maxCount)
    }
    
    //ガード破損
    func broken(){
        self.count = 0
        //アニメーション
        self.removeAllActions()
        self.run( SKAction.group( [SKAction.rotate(byAngle: 4 * CGFloat.pi , duration: 1.0),
                                  SKAction.moveTo(y: 0, duration: 1.0)] ))
        brokenAnimation(duration: 1.0)
        //ガード不可状態にする
        self.guardStatus = .disable
    }
    
    private func brokenAnimation(duration: TimeInterval){
        let flashCount = 10
        //topの画像を入れ替える
        let animate = SKAction.animate(with: [top_default,top_broken],
                                       timePerFrame: duration / Double(flashCount),
                                       resize: false,
                                       restore: false)
        top.run(SKAction.repeat(animate, count: flashCount))
        //閉じる
        top.run(SKAction.moveTo(y: 0, duration: duration))
        bottom.run(SKAction.moveTo(y: 0, duration: duration))
        glass.run(SKAction.scaleY(to: 0, duration: duration))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
