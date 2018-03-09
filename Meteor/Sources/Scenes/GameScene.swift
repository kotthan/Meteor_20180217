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
    var attackShape: SKShapeNode!                                   //攻撃判定シェイプノード
    var attackShapeName: String = "attackShape"
    var guardShape: SKShapeNode!                                    //防御判定シェイプノード
    var guardShapeName: String = "guardShape"
    var creditButton = SKLabelNode()
    var creditBackButton = SKLabelNode()
    var score = 0                                                   //スコア
    var combo = 0                                                   //スコア
    let highScoreLabel = SKLabelNode()                              //ハイスコア表示ラベル
    var highScore = 0                                               //ハイスコア
    var pauseButton: PauseButton!                                   //ポーズボタン
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
    var attackFlg : Bool = false                                    //攻撃フラグ
    var gameFlg:Bool = false
    var gameWaitFlag = false                                        //スタート時にplayerが空中の場合に待つためのフラグ
    var creditFlg = false
    var retryFlg = false                                            //リトライするときにそのままゲームスタートさせる
    
    //MARK: - プロパティ
	//MARK: プレイヤーキャラプロパティ
    //MARK: 隕石・プレイヤー動作プロパティ

    //調整用パラメータ
    var gravity : CGFloat = -900                                    //重力 9.8 [m/s^2] * 150 [pixels/m]
    var meteorPos :CGFloat = 1320.0                                 //隕石の初期位置(1500.0)

    var meteorSpeedAtGuard: CGFloat = 100                           //隕石が防御された時の速度
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
        //攻撃判定用シェイプ
        attackShapeMake()
        //ガード判定用シェイプ
        guardShapeMake()
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
        self.creditButton.fontSize = 30
        self.creditButton.text = "Credits"
        self.creditButton.position.x = self.frame.size.width / 2
        self.creditButton.position.y += 720 //適当
        self.creditButton.zPosition = 50
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
        self.creditBackButton.zPosition = 50
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
        guardPod.zPosition = -1
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
        self.highScoreLabel.zPosition = -1                  //プレイヤーの後ろ
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
        pauseView = PauseView(frame: self.frame)
        pauseView.isHidden = true
        self.camera?.addChild(pauseView)
        //　ポーズボタン
        pauseButton = PauseButton()
        pauseButton.layer.anchorPoint = CGPoint(x: 1, y: 0)//右上
        pauseButton.layer.position = CGPoint(x: frame.maxX - 10, y: 25)
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
        self.view!.addSubview(pauseButton)
        
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
        if ( !meteorBase.meteores.isEmpty )
        {
            self.meteorBase.meteorSpeed += self.gravity * meteorBase.meteorGravityCoefficient / 60
            for m in meteorBase.meteores
            {
                m.position.y += self.meteorBase.meteorSpeed / 60
            }
        }
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
        /*guard ( gameoverFlg == false ) else {  //ゲームオーバでなければ次の処理に進む
            return
        }*/
        //ポーズでなければ次の処理に進む
        /*guard ( self.view!.scene?.isPaused == false ) else {
            return
        }*/
        
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
        /*guard ( gameoverFlg == false ) else {  //ゲームオーバでなければ次の処理に進む
            
           // return
        }*/
        //ポーズでなければ次の処理に進む
        /*guard ( self.view!.scene?.isPaused == false ) else {
            return
        }*/
        
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
                case let node where node == titleNode?.TitleMeteorNode :
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
                case let node where node == titleNode?.TitleNode :
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
                attackAction()
            case .swipeDown:
                if gameFlg == true{
                    guardAction(endFlg: true)
                }
            case .swipeUp where player.actionStatus == .Standing: //ジャンプしてない場合のみ
                self.player.jump()
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
            if attackFlg == false{
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
        playSound(soundName: "button01")
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
            let action_1 = SKAction.fadeOut(withDuration: 1.0)
            self.creditButton.run(SKAction.sequence([action_1,SKAction.removeFromParent()]))
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
    func attackShapeMake()
    {
        let attackShape = SKShapeNode(rect: CGRect(x: 0.0 - self.player.size.width/2, y: 0.0 - self.player.size.height/2, width: self.player.size.width, height: self.player.size.height))
        attackShape.name = attackShapeName
        let physicsBody = SKPhysicsBody(rectangleOf: attackShape.frame.size)
        attackShape.position = CGPoint(x: 0, y: self.player.size.height)
        attackShape.fillColor = UIColor.clear
        attackShape.strokeColor = UIColor.clear
        attackShape.zPosition = 1
        attackShape.physicsBody = physicsBody
        attackShape.physicsBody?.affectedByGravity = false      //重力判定を無視
        attackShape.physicsBody?.isDynamic = false              //固定物に設定
        attackShape.physicsBody?.categoryBitMask = 0b10000      //接触判定用マスク設定
        attackShape.physicsBody?.collisionBitMask = 0b0000      //接触対象をなしに設定
        attackShape.physicsBody?.contactTestBitMask = 0b1000    //接触対象をmeteorに設定
        //print("---attackShapeを生成しました---")
        self.attackShape = attackShape
    }
    
    func attackAction()
    {
        if gameoverFlg == true
        {
            return
        }
        if attackFlg == false
        {
            //print("---アタックフラグをON---")
            self.attackFlg = true
            self.player.attack()
            playSound(soundName: "attack03")
            if player.childNode(withName: attackShapeName) == nil {
                self.player.addChild(attackShape)
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
        }
    }
    
    func attackMeteor()
    {
        guard gameoverFlg != true else{ return }
        guard attackFlg == true else{ return }
        
            //print("---隕石を攻撃---")
            if meteorBase.meteores.isEmpty == false
            {
                if player.ultraAttackStatus == .none //必殺技のときは続けて攻撃するため
                {
                    if let attackNode = player.childNode(withName: attackShapeName)
                    {
                        attackNode.removeAllActions()
                        attackNode.removeFromParent()
                    }
                    attackFlg = false
                    //print("---アタックフラグをOFF---")
                }
                meteorBase.meteores[0].physicsBody?.categoryBitMask = 0
                meteorBase.meteores[0].physicsBody?.contactTestBitMask = 0
                meteorBase.meteores[0].removeFromParent()
                //隕石を爆発させる
                let particle = SKEmitterNode(fileNamed: "MeteorBroken.sks")
                //接触座標にパーティクルを放出するようにする。
                particle!.position = CGPoint(x: player.position.x,
                                             y: player.position.y + (attackShape.position.y))
                //0.7秒後にシーンから消すアクションを作成する。
                let action1 = SKAction.wait(forDuration: 0.5)
                let action2 = SKAction.removeFromParent()
                let actionAll = SKAction.sequence([action1, action2])
                //パーティクルをシーンに追加する。
                self.addChild(particle!)
                //アクションを実行する。
                particle!.run(actionAll)
                //print("---消すノードは\(meteorBase.meteores[0])です---")
                meteorBase.meteores.remove(at: 0)
                //self.meteorGravityCoefficient -= 0.06                   //数が減るごとに隕石の速度を遅くする
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
                playSound(soundName: "broken1")
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
        self.attackFlg = true
        if let attackNode = player.childNode(withName: attackShapeName) {
            attackNode.removeAllActions()
            attackNode.removeFromParent()
        }
        self.player.addChild(attackShape)
        //print("add ultra attackShape")
        //大ジャンプ
        player.moving = false
        player.actionStatus = .Jumping
        player.velocity = self.player.ultraAttackSpped
        //サウンド
        playSound(soundName: "jump10")
    }
    func ultraAttackEnd(){
        self.attackFlg = false
        //attackShapeを消す
        if let attackNode = player.childNode(withName: attackShapeName)
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
    func guardShapeMake()
    {
        let guardShape = SKShapeNode(rect: CGRect(x: 0.0 - self.player.size.width/2, y: 0.0 - self.player.size.height/2, width: self.player.size.width, height: self.player.size.height + 10))
        guardShape.name = guardShapeName
        let physicsBody = SKPhysicsBody(rectangleOf: guardShape.frame.size)
        guardShape.position = CGPoint(x: 0, y: 0)
        guardShape.fillColor = UIColor.clear
        guardShape.strokeColor = UIColor.clear
        guardShape.zPosition = 1
        guardShape.physicsBody = physicsBody
        guardShape.physicsBody?.affectedByGravity = false      //重力判定を無視
        guardShape.physicsBody?.isDynamic = false              //固定物に設定
        guardShape.physicsBody?.categoryBitMask = 0b100000     //接触判定用マスク設定
        guardShape.physicsBody?.collisionBitMask = 0b0000      //接触対象をなしに設定
        guardShape.physicsBody?.contactTestBitMask = 0b1000    //接触対象をmeteorに設定
        self.guardShape = guardShape
        //print("---guardShapeを生成しました---")
    }
    
    func guardAction(endFlg: Bool)
    {
        guard gameoverFlg != true else { return }
        
        switch ( self.guardPod.guardStatus ){
        case .enable:   //ガード開始
            self.guardPod.guardStatus = .guarding
            if player.childNode(withName: guardShapeName) == nil {
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
            if let guardNode = player.childNode(withName: guardShapeName) {
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
        guard let guardNode = player.childNode(withName: guardShapeName) else {
            //print("guardShapeなしガード")
            return
        }
        
        if (self.guardPod.guardStatus == .guarding)
        {
            playSound(soundName: "bougyo01")
            guardPod.subCount()
            //ガードシェイプ削除
            guardNode.removeFromParent()
            self.player.guardEnd()
            for i in meteorBase.meteores
            {
                i.removeAllActions()
                if player.actionStatus != .Standing {
                    self.player.velocity = self.speedFromMeteorAtGuard  //プレイヤーの速度が上がる
                    let meteor = self.meteorBase.meteores.first
                    let meteorMinY = (meteor?.position.y)! - ((meteor?.size.height)!/2)
                    let playerHalfSize = self.player.size.height / 2
                    self.player.position.y = meteorMinY - playerHalfSize - 1
                }
                self.meteorBase.meteorSpeed = self.meteorSpeedAtGuard       //上に持ちあげる
                self.combo = 0
            }
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
            circle.zPosition = 1500.0
            circle.fillColor = UIColor.white
            self.addChild(circle)
            let actions = SKAction.sequence(
                [   SKAction.run{self.playSound(soundName: "explore16")},
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
        let scene = GameScene(size: self.scene!.size)
        scene.scaleMode = SKSceneScaleMode.aspectFill
        self.view?.presentScene(scene)
    }
    
    func homeButtonAction()
    {
        let actions = SKAction.sequence([
            SKAction.run { self.playSound(soundName: "push_45") },
            SKAction.run { self.gameOverView.audioPlayer.stop() },
            SKAction.run { adBanner.isHidden = true },
            SKAction.run { self.newGame() }
            ])
        run(actions)
    }
    func reStartButtonAction()
    {
        let scene = GameScene(size: self.scene!.size)
        scene.scaleMode = SKSceneScaleMode.aspectFill
        scene.retryFlg = true
        let actions = SKAction.sequence([
            SKAction.run { self.playSound(soundName: "push_45") },
            SKAction.run { self.gameOverView.audioPlayer.stop() },
            SKAction.run { adBanner.isHidden = true },
            SKAction.run { self.view!.presentScene(scene)}
            ])
        run(actions)
    }
    //MARK: 音楽
    func playSound(soundName: String)
    {
        let mAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        self.run(mAction)
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
    let paramNames = ["重力",
                      "隕石の発生位置",
                      "隕石の重力受ける率",
                      "ジャンプ速度",
                      "プレイヤーの重力受ける率",
                      "ガード時の隕石速度",
                      "ガード時のプレイヤー速度"]
    var params = [UnsafeMutablePointer<CGFloat>]()
    let paramMin:[Float] = [0,       //gravity
                            0,       //meteorPos
                            0,       //pleyer.jumpVeloctiy
                            0,       //meteorSpeedAtGuard
                            0]       //speedFromMeteorOnGuard
    let paramMax:[Float] = [1000,    //gravity
                            5000,    //meteorPos
                            2000,    //pleyer.jumpVeloctiy
                            1000,    //meteorSpeedAtGuard
                            1000]    //speedFromMeteorOnGuard
    let paramTrans = [ {(a: Float) -> CGFloat in return -CGFloat(Int(a)) },
                       {(a: Float) -> CGFloat in return CGFloat(Int(a)) },
                       {(a: Float) -> CGFloat in return CGFloat(Int(a)) },
                       {(a: Float) -> CGFloat in return CGFloat(Int(a)) },
                       {(a: Float) -> CGFloat in return CGFloat(Int(a)) }
    ]
    let paramInv = [ {(a: CGFloat) -> Float in return -Float(a) },
                     {(a: CGFloat) -> Float in return Float(a) },
                     {(a: CGFloat) -> Float in return Float(a) },
                     {(a: CGFloat) -> Float in return Float(a) },
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
        gravity = -900                               //重力 9.8 [m/s^2] * 150 [pixels/m]
        meteorPos = 2400                             //隕石の初期位置
        player.jumpVelocity = 1500                       //プレイヤーのジャンプ時の初速
        meteorSpeedAtGuard = 100                     //隕石が防御された時の速度
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
