//
//  GameClearScene.swift
//  Meteor
//
//  Created by Ryota on 2018/03/31.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class GameClearScene: SKScene {
    
    //ノード
    let base: SKNode
    let background: BackgroundView
    let ground: Ground
    let player: Player
    let guardPod: GuardPod
    
    var homeButton: SKSpriteNode!
    
    //タッチ処理用
    var beganPos: CGPoint = CGPoint.zero
    var beganPosOnView: CGPoint = CGPoint.zero  //viewの座標系でのタッチ位置
    var tapPoint: CGPoint = CGPoint.zero
    var beganPyPos: CGFloat = 0.0
    var endPyPos:CGFloat = 0.0
    var movePyPos:CGFloat = 0.0
    var touchNode: SKSpriteNode!
    
    init(from: GameScene){
        self.base = from.baseNode
        self.background = from.backgroundView
        self.ground = from.ground
        self.player = from.player
        self.guardPod = from.guardPod
        super.init(size: from.frame.size)
        self.scaleMode = from.scaleMode
    }
    
    override func didMove(to view: SKView) {
        self.base.removeFromParent()
        self.addChild(self.base)
        //ホームボタン
        homeButton = SKSpriteNode(imageNamed: "home")
        homeButton.name = "HomeButton"
        homeButton.size.width = 75.0
        homeButton.size.height = 75.0
        homeButton.zPosition = 100001
        homeButton.position.x = frame.size.width/3
        homeButton.position.y = frame.size.height/5
        homeButton.xScale = 1
        homeButton.yScale = 1
        self.addChild(homeButton)
        //クリアの文字
        let labelBase = SKNode()
        labelBase.position.x = self.frame.width * 0.5
        labelBase.position.y = self.frame.height * 0.7
        var clearLabels: [SKLabelNode] = []
        var delay:Double = 0
        var posX: CGFloat = 0
        for char in "CLEAR!" {
            let label = SKLabelNode(text: String(char))
            label.fontName = "GillSansStd-ExtraBold"
            label.fontSize = 60
            label.position.x = posX
            posX += 50
            clearLabels.append(label)
            labelBase.addChild(label)
            let act1 = SKAction.moveBy(x: 0, y: 20, duration: 0.5)
            act1.timingMode = .easeInEaseOut
            let wait = SKAction.wait(forDuration: 3)
            let acts = SKAction.sequence([act1,act1.reversed(),wait])
            let wait2 = SKAction.wait(forDuration: delay)
            label.run(SKAction.sequence([wait2,SKAction.repeatForever(acts)]))
            delay += 0.5
        }
        labelBase.position.x -= CGFloat((clearLabels.count-1) * 50) / 2
        self.addChild(labelBase)
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.player.update(meteor: nil, meteorSpeed: 0.0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first as UITouch? {
            self.beganPosOnView = CGPoint(x: touch.location(in: view).x,y: frame.maxY - touch.location(in: view).y ) //y座標を反転する
            self.beganPos = touch.location(in: self)
            //self.beganPyPos = (self.camera?.position.y)! //カメラの移動量を計算するために覚えておく
            //タッチしたノードを記録しておく
            touchNode = self.atPoint(beganPos) as? SKSpriteNode
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches
        {
            let endPos = touch.location(in: self)
            //ボタンタップ判定
            let node:SKSpriteNode? = self.atPoint(endPos) as? SKSpriteNode;
            if( touchNode != nil ) && ( node == touchNode ) { // タッチ開始時と同じノードで離した
                print("---タップを離したノード=\(String(describing: node?.name))---")
                var buttonPushFlg = true
                switch node{ //押したボタン別処理
                case let node where node == self.homeButton :
                    homeButtonAction()
                default:
                    buttonPushFlg = false
                }
            }
        }
    }
    
    func homeButtonAction()
    {
        let actions = SKAction.sequence([
            SKAction.run { self.playSound("push_45") },
            SKAction.run {
                let gameScene = GameScene(size: self.frame.size)
                self.view?.presentScene(gameScene)
            }
            ])
        run(actions)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
