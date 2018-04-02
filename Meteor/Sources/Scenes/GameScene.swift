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
    var baseNode: SKNode
    var backgroundView: BackgroundView!
    var player: Player
    let normalCamera = SKCameraNode()
    var gameCamera: GameCamera!
    var ground: Ground!
    var lowestShape: LowestShape!
    var guardPod: GuardPod!
    var titleNode: TitleNode!
    var gaugeview: GaugeView!
    var pauseButton: PauseButton!
    var guardShape: GuardShape!                                    //防御判定シェイプノード
    var creditButton = SKLabelNode()
    var creditBackButton = SKLabelNode()
    var score = 0 {                                                 //スコア
        didSet {
            if score > 99999 {
                score = 99999
            }
            //更新時に表示も更新する
            self.hudView.drawScore( score: self.score )
        }
    }
    var combo = 0 {                                                 //コンボ
        didSet{
            guard combo != 0 else { return }
            //0以外が設定されていたら表示も更新する
            let comboLabel = ComboLabel(self.combo)
            comboLabel.position.x = 100
            comboLabel.position.y = self.player.size.height/2
            self.player.addChild(comboLabel)
        }
    }
    let highScoreLabel = SKLabelNode()                              //ハイスコア表示ラベル
    var highScore = 0                                               //ハイスコア
    //MARK: 画面
    var pauseView: PauseView!                                       //ポーズ画面
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
    }
    var sceneState:SceneState = .Title
    var gameFlg:Bool = false
    var gameWaitFlag = false
    //スタート時にplayerが空中の場合に待つためのフラグ
    var creditFlg = false
    var retryFlg = false                                            //リトライするときにそのままゲームスタートさせる

    //調整用パラメータ

    var speedFromMeteorAtGuard : CGFloat = -500  //隕石を防御した時にプレイヤーが受ける隕石の速度
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
    
    //MARK: データ保存
    var keyHighScore = "highScore"
    
    init(from: GameScene) {
        self.baseNode = from.baseNode
        self.player = from.player
        self.backgroundView = from.backgroundView
        self.ground = from.ground
        super.init(size: from.frame.size)
        self.scaleMode = from.scaleMode
    }
    
    override init(size: CGSize) {
        self.baseNode = SKNode()
        self.player = Player()
        //端末ごとのスケール調整
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        //MARK: カメラ
        normalCamera.position = CGPoint(x: self.frame.size.width/2,y: 1005)
        self.addChild(normalCamera)
        self.camera = normalCamera
        self.gameCamera = GameCamera(player: self.player, defaultY: frame.size.height / 2)
        //背景
        if self.backgroundView == nil {
            self.backgroundView = BackgroundView(frame: self.frame)
        }
        self.baseNode.addChild(backgroundView)
        //地面
        if self.ground == nil {
            self.ground = Ground(frame: self.frame)
        }
        self.baseNode.addChild(ground)
        self.player.ground = self.ground
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
        gaugeview.setMeteorGaugeScale(ultraPower: CGFloat(self.player.ultraPower) )
        gaugeview.position.y -= gaugeview.size.height
        self.gameCamera.addChild(gaugeview)
        gaugeview.isHidden = true
        self.player.gaugeview = gaugeview
        
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
        guardPod = GuardPod()
        guardPod.gaugeView = gaugeview
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
        self.gameCamera.addChild(pauseView)
        //pauseButton
        pauseButton = PauseButton(frame:self.frame)
        pauseButton.setPauseFunc{
            self.pauseView.isHidden = false
            self.view!.scene?.isPaused = true
            self.mainBgmPlayer.pause()
        }
        pauseButton.setResumeFunc{
            self.pauseView.isHidden = true
            self.view!.scene?.isPaused = false
            self.mainBgmPlayer.play()
        }
        pauseButton.isHidden = true     //タイトル画面では非表示
        self.gameCamera.addChild(pauseButton)
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
        if( retryFlg )
        { //リトライ時はそのままスタートする
            startButtonAction()
        }
        //view.showsPhysics = true
	}
    
    //アプリがバックグラウンドから復帰した際に呼ばれる関数
    //起動時にも呼ばれる
    @objc func becomeActive(_ notification: Notification) {
        guard gameFlg == true else{ return } // ゲーム中でなければなにもせず抜ける
        guard creditFlg == false else { return }//クレジット中もポーズにしない
        isPaused = true     //ポーズ状態にする
        if( pauseButton.isPushed == false ){ //ポーズボタンが押されていなかった
            pauseButton.pauseAction()
        }
    }
    
    //MARK: シーンのアップデート時に呼ばれる関数
    override func update(_ currentTime: TimeInterval)
    {
        self.meteorBase.update()
        self.player.update(meteor: self.meteorBase.meteores.first, meteorSpeed: self.meteorBase.meteorSpeed)
        
        self.gameCamera.update()
        if ( self.creditFlg == true ) && ( self.player.ultraAttackStatus == .attacking ) && ( self.player.velocity < 0 ){
            self.titleNode.isHidden = false
            self.titleNode.alpha = 1.0
            self.childNode(withName: "credits")?.removeFromParent()
            self.creditButton.isHidden = false
            self.creditButton.alpha = 1.0
            if( self.gameCamera.position.y < titleNode.TitleNode?.position.y ){
                self.gameCamera.position = CGPoint(x: self.frame.size.width/2,y: (titleNode.TitleNode?.position.y)!)
                //カメラ入れ替え
                self.setCamera(self.normalCamera)
                self.gameFlg = false
                self.creditFlg = false
            }
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
            self.beganPyPos = (self.camera?.position.y)!                     //カメラの移動量を計算するために覚えておく
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
            case .swipeUp:
                self.player.squat()//しゃがみ
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
                    self.player.ultraAttack()
                case let node where node == creditButton.childNode(withName: "credit"):
                    creditAction()
                case let node where node?.name == "BackTitle":
                    gameFlg = true
                    self.setCamera(self.gameCamera)
                    self.player.ultraAttack()
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
                if gameFlg == false && creditFlg == false {
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
                    self.player.attack()
                }
            case .swipeDown:
                if gameFlg == true{
                    guardAction(endFlg: true)
                }
            case .swipeUp where player.actionStatus == .Standing: //ジャンプしてない場合のみ
                self.player.jump()
                self.ground.jumpSprite(pos: player.position)
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
            if self.player.ultraAttackStatus == .attacking {
                if( meteorBase.meteores.isEmpty ){ //全て壊せているはずだが一応チェックする
                    if score >= 99999 {
                        gameClear()
                    }
                    else{
                        //次のmeteorBase.meteores生成
                        self.meteorBase.buildFlg = true
                    }
                }
            }
            self.player.landing()
            if( gameWaitFlag == true ){
                gameStart()
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
        //カメラ入れ替え
        self.setCamera(self.gameCamera)
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
                self.normalCamera.run(actionAll)
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
        guard self.player.attackFlg == true else{ return }
        
        //print("---隕石を攻撃---")
        if meteorBase.meteores.isEmpty == false
        {
            //コンボ
            self.combo += 1
            let comboBonus:Float = 1 + (Float(self.combo) / 10)
            //スコア
            self.score += Int(Float( 1 + self.meteorBase.meteores.count ) * comboBonus )
            self.player.attackMeteor()
            meteorBase.broken(attackPos: CGPoint(x: player.position.x, y: player.position.y + (player.attackShape.position.y)))
        }
        if meteorBase.meteores.isEmpty == true
        {
            if player.ultraAttackStatus == .none //必殺技中は着地後に生成する
            {
                if score >= 99999 {
                    gameClear()
                }
                else{
                    self.meteorBase.buildFlg = true
                    //print("---meteorBase.meteoresが空だったのでビルドフラグON---")
                }
            }
        }
        
    }
    
    //MARK: 防御
    func guardAction(endFlg: Bool)
    {
        
        switch ( self.guardPod.guardStatus ){
        case .enable:   //ガード開始
            self.guardPod.guardStatus = .guarding
            if player.childNode(withName: guardShape.name!) == nil {
                player.addChild( guardShape )
            }
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
            self.player.guardEnd()
        }
    }

    func guardMeteor()
    {
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
        guard gameFlg == true else { return }
        self.gameFlg = false
        self.meteorTimer?.invalidate()
        pauseButton.isHidden = true//ポーズボタンを非表示にする
        hudView.scoreLabel.isHidden = true
        hudView.highScoreLabel.isHidden = true
        MainStop()
        //墜落演出
        let circle = SKShapeNode(circleOfRadius:1)
        circle.position.x = self.meteorBase.meteores[0].position.x
        circle.position.y = self.meteorBase.meteores[0].position.y - self.meteorBase.meteores[0].size.height / 2
        circle.setzPos(.GameOverCircle)
        circle.fillColor = UIColor.white
        self.addChild(circle)
        let actions = SKAction.sequence(
            [   SKAction.run{self.playSound("explore16")},
                SKAction.scale(to: 2000, duration: 1.5),
              //SKAction.wait(forDuration: 0.5),
              SKAction.group(
                [ SKAction.wait(forDuration: 0.1),
                  SKAction.run{
                    self.player.isHidden = true
                    self.meteorBase.isHidden = true
                    },
                  ]),
              SKAction.run {
                let gameOverScene = GameOverScene(size: self.frame.size)
                gameOverScene.setScore(score: self.score, highScore: self.highScore)
                self.view?.presentScene(gameOverScene)
                },
              //SKAction.run{self.isPaused = true},
            ])
        circle.run(actions)
    }
    
    func gameClear(){
        //UIviewはScene移動しても残るので削除する
        self.hudView.removeFromSuperview()
        let clearScene = GameClearScene(from: self)
        self.view!.presentScene( clearScene )
    }
    
    func setCamera(_ camera :SKCameraNode){
        if let oldCamera = self.camera {
            oldCamera.removeFromParent()
            camera.position = oldCamera.position
        }
        self.addChild(camera)
        self.camera = camera
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
}
