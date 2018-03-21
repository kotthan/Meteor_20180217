//
//  GameScene.swift
//  Meteor
//
//  Created by Kazuaki Oe on 2018/02/17.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation
import AudioToolbox
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

@available(iOS 9.0, *)
class GameScene: SKScene, SKPhysicsContactDelegate {
    let debug = false  //デバッグフラグ
	//MARK: - 基本構成
    //MARK: ノード
    let baseNode = SKNode()
    var backgroundView: BackgroundView!
    let player = Player()
    var ground: Ground!
    var lowestShape: LowestShape!
    var guardPod: GuardPod!
    var titleNode: TitleNode!
    var gaugeview: GaugeView!
    var pauseButton: PauseButton!
    var guardShape: GuardShape!                                    //防御判定シェイプノード
    var creditButton = SKLabelNode()
    var creditBackButton = SKLabelNode()
    var score = 0                                                   //スコア
    var combo = 0                                                   //スコア
    let highScoreLabel = SKLabelNode()                              //ハイスコア表示ラベル
    var highScore = 0                                               //ハイスコア
    //MARK: 画面
    var pauseView: PauseView!                                       //ポーズ画面
    var gameOverView: GameOverView!
    var hudView = HUDView()                                         //HUD
    
    var mainBgmPlayer: AVAudioPlayer!
    var titleBgmPlayer: AVAudioPlayer!
    
    //MARK: タイマー
    var meteorTimer: Timer?                                         //隕石用タイマー
    
    //MARK: フラグ
    enum SceneState {
        case Title      //タイトル表示
        case Prologue   //スタートアニメーション
        case Credits    //credit表示
        case GameWait   //ゲーム開始待ち
        case Game       //ゲーム中
        case Pause      //ポーズ
        case GameOver   //ゲームオーバー
    }
    var sceneState:SceneState = .Title
    var gameoverFlg : Bool = false                                  //ゲームオーバーフラグ
    var gameFlg:Bool = false
    var gameWaitFlag = false
    //スタート時にplayerが空中の場合に待つためのフラグ
    var creditFlg = false
    var retryFlg = false                                            //リトライするときにそのままゲームスタートさせる

    //調整用パラメータ

    var speedFromMeteorAtGuard : CGFloat = 350                      //隕石を防御した時にプレイヤーが受ける隕石の速度
    var cameraMax : CGFloat = 1450                                  //カメラの上限
    //MARK: タッチ関係プロパティ
    var beganPos: CGPoint = CGPoint.zero
    var beganPosOnView: CGPoint = CGPoint.zero  //viewの座標系でのタッチ位置
	var tapPoint: CGPoint = CGPoint.zero
    var beganPyPos: CGFloat = 0.0
    var endPyPos:CGFloat = 0.0
    var movePyPos:CGFloat = 0.0
    var touchNode: SKSpriteNode!
    enum TouchAction {  //タッチアクション
        case tap        //タップ
        case swipeUp    //上スワイプ
        case swipeDown  //下スワイプ
        case swipeLeft  //左スワイプ
        case swipeRight //右スワイプ
    }
    
    //MARK: 画面移動プロパティ
	var screenSpeed: CGFloat = 28.0
	var screenSpeedScale: CGFloat = 1.0
    
    var pCamera: SKCameraNode?
    
    //MARK: データ保存
    var keyHighScore = "highScore"
    
