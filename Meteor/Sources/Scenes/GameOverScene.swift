//
//  GameOverScene.swift
//  Meteor
//
//  Created by Ryota on 2018/03/26.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {

    private var score: Int = 0
    private var highScore: Int = 0
    private let keyHighScore = "highScore"
    private var gameOverView: GameOverView!
    //MARK: タッチ関係プロパティ
    private var beganPos: CGPoint = CGPoint.zero
    private var beganPosOnView: CGPoint = CGPoint.zero  //viewの座標系でのタッチ位置
    private var tapPoint: CGPoint = CGPoint.zero
    private var beganPyPos: CGFloat = 0.0
    private var endPyPos:CGFloat = 0.0
    private var movePyPos:CGFloat = 0.0
    private var touchNode: SKSpriteNode!
    
    override init(size: CGSize) {
        var scaleMode:SKSceneScaleMode = .aspectFill
        var frameSize = size
        //iPadの場合は上書きする
        if (UIDevice.current.model.range(of: "iPad") != nil) {
            frameSize = CGSize(width: 375.0, height: 667.0)
            scaleMode = .fill
        }
        super.init(size: frameSize)
        self.scaleMode = scaleMode
    }
    
    func setScore(score: Int, highScore: Int){
        self.score = score
        //ハイスコア更新
        print("------------score:\(score) high:\(highScore)------------")
        if( score > highScore ){
            self.highScore = score
            print("------------hidh score!------------")
            UserDefaults.standard.set(self.highScore, forKey: self.keyHighScore) //データの保存
        }
        else{
            self.highScore = highScore
        }
    }
    
    override func didMove(to view: SKView) {
        self.gameOverView = GameOverView(frame: self.frame, score: self.score, highScore: self.highScore )
        self.addChild(self.gameOverView)
    }

    //MARK: - 関数定義　タッチ処理
    //MARK: タッチダウンされたときに呼ばれる関数
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first as UITouch?
        {
            //タッチしたノードを記録しておく
            touchNode = self.atPoint(touch.location(in: self)) as? SKSpriteNode
            print("---タップをしたノード=\(String(describing: touchNode?.name))---")
        }
    }
    //MARK: タッチアップされたときに呼ばれる関数
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first as UITouch?
        {
            //ボタンタップ判定
            let node:SKSpriteNode? = self.atPoint(touch.location(in: self)) as? SKSpriteNode;
            if( touchNode != nil ) && ( node == touchNode ) { // タッチ開始時と同じノードで離した
                print("---タップを離したノード=\(String(describing: node?.name))---")
                switch node{ //押したボタン別処理
                case let node where node == gameOverView?.HomeButton :
                    homeButtonAction()
                case let node where node ==  gameOverView?.ReStartButton :
                    reStartButtonAction()
                default:
                    break
                }
            }
        }
    }
    
    func homeButtonAction()
    {
        let actions = SKAction.sequence([
            SKAction.run { self.playSound("push_45") },
            SKAction.run { self.gameOverView.audioPlayer.stop() },
            SKAction.run { adBanner.isHidden = true },
            SKAction.run { self.newGame() }
            ])
        run(actions)
    }
    
    func reStartButtonAction()
    {
        let gameScene = GameScene(size: frame.size)
        gameScene.retryFlg = true
        let actions = SKAction.sequence([
            SKAction.run { self.playSound("push_45") },
            SKAction.run { self.gameOverView.audioPlayer.stop() },
            SKAction.run { adBanner.isHidden = true },
            SKAction.run { self.view!.presentScene(gameScene)}
            ])
        run(actions)
    }
    
    func newGame()
    {
        let gameScene = GameScene(size: frame.size)
        self.view?.presentScene(gameScene)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
