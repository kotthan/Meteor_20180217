//
//  GameViewController.swift
//

import UIKit
import SpriteKit
import GoogleMobileAds

@available(iOS 9.0, *)
var adBanner: GADBannerView!
class GameViewController: UIViewController, GADBannerViewDelegate {

	var gameView: GameView!     //SKView
    var gameScene: GameScene!   //SKScene, SKPhysicsContactDelegate
    override func viewDidLoad() {
		super.viewDidLoad()
        let frame = UIScreen.main.bounds
		//===================
		//Game View作成
		//===================
		self.gameView = GameView(frame: CGRect(x: 0,y: 0,width: frame.size.width,height: frame.size.height))
		self.gameView.allowsTransparency = true
		self.gameView.ignoresSiblingOrder = true
		self.view.addSubview(self.gameView)
		self.view.sendSubview(toBack: self.gameView)
        print("GameViewがコントローラに追加されたよ")
		//デバッグ表示
//		self.gameView.showsFPS = true
//		self.gameView.showsNodeCount = true
//		self.gameView.showsPhysics = true
		//===================
		// Game Scene作成
		//===================
        self.gameScene = GameScene(size: frame.size)
        // ゲームシーンを表示
		self.gameView.presentScene(self.gameScene)
        print("GameSceneがコントローラで呼ばれたよ")
        print("画面サイズ＝\(frame)")
        //広告の表示
        self.showAd()
    }

	override func viewDidAppear(_ animated: Bool)
    {}
    
    override var prefersStatusBarHidden: Bool{
        return true
    }

    func showAd() {
        // Define custom GADAdSize of 250x250 for DFPBannerView.
        //let customAdSize = GADAdSizeFromCGSize(CGSize(width: 300, height: 300))
        //adBanner = GADBannerView(adSize: customAdSize)
        adBanner = GADBannerView(adSize: kGADAdSizeMediumRectangle)//300×250
        if (UIDevice.current.model.range(of: "iPad") != nil) {
            //でかいので小さくしておく
            adBanner.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
        //配置設定
        let frame = UIScreen.main.bounds
        adBanner.frame.origin.x = frame.size.width / 2 - adBanner.frame.size.width / 2
        adBanner.frame.origin.y = frame.size.height - adBanner.frame.size.height - 20
        adBanner.adUnitID = "ca-app-pub-2945918043757109/9447056281"
        adBanner.delegate = self
        adBanner.rootViewController = self
        
        let gadRequest:GADRequest = GADRequest()
        // テスト用の広告を表示する時のみ使用（申請時に削除）
        gadRequest.testDevices = ["12345678abcdefgh"]
        adBanner.load(gadRequest)
        adBanner.isHidden = true
        self.view.addSubview(adBanner)
    }
}