    //MARK: - 関数定義 シーン関係
	//MARK: シーンが表示されたときに呼ばれる関数
	override func didMove(to view: SKView)
    {
        //MARK: 設定関係
        self.backgroundColor = SKColor.clear                           //背景色
        self.physicsWorld.contactDelegate = self                       //接触デリゲート
        self.physicsWorld.gravity = CGVector(dx:0, dy:0)               //重力設定
        
		//MARK: 背景
        self.addChild(self.baseNode)                                //ベース追加
        self.baseNode.addChild(self.player)                 //プレイヤーベース追加
 
        //MARK: BGM
        //MainBGM
        let MainSoundFilePath: String = Bundle.main.path(forResource: "crasy", ofType: "mp3")!
        let MainfileURL: URL = URL(fileURLWithPath: MainSoundFilePath)
        try! mainBgmPlayer = AVAudioPlayer(contentsOf: MainfileURL)
        mainBgmPlayer.numberOfLoops = -1
        mainBgmPlayer.prepareToPlay()
        //TitleBGM
        let TitleSoundFilePath: String = Bundle.main.path(forResource: "yabusaka", ofType: "mp3")!
        let TitlefileURL: URL = URL(fileURLWithPath: TitleSoundFilePath)
        try! titleBgmPlayer = AVAudioPlayer(contentsOf: TitlefileURL)
        titleBgmPlayer.numberOfLoops = -1
        titleBgmPlayer.prepareToPlay()
        titleBgmPlayer.play()

		//MARK: SKSファイルを読み込み
		if let scene = SKScene(fileNamed: "GameScene.sks")
        {
            //===================
			//MARK: プレイヤー
			//===================
			scene.enumerateChildNodes(withName: "player", using: { (node, stop) -> Void in
				let player = node as! SKSpriteNode
                self.player.setSprite(sprite: player)
                //print("---SKSファイルよりプレイヤー＝\(player)を読み込みました---")
                //アニメーション
                self.player.stand()
            })
            if( debug ){ //デバッグ用
                //addBodyFrame(node: player)  //枠表示
            }
		}
        
        //MARK: カメラ
        let camera = SKCameraNode()
        camera.position = CGPoint(x: self.frame.size.width/2,y: 1005)
        self.addChild(camera)
        self.camera = camera
        //背景
        backgroundView = BackgroundView(frame: self.frame)
        self.baseNode.addChild(backgroundView)
        //地面
        ground = Ground(frame: self.frame)
        self.baseNode.addChild(ground)
        //LowestShape（ゲームオーバー判定用）
        lowestShape = LowestShape(frame: self.frame)
        self.baseNode.addChild(lowestShape)
        //隕石ベース
        self.addChild(self.meteorBase)
        //ガード判定用シェイプ
        self.guardShape = GuardShape(size: self.player.size)
        //タイトルノード
        titleNode = TitleNode()
        self.baseNode.addChild(titleNode)
        //ゲージ関係
        gaugeview = GaugeView(frame: self.frame)
        gaugeview.setMeteorGaugeScale(to: CGFloat(self.player.ultraPower) / 10.0)
        gaugeview.position.y -= gaugeview.size.height
        self.camera!.addChild(gaugeview)
        gaugeview.isHidden = true
        
        //===================
        //MARK: credit表示ボタン
        //===================
        self.creditButton.fontName = "GillSansStd-ExtraBold"
        self.creditButton.fontSize = 20
        self.creditButton.text = "Credits"
        //self.creditButton.position.x = frame.width/2
        //self.creditButton.position.y =
        self.creditButton.position = CGPoint(
            x: frame.width/2, y: 1300)
        print("creditのposition=\(self.creditButton.position)")
        self.creditButton.setzPos(.CreditButton)
        //タッチ判定用SpriteNode
        let creditButtonNode = SKSpriteNode(color: UIColor.clear, size: creditButton.frame.size)
        creditButtonNode.position.y += creditButton.frame.size.height / 2
        creditButtonNode.xScale = 1.2
        creditButtonNode.yScale = 1.5
        creditButtonNode.name = "credit"
        creditButton.addChild(creditButtonNode)
        self.baseNode.addChild(self.creditButton)
        //===================
        //MARK: credit戻るボタン
        //===================
        self.creditBackButton.fontName = "GillSansStd-ExtraBold"
        self.creditBackButton.fontSize = 30
        self.creditBackButton.text = "Back"
        self.creditBackButton.position.x = self.frame.size.width / 2
        self.creditBackButton.position.y += 70 //適当
        self.creditBackButton.setzPos(.CreditBuckButton)
        //タッチ判定用SpriteNode
        let creditBackButtonNode = SKSpriteNode(color: UIColor.clear, size: creditBackButton.frame.size)
        creditBackButtonNode.position.y = creditButton.frame.size.height / 2
        creditBackButtonNode.xScale = 1.2
        creditBackButtonNode.yScale = 1.5
        creditBackButtonNode.name = "BackTitle"
        creditBackButton.addChild(creditBackButtonNode)
        self.baseNode.addChild(self.creditBackButton)
        
        //===================
        //MARK: ガードゲージ
        //===================
        guardPod = GuardPod(gaugeView: gaugeview)
        guardPod.position = CGPoint(x: self.player.sprite.position.x - 30, y: self.player.sprite.position.y )
        guardPod.setzPos(.GuadPod)
        self.player.addChild(guardPod)
        
        //ハイスコアラベル
        if ( UserDefaults.standard.object(forKey: keyHighScore) != nil )
        {
            self.highScore = UserDefaults.standard.integer(forKey: self.keyHighScore) //保存したデータの読み出し
            print("read data\(keyHighScore) : \(self.highScore)")
        }
        self.highScoreLabel.text = String( self.highScore ) //ハイスコアを表示する
        self.highScoreLabel.position = CGPoint(             //表示位置は適当
            x: 280.0,
            y: 85.0
        )
        self.highScoreLabel.setzPos(.HighScore)             //プレイヤーの後ろ
        self.baseNode.addChild(self.highScoreLabel)         //背景に固定のつもりでbaseNodeに追加
        self.highScoreLabel.isHidden = true
        //===================
        //MARK: HUD
        //===================
        self.hudView = HUDView(frame: self.frame)
        self.view!.addSubview(hudView)
        hudView.highScoreLabel.text = "BEST " + String(self.highScore)
        //===================
        //MARK: ポーズ画面
        //===================
        //pauseview
        pauseView = PauseView(frame: self.frame)
        pauseView.isHidden = true
        self.camera?.addChild(pauseView)
        //pauseButton
        pauseButton = PauseButton(frame:self.frame)
        pauseButton.setPauseFunc{
            self.sliderHidden = !self.sliderHidden
            self.pauseView.isHidden = self.sliderHidden
            self.view!.scene?.isPaused = !self.sliderHidden
            self.mainBgmPlayer.pause()
        }
        pauseButton.setResumeFunc{
            self.sliderHidden = !self.sliderHidden
            self.pauseView.isHidden = self.sliderHidden
            self.view!.scene?.isPaused = !self.sliderHidden
            self.mainBgmPlayer.play()
        }
        pauseButton.isHidden = true     //タイトル画面では非表示
        self.camera?.addChild(pauseButton)
        // アプリがバックグラウンドから復帰した際に呼ぶ関数の登録
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(becomeActive(_:)),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        if(debug)
        {
            view.showsPhysics = true
            let playerBaseShape = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 10, height: 10))
            playerBaseShape.zPosition = -50
            player.addChild( playerBaseShape )
        }
        setDefaultParam()
        if( retryFlg )
        { //リトライ時はそのままスタートする
            startButtonAction()
        }
        view.showsPhysics = false
	}
    
    //アプリがバックグラウンドから復帰した際に呼ばれる関数
    //起動時にも呼ばれる
    @objc func becomeActive(_ notification: Notification) {
        guard gameFlg == true else{ return } // ゲーム中でなければなにもせず抜ける
        isPaused = true     //ポーズ状態にする
        if( sliderHidden == true ){ //ポーズボタンが押されていなかった
            if( gameoverFlg == false ){ //ゲームオーバになっていない時
               pauseButton.pauseAction()
            }
        }
    }
    
    //MARK: シーンのアップデート時に呼ばれる関数
    override func update(_ currentTime: TimeInterval)
    {
        self.meteorBase.update()
        self.player.update(meteor: self.meteorBase.meteores.first, meteorSpeed: self.meteorBase.meteorSpeed)
        
        if (gameFlg == false)
        { }
        else if (player.actionStatus != .Standing) && (self.player.position.y + 200 > self.frame.size.height/2)
        {
            if( self.player.position.y < self.cameraMax ) //カメラの上限を超えない範囲で動かす
            {
                self.camera!.position = CGPoint(x: self.frame.size.width/2,y: self.player.position.y + 150 );
                if ( self.creditFlg == true ) && ( self.player.ultraAttackStatus == .attacking ) &&
                    ( self.player.velocity < 0 ){
                    self.titleNode.isHidden = false
                    self.titleNode.alpha = 1.0
                    self.childNode(withName: "credits")?.removeFromParent()
                    self.creditButton.isHidden = false
                    self.creditButton.alpha = 1.0
                    if( self.camera!.position.y < titleNode.TitleNode?.position.y ){
                        self.camera!.position = CGPoint(x: self.frame.size.width/2,y: (titleNode.TitleNode?.position.y)!)
                        self.gameFlg = false
                        self.creditFlg = false
                    }
                }
            }
        }
        else
        {
            self.camera!.position = CGPoint(x: self.frame.size.width/2,y: self.frame.size.height/2)
        }
    }
    //MARK: すべてのアクションと物理シミュレーション処理後、1フレーム毎に呼び出される
    override func didSimulatePhysics()
    {
        self.player.didSimulatePhysics()
    }
    //MARK: - 関数定義　タッチ処理
    //MARK: タッチダウンされたときに呼ばれる関数
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard ( player.ultraAttackStatus == .none ) else { //必殺技中でなければ次の処理に進む
            return
        }
        
        if let touch = touches.first as UITouch?
        {
            self.beganPosOnView = CGPoint(x: touch.location(in: view).x,
                                          y: frame.maxY - touch.location(in: view).y ) //y座標を反転する
            self.beganPos = touch.location(in: self)
            self.beganPyPos = (camera?.position.y)!                     //カメラの移動量を計算するために覚えておく
            if( touchPath != nil ){ //すでにタッチの軌跡が描かれていれば削除
                touchPath.removeFromParent()
            }
            //タッチしたノードを記録しておく
            touchNode = self.atPoint(beganPos) as? SKSpriteNode
            print("---タップをしたノード=\(String(describing: touchNode?.name))---")
            if( touchNode?.name == "credit"  ){
                let scale = SKAction.scale(to: 1.5, duration: 0.05)
                let routate1 = SKAction.rotate(byAngle: CGFloat(10.0 / 180.0 * Double.pi), duration: 0.05)
                let routate2 = SKAction.rotate(byAngle: CGFloat(-20.0 / 180.0 * Double.pi), duration: 0.05)
                let routate3 = SKAction.rotate(byAngle: CGFloat(20.0 / 180.0 * Double.pi), duration: 0.05)
                let routate4 = SKAction.rotate(byAngle: CGFloat(-10.0 / 180.0 * Double.pi), duration: 0.05)
                self.creditButton.run( SKAction.sequence([scale,routate1,routate2,routate3,routate4]) )
            }
        }
    }

    //MARK: タッチ移動されたときに呼ばれる関数
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard ( player.ultraAttackStatus == .none ) else { //必殺技中でなければ次の処理に進む
            return
        }
        guard ( gameoverFlg == false ) else {  //ゲームオーバでなければ次の処理に進む
            return
        }
        //ポーズでなければ次の処理に進む
        guard ( self.view!.scene?.isPaused == false ) else {
            return
        }
        
        for touch: AnyObject in touches
        {
            let endPosOnView = CGPoint(x: touch.location(in: view).x,
                                       y: frame.maxY - touch.location(in: view).y )
            drawTouchPath(begin: beganPosOnView, end: endPosOnView)
            switch getTouchAction(begin: beganPosOnView, end: endPosOnView) {
            case .tap:
                break   //何もしない
            case .swipeDown:
                if gameFlg == true{
                    guardAction(endFlg: false)
                }
            case .swipeUp: //ジャンプしてない場合のみ
                break   //何もしない
            case .swipeLeft: //ジャンプしてない場合のみ
                break   //何もしない
            case .swipeRight://ジャンプしてない場合のみ
                break   //何もしない
            }
            if( self.touchNode?.name == "credit" ){
                if let node = self.atPoint(touch.location(in: self)) as? SKSpriteNode {
                    if self.touchNode != node {
                        self.creditButton.run( SKAction.scale(to: 1, duration: 0.05) )
                        self.touchNode = nil
                    }
                }
            }
         }
    }
    
    //MARK: タッチアップされたときに呼ばれる関数
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard ( player.ultraAttackStatus == .none ) else { //必殺技中でなければ次の処理に進む
            return
        }
        for touch: AnyObject in touches
        {
            let endPosOnView = CGPoint(x: touch.location(in: view).x,
                                       y: frame.maxY - touch.location(in: view).y )
            let endPos = touch.location(in: self)
            //ボタンタップ判定
            let node:SKSpriteNode? = self.atPoint(endPos) as? SKSpriteNode;
            if( touchNode != nil ) && ( node == touchNode ) { // タッチ開始時と同じノードで離した
                print("---タップを離したノード=\(String(describing: node?.name))---")
                var buttonPushFlg = true
                switch node{ //押したボタン別処理
                case let node where node == gaugeview.ultraAttackIcon :
                    if self.creditButton.childNode(withName: "credit") != nil {
                        gameFlg = true
                    }
                    guard gameoverFlg == false else{ break }
                    ultraAttack()
                case let node where node == creditButton.childNode(withName: "credit"):
                    creditAction()
                case let node where node?.name == "BackTitle":
                    gameFlg = true
                    ultraAttack()
                case let node where node == gameOverView?.HomeButton :
                    homeButtonAction()
                case let node where node ==  gameOverView?.ReStartButton :
                    reStartButtonAction()
                case let node where node == pauseButton?.PauseButton :
                    pauseButton.tapped()
                default:
                    buttonPushFlg = false
                }
                // ボタンが押されていればスワイプ処理はしないので抜ける
                if buttonPushFlg == true
                {
                    return
                }
            }
            //スワイプ判定
            drawTouchPath(begin: beganPosOnView, end: endPosOnView)
            switch getTouchAction(begin: beganPosOnView, end: endPosOnView) {
            case .tap:
                if gameFlg == false && gameoverFlg == false && creditFlg == false {
                    let actions = SKAction.sequence(
                        [ SKAction.run {
                            TitleNode.TapAction(self.titleNode.TitleNode, node2: self.titleNode.TitleMeteorNode)
                            },
                          SKAction.wait(forDuration: 1.5),
                          SKAction.run {
                            self.startButtonAction()
                            }
                        ])
                    run(actions)
                } else {
                    if gameoverFlg == false{
                        self.player.attack()
                    }
                }
            case .swipeDown:
                if gameFlg == true{
                    guardAction(endFlg: true)
                }
            case .swipeUp where player.actionStatus == .Standing: //ジャンプしてない場合のみ
                self.player.jump()
                let particles = SKEmitterNode(fileNamed: "jump.sks")
                //接触座標にパーティクルを放出するようにする。
                particles!.position = CGPoint(x: player.position.x,
                                           y: player.position.y)
                //0.7秒後にシーンから消すアクションを作成する。
                let action11 = SKAction.wait(forDuration: 0.5)
                let action21 = SKAction.removeFromParent()
                let actionAll1 = SKAction.sequence([action11, action21])
                //パーティクルをシーンに追加する。
                self.addChild(particles!)
                //アクションを実行する。
                particles!.run(actionAll1)
            case .swipeLeft where player.actionStatus == .Standing: //ジャンプしてない場合のみ
                self.player.moveToLeft()
            case .swipeRight where player.actionStatus == .Standing://ジャンプしてない場合のみ
                self.player.moveToRight()
            default:
                break   //何もしない
            }
        }
    }
    func getTouchAction(begin: CGPoint, end:CGPoint) ->TouchAction
    {
        let moveX = end.x - begin.x
        let moveY = end.y - begin.y
        let margin:CGFloat = 50
        //移動量が少なかったらタップ
        if( fabs(moveX) < margin && fabs(moveY) < margin ){
            return TouchAction.tap
        }
        // 絶対値が大きいほうの動作を優先、値の正負で方向を判定する
        switch( moveX,moveY ){
        case (let x, let y) where fabs(x) > fabs(y) && x > 0:
            return TouchAction.swipeRight
        case (let x, let y) where fabs(x) > fabs(y) && x < 0:
            return TouchAction.swipeLeft
        case (let x, let y) where fabs(x) <= fabs(y) && y > 0:
            return TouchAction.swipeUp
        case (let x, let y) where fabs(x) <= fabs(y) && y < 0:
            return TouchAction.swipeDown
        default:
            break
        }
        //ここは通らないはず
        print("ありえないTouchAction x:\(moveX),y:\(moveY)")
        return TouchAction.tap
    }
    var touchPath: SKShapeNode! = nil
    func drawTouchPath(begin: CGPoint, end:CGPoint){
        guard debug else { return } //デバッグフラグがfalseならなにもしない
        //カメラが存在するかどうかのチェック
        guard let camera = camera else{
            return
        }
        //すでにタッチの軌跡が描かれていれば削除
        if( touchPath != nil ){
            touchPath.removeFromParent()
        }
        //カメラの移動分平行移動する
        let moveX = camera.position.x - frame.size.width / 2
        let moveY = camera.position.y - frame.size.height / 2
        var points = [ CGPoint( x: begin.x + moveX, y: begin.y + moveY ),
                       CGPoint( x: end.x + moveX, y: end.y + moveY ) ]
        //線の作成
        touchPath = SKShapeNode(points: &points, count: points.count)
        //色の設定
        switch getTouchAction(begin: begin, end: end){
        case .tap:
            touchPath.strokeColor = UIColor.red
        case .swipeUp:
            touchPath.strokeColor = UIColor.green
        case .swipeDown:
            touchPath.strokeColor = UIColor.blue
        case .swipeLeft:
            touchPath.strokeColor = UIColor.yellow
        case .swipeRight:
            touchPath.strokeColor = UIColor.yellow
        }
        //線の描画
        baseNode.addChild(touchPath)
    }
    
    
    //MARK: - 関数定義　接触判定
    func didBegin(_ contact: SKPhysicsContact) {
        //print("---didBeginで衝突しました---")
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        _ = nodeA?.name
        _ = nodeB?.name
        let bitA = contact.bodyA.categoryBitMask
        let bitB = contact.bodyB.categoryBitMask
        
        if (bitA == 0b10000 || bitB == 0b10000) && (bitA == 0b1000 || bitB == 0b1000)
        {
            //print("---MeteorとattackShapeが接触しました---")
            attackMeteor()
        }
        else if (bitA == 0b100000 || bitB == 0b100000) && (bitA == 0b1000 || bitB == 0b1000)
        {
            //print("---MeteorとguardShapeが接触しました---")
            guardMeteor()
        }
        else if (bitA == 0b0010 || bitB == 0b0010) && (bitA == 0b1000 || bitB == 0b1000)
        {
            //print("---MeteorとGameOverが接触しました---")
            if( player.ultraAttackStatus == .none ){ //必殺技中はゲームオーバーにしない
                gameOver()
            }
        }
        else if (bitA == 0b0100 || bitB == 0b0100) && (bitA == 0b0001 || bitB == 0b0001)
        {
            //print("---Playerと地面が接触しました---")
            self.player.landing()
            if( gameWaitFlag == true ){
                gameStart()
            }
            switch ( player.ultraAttackStatus )
            {
            case .landing:
                player.ultraAttackStatus = .attacking
                player.position.y = player.defaultYPosition
                ultraAttackJump()
                break
            case .attacking:
                ultraAttackEnd()
                break
            case .none:
                //何もしない
                break
            }
            if self.player.attackFlg == false{
                self.player.stand()
            }
        }
        else if (bitA == 0b0100 || bitB == 0b0100) && (bitA == 0b1000 || bitB == 0b1000)
        {
            //print("---Playerとmeteorが接触しました---")
            if player.ultraAttackStatus == .none {
                self.player.collisionMeteor()
            }
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        //print("------------didEndで衝突しました------------")
        //print("bodyA:\(contact.bodyA)")
        //print("bodyB:\(contact.bodyB)")
        return
    }
    
    //MARK: - 関数定義　自分で設定関係
    
    //MARK: 配列
    let meteorBase = Meteor()

    func startButtonAction()
    {
        //MARK: ゲーム進行関係
        self.meteorTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.fallMeteor), userInfo: nil, repeats: true)                                          //タイマー生成
        playSound("button01")
        self.titleBgmPlayer.stop()
        self.mainBgmPlayer.play()
        if( retryFlg == false )
        {
            //リトライ時はアニメーションはしない
            let action2 = SKAction.run{
                let action1 = SKAction.moveTo(y: self.frame.size.height / 2, duration: 2)
                action1.timingMode = .easeInEaseOut
                let action2 = SKAction.run {
                    //self.titleNode.isHidden = true
                    if( self.player.actionStatus != .Standing ){
                        self.gameWaitFlag = true
                    }
                    else{
                        self.gameStart()
                    }
                }
                let actionAll = SKAction.sequence([action1,action2])
                self.camera?.run(actionAll)
            }
            self.titleNode.run(action2)
            self.creditButton.isHidden = true
        }
        else{
            self.titleNode.isHidden = true
            self.creditButton.isHidden = true
            gameStart()
        }
        pauseButton.isHidden = false //ポーズボタンを表示する
        gaugeview.isHidden = false
        creditBackButton.isHidden = true
    }
    
    func gameStart(){
        gameWaitFlag = false
        gameFlg = true
        //pod回復スタート
        guardPod.startRecover()
        gaugeview.run( SKAction.moveTo(y: -frame.size.height / 2 + gaugeview.size.height / 2, duration: 0.5))
    }
    
    func creditAction(){
        let credits = Credits(frame: self.frame)
        credits.name = "credits"
        credits.position.x = self.frame.size.width / 2
        //credits.position.y -= ( credits.height - self.frame.height )
        credits.position.y -= self.frame.height
        self.addChild(credits)
        self.creditFlg = true
        let action1 = SKAction.fadeOut(withDuration: 1.0)
        let action2 = SKAction.run{
            let moveCredit = SKAction.moveTo(y: credits.height - self.frame.size.height, duration: 10)
            let cameraAct = SKAction.run {
                let action1 = SKAction.moveTo(y: self.frame.size.height / 2, duration: 5)
                let action2 = SKAction.run {
                    self.titleNode.isHidden = true
                }
                let actionAll = SKAction.sequence([action1,action2])
                self.camera?.run(actionAll)
            }
            self.childNode(withName: "credits")?.run(SKAction.sequence([moveCredit,cameraAct]))
        }
        self.titleNode.run(SKAction.sequence([action1,action2]))
        self.creditButton.run(SKAction.sequence([action1,SKAction.hide()]))
    }
    
    @objc func fallMeteor()
    {
        guard gameFlg == true else { return }

        meteorBase.buildMeteor(position: CGPoint(x:187, y: self.player.position.y + 760))

    }
    
    //MARK: 攻撃    
    func attackMeteor()
    {
        guard gameoverFlg != true else{ return }
        guard self.player.attackFlg == true else{ return }
        
            //print("---隕石を攻撃---")
            if meteorBase.meteores.isEmpty == false
            {
                if player.ultraAttackStatus == .none //必殺技のときは続けて攻撃するため
                {
                    if let attackNode = player.childNode(withName: player.attackShape.name!)
                    {
                        attackNode.removeAllActions()
                        attackNode.removeFromParent()
                    }
                    self.player.attackFlg = false
                    //print("---アタックフラグをOFF---")
                }
                meteorBase.broken(attackPos: CGPoint(x: player.position.x,
                                                     y: player.position.y + (player.attackShape.position.y)))
                //スコア
                self.score += 1;
                self.hudView.drawScore( score: self.score )
                //コンボ
                self.combo += 1;
                let comboLabel = ComboLabel(self.combo)
                comboLabel.position.x = 100
                comboLabel.position.y = self.player.size.height/2
                self.player.addChild(comboLabel)
                //必殺技
                if( player.ultraAttackStatus == .none )
                {
                    self.player.ultraPower += 1
                    gaugeview.setMeteorGaugeScale(to: CGFloat(self.player.ultraPower) / 10.0 )
                }
                playSound("broken1")
                vibrate()
                //隕石と接触していたら速度を0にする
                if( self.player.meteorCollisionFlg )
                {
                    self.player.meteorCollisionFlg = false
                    player.velocity = 0;
                }
            }
            if meteorBase.meteores.isEmpty == true
            {
                if player.ultraAttackStatus == .none //必殺技中は着地後に生成する
                {
                    self.meteorBase.buildFlg = true
                    //print("---meteorBase.meteoresが空だったのでビルドフラグON---")
                }
            }
        
    }
    
    //必殺技
    func ultraAttack(){
        //print("!!!!!!!!!!ultraAttack!!!!!!!!!")
        self.player.ultraPower = 0
        gaugeview.setMeteorGaugeScale(to: 0)
        //入力を受け付けないようにフラグを立てる
        player.ultraAttackStatus = .landing
        if( player.actionStatus != .Standing ) //空中にいる場合
        {
            //地面に戻る
            player.velocity = -2000
        }
        else
        {
            player.ultraAttackStatus = .attacking
            //大ジャンプ
            ultraAttackJump()
        }
        //ultraAttackフラグは地面に着いた時に落とす
    }
    func ultraAttackJump(){
        //攻撃Shapeを出す
        self.player.attackFlg = true
        if let attackNode = player.childNode(withName: player.attackShape.name!) {
            attackNode.removeAllActions()
            attackNode.removeFromParent()
        }
        self.player.addChild(player.attackShape)
        //print("add ultra attackShape")
        //大ジャンプ
        player.moving = false
        player.actionStatus = .Jumping
        player.velocity = self.player.ultraAttackSpped
        //サウンド
        playSound("jump10")
    }
    func ultraAttackEnd(){
        self.player.attackFlg = false
        //attackShapeを消す
        if let attackNode = player.childNode(withName: player.attackShape.name!)
        {
            attackNode.removeFromParent()
            //print("remove ultra attackShape")
        }
        //フラグを落とす
        player.ultraAttackStatus = .none
        if( meteorBase.meteores.isEmpty ){ //全て壊せているはずだが一応チェックする
            //次のmeteorBase.meteores生成
            self.meteorBase.buildFlg = true
        }
    }
    //MARK: 防御
    func guardAction(endFlg: Bool)
    {
        guard gameoverFlg != true else { return }
        
        switch ( self.guardPod.guardStatus ){
        case .enable:   //ガード開始
            self.guardPod.guardStatus = .guarding
            if player.childNode(withName: guardShape.name!) == nil {
                player.addChild( guardShape )
            }
            //アニメーション
            self.player.guardStart()
        case .guarding: //ガード中
            self.guardPod.subCount(0.4)
            break
        case .disable:  //ガード不可
            return
        }

        if( endFlg == true )
        {
            if let guardNode = player.childNode(withName: guardShape.name!) {
                guardNode.removeFromParent()
            }
            self.guardPod.guardStatus = .enable
            //アニメーション
            self.player.guardEnd()
        }
    }

    func guardMeteor()
    {
        guard gameoverFlg != true else { return }
        guard let guardNode = player.childNode(withName: guardShape.name!) else {
            //print("guardShapeなしガード")
            return
        }
        
        if (self.guardPod.guardStatus == .guarding)
        {
            playSound("bougyo01")
            meteorBase.guarded(guardPos: CGPoint(x: player.position.x,
                                       y: player.position.y + (guardShape.position.y)))
            guardPod.subCount()
            //ガードシェイプ削除
            guardNode.removeFromParent()
            self.player.guardEnd()
            if player.actionStatus != .Standing {
                self.player.velocity = self.speedFromMeteorAtGuard  //プレイヤーの速度が上がる
                if let meteor = self.meteorBase.meteores.first {
                    let meteorMinY = meteor.position.y - (meteor.size.height / 2)
                    let playerHalfSize = self.player.size.height / 2
                    self.player.position.y = meteorMinY - playerHalfSize - 1
                }
            }
            self.combo = 0
        }
        else
        {
            print("---guardShapeとmeteorが衝突したけどフラグOFFでした---")
            return
        }
    }
    func gameOver()
    {
        if( !gameoverFlg ){ //既にGameOverの場合はなにもしない
            self.gameoverFlg = true
            self.gameFlg = false
            self.meteorTimer?.invalidate()
            pauseButton.isHidden = true//ポーズボタンを非表示にする
            hudView.scoreLabel.isHidden = true
            hudView.highScoreLabel.isHidden = true
            //ハイスコア更新
            print("------------score:\(self.score) high:\(self.highScore)------------")
            if( self.score > self.highScore ){
                self.highScore = self.score
                self.highScoreLabel.text = String(self.highScore)
                print("------------hidh score!------------")
                UserDefaults.standard.set(self.highScore, forKey: self.keyHighScore) //データの保存
            }
            print("------------gameover------------")
            self.mainBgmPlayer.stop()
            //墜落演出
            let circle = SKShapeNode(circleOfRadius:1)
            circle.position.x = self.meteorBase.meteores[0].position.x
            circle.position.y = self.meteorBase.meteores[0].position.y - self.meteorBase.meteores[0].size.height / 2
            circle.setzPos(.GameOverCircle)
            circle.fillColor = UIColor.white
            self.addChild(circle)
            let actions = SKAction.sequence(
                [   SKAction.run{self.playSound("explore16")},
                    SKAction.scale(to: 2000, duration: 2.5),
                  //SKAction.wait(forDuration: 0.5),
                  SKAction.group(
                    [ SKAction.wait(forDuration: 0.2),
                      SKAction.run{
                        self.player.isHidden = true
                        self.meteorBase.isHidden = true
                        },
                      ]),
                  SKAction.run {
                    self.gameOverView = GameOverView(frame: self.frame, score: self.score, highScore: self.highScore )
                    self.camera?.addChild(self.gameOverView)
                    },
                  //SKAction.run{self.isPaused = true},
                  SKAction.run{self.gameOverView.isHidden = false},

                ])
            circle.run(actions)
        }
    }

    func newGame()
    {
        var gameScene: GameScene!
        if (UIDevice.current.model.range(of: "iPad") != nil) {
            gameScene = GameScene(size: CGSize(width: 375.0, height: 667.0))
            gameScene.scaleMode = .fill
        }
        else{
            gameScene = GameScene(size: frame.size)
            gameScene.scaleMode = .aspectFill
        }
        self.view?.presentScene(gameScene)
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
        var gameScene: GameScene!
        if (UIDevice.current.model.range(of: "iPad") != nil) {
            gameScene = GameScene(size: CGSize(width: 375.0, height: 667.0))
            gameScene.scaleMode = .fill
        }
        else{
            gameScene = GameScene(size: frame.size)
            gameScene.scaleMode = .aspectFill
        }
        gameScene.retryFlg = true
        let actions = SKAction.sequence([
            SKAction.run { self.playSound("push_45") },
            SKAction.run { self.gameOverView.audioPlayer.stop() },
            SKAction.run { adBanner.isHidden = true },
            SKAction.run { self.view!.presentScene(gameScene)}
            ])
        run(actions)
    }
    
    func playBgm(soundName: String)
    {
        let action = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        let actionLoop = SKAction.repeatForever(action)
        self.run(actionLoop, withKey: "actionLoop")
    }
    
    func TitleStop()
    {
        titleBgmPlayer.stop()
        titleBgmPlayer.currentTime = 0
    }
    
    func MainStop()
    {
        mainBgmPlayer.stop()
        mainBgmPlayer.currentTime = 0
    }
    
    
    func vibrate() {
        //AudioServicesPlaySystemSound(1519)
        //AudioServicesDisposeSystemSoundID(1519)
    }

    //MARK:デバッグ用
    //SKShapeNodeのサイズの四角を追加する
    func addBodyFrame(node: SKSpriteNode){
        let frameRect = SKShapeNode(rect: CGRect(x: -node.size.width / 2,
                                                 y: -node.size.height / 2,
                                                 width: node.size.width,
                                                 height: node.size.height))
        frameRect.fillColor = UIColor.clear
        frameRect.lineWidth = 2.0
        frameRect.xScale = 1 / node.xScale  //縮小されている場合はその分拡大する
        frameRect.yScale = 1 / node.yScale  //縮小されている場合はその分拡大する
        frameRect.zPosition = 1500          //とにかく手前
        frameRect.name = "frame"
        node.addChild( frameRect )
    }
    //デバッグ表示用view
    var debugView = UIView()
    let playerPosLabel = UILabel()                                  //プレイヤーの座標表示用ラベル
    let paramNames = ["ジャンプ速度",
                      "ガード時のプレイヤー速度"]
    var params = [UnsafeMutablePointer<CGFloat>]()
    let paramMin:[Float] = [0,       //pleyer.jumpVeloctiy
                            0]       //speedFromMeteorOnGuard
    let paramMax:[Float] = [2000,    //pleyer.jumpVeloctiy
                            1000]    //speedFromMeteorOnGuard
    let paramTrans = [ {(a: Float) -> CGFloat in return CGFloat(Int(a)) },
                       {(a: Float) -> CGFloat in return CGFloat(Int(a)) }
    ]
    let paramInv = [  {(a: CGFloat) -> Float in return Float(a) },
                     {(a: CGFloat) -> Float in return Float(a) }
    ]
    //調整用スライダー
    var paramSliders = [UISlider]()
    var paramLabals = [SKLabelNode]()
    var collisionLine : SKShapeNode!

    //削除
    func removeParamSlider(){
        debugView.removeFromSuperview()
    }
    var sliderHidden: Bool = true
    @objc func sliderSwitchHidden( ){
        sliderHidden = !sliderHidden
        debugView.isHidden = sliderHidden
    }
    @objc func setDefaultParam(){
        //調整用パラメータ
        player.jumpVelocity = 1500                       //プレイヤーのジャンプ時の初速
        speedFromMeteorAtGuard = -500                //隕石を防御した時にプレイヤーの速度
        var ix = 0
        for slider in paramSliders {
            slider.setValue( paramInv[ix](params[ix].pointee), animated: true)  // デフォルト値の設定
            let label = slider.subviews.last as! UILabel
            label.text = paramNames[ix] + ": " + String( describing: params[ix].pointee )
            label.sizeToFit()
            ix += 1
        }
    }
    // スライダーの値が変更された時の処理
    @objc func sliderOnChange(_ sender: UISlider) {
        //変更されたスライダーの配列のindex
        let index = paramSliders.index(of: sender)
        //
        params[index!].pointee = paramTrans[index!](sender.value)
        print("###set \(paramNames[index!]): \(sender.value) -> \(params[index!].pointee)")
        let label = sender.subviews.last as! UILabel
        label.text = paramNames[index!] + ": " + String( describing: params[index!].pointee )
        label.sizeToFit()
    }
}
