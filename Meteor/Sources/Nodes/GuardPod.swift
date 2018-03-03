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
    private let podScale: CGFloat = 1 / 5
    private var podHeight: CGFloat
    
    let pod2Top = SKCropNode()
    let pod2Middle = SKCropNode()
    var middleMask: SKShapeNode!
    let pod2Bottom = SKCropNode()
    let gaugeMask = SKCropNode()

    var guardStatus = guardState.enable //ガード状態
    let maxCount:CGFloat = 90.0   //最大値
    var count:CGFloat = 0.0
    let recoverCountTime:Double = 2.0 //ガードを１回復するまでの時間
    let recoverBrokenTime:Double = 5.0  //破壊状態から回復するまでの時間
    let actionKey = "recover"
    var gaugeMaskShape: SKShapeNode!
    let countLabel = SKLabelNode()  //テスト表示用
    
    override init() {
        //初期化
        top_default = SKTexture(imageNamed: "podTop_green")
        top_broken = SKTexture(imageNamed: "podTop_red")
        top = SKSpriteNode(texture: top_default)
        glass = SKSpriteNode(imageNamed: "podGlass")
        bottom = SKSpriteNode(imageNamed: "podBottom")
        podHeight = glass.size.height / 2 - 12 //上下の枠は隠す
        super.init()
        //縮小
        top.xScale *= podScale
        top.yScale *= podScale
        glass.xScale *= podScale
        glass.yScale *= podScale
        bottom.xScale *= podScale
        bottom.yScale *= podScale
        podHeight *= podScale
        //アンカーポイント
        top.anchorPoint.y = 18 / 167 //中央の丸を除いた下端あたり
        bottom.anchorPoint.y = 1.0
        //グラスを中心に位置調整
        top.position.y += podHeight
        bottom.position.y -= podHeight
        //z座標
        glass.zPosition = zPosition
        bottom.zPosition = zPosition + 0.1
        top.zPosition = zPosition + 0.2
        //追加
        self.addChild(self.top)
        self.addChild(self.glass)
        self.addChild(self.bottom)
        //ゲージ部分をマスクするノードの定義
        self.gaugeMaskShape = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 20, height: 20))
        self.gaugeMaskShape.position.x -= 10
        self.gaugeMaskShape.position.y -= 10
        self.gaugeMaskShape.fillColor = UIColor.white
        //cropNodeのマスクに設定
        self.gaugeMask.maskNode = self.gaugeMaskShape
        self.gaugeMaskShape.yScale = CGFloat(self.count) / CGFloat(self.maxCount)
        self.addChild(gaugeMask)
        //
        //cropNodeにゲージのspriteNodeを追加
        let podGaugeSprite = SKSpriteNode(imageNamed: "Pod3")
        podGaugeSprite.xScale /= 5
        podGaugeSprite.yScale /= 5
        self.gaugeMask.addChild(podGaugeSprite)
        //ベース
        let podSprite1 = SKSpriteNode(imageNamed: "Pod0")
        podSprite1.xScale /= 5
        podSprite1.yScale /= 5
        //下マスク
        var bottomPoints = [CGPoint(x: -15, y: -30),
                      CGPoint(x: -15, y: -11),
                      CGPoint(x: 15, y: -11),
                      CGPoint(x: 15, y: -30)]
        let bottomMask = SKShapeNode(points: &bottomPoints, count: bottomPoints.count)
        bottomMask.fillColor = UIColor.red
        self.pod2Bottom.maskNode = bottomMask
        self.pod2Bottom.addChild(podSprite1)
        self.addChild(pod2Bottom)
        //上マスク
        var topPoints = [CGPoint(x: -15, y: 10.5),
                         CGPoint(x: -15, y: 30),
                         CGPoint(x: 15, y: 30),
                         CGPoint(x: 15, y: 10.5),
                         CGPoint(x: 2.2,  y: 10.5),
                         CGPoint(x: 2.2,  y: 8),
                         CGPoint(x: -2.5,  y: 8),
                         CGPoint(x: -2.5,  y: 10.5)]
        let topMask = SKShapeNode(points: &topPoints, count: topPoints.count)
        topMask.fillColor = UIColor.red
        self.pod2Top.maskNode = topMask
        let podSprite2 = SKSpriteNode(imageNamed: "Pod0")
        podSprite2.xScale /= 5
        podSprite2.yScale /= 5
        self.pod2Top.addChild(podSprite2)
        self.addChild(pod2Top)
        //あいだマスク
        middleMask = SKShapeNode(rect: CGRect(x: -10, y: -9, width: 19, height: 19))
        middleMask.fillColor = UIColor.red
        self.pod2Middle.maskNode = middleMask
        let podSprite3 = SKSpriteNode(imageNamed: "Pod0")
        podSprite3.xScale /= 5
        podSprite3.yScale /= 5
        self.pod2Middle.addChild(podSprite3)
        self.addChild(pod2Middle)
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
            //ふわふわ
            let act1 = SKAction.moveBy(x: 0, y: 20, duration: 2)
            act1.timingMode = .easeInEaseOut
            let acts = SKAction.sequence([act1,act1.reversed()])
            self.run(SKAction.repeatForever(acts))
            //
            self.middleMask.run( SKAction.scale(to: 1/5, duration: 1.0) )
            self.pod2Top.run( SKAction.move(to: CGPoint(x: 0, y:0), duration: 1.0) )
            self.pod2Bottom.run( SKAction.move(to: CGPoint(x: 0, y:0), duration: 1.0) )
            self.gaugeMaskShape.run( SKAction.scale(to: 1.0, duration: 1.0) )
            stopRecover()
        }
        else{
            if( self.action(forKey: self.actionKey) == nil ){
                startRecover()
            }
        }
        if( self.guardStatus != .disable ){
            self.gaugeMaskShape.yScale = CGFloat(self.count) / CGFloat(self.maxCount)
        }
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
        //アニメーション
        let duration = 1.0
        self.removeAllActions()
        self.run( SKAction.group( [SKAction.rotate(byAngle: 4 * CGFloat.pi , duration: 1.0),
                                  SKAction.moveTo(y: 0, duration: 1.0)] ))
        self.middleMask.run( SKAction.scale(to: 0, duration: 1.0) )
        self.pod2Top.run( SKAction.move(to: CGPoint(x: 0, y:-11), duration: 1.0) )
        self.pod2Bottom.run( SKAction.move(to: CGPoint(x: 0, y:11), duration: 1.0) )
        top.run(SKAction.moveTo(y: 0, duration: duration))
        let animate = SKAction.animate(with: [top_default,top_broken],
                                       timePerFrame: 0.1,
                                       resize: false,
                                       restore: false)
        top.run(SKAction.repeat(animate, count: 5))
        bottom.run(SKAction.moveTo(y: 0, duration: duration))
        glass.run(SKAction.scaleY(to: 0, duration: duration))
        //self.gaugeMask.isHidden = true
        //ガード不可状態にする
        self.guardStatus = .disable
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
