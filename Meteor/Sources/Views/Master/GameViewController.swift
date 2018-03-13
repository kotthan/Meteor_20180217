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
	
	class func gameViewController() -> GameViewController {
		let gameView = GameViewController(nibName: "GameViewController", bundle: nil)
		let frame = UIScreen.main.bounds
		gameView.view.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
		return gameView
	}
	
    override func viewDidLoad() {
		super.viewDidLoad()

		//===================
		//Game View作成
		//===================
		let frame = UIScreen.main.bounds
		self.gameView = GameView(frame: CGRect(x: 0,y: 0,width: frame.size.width,height: frame.size.height))
		self.gameView.allowsTransparency = true
		self.gameView.ignoresSiblingOrder = true
		self.view.addSubview(self.gameView)
		self.view.sendSubview(toBack: self.gameView)
		//デバッグ表示
//		self.gameView.showsFPS = true
//		self.gameView.showsNodeCount = true
//		self.gameView.showsPhysics = true
		
		//===================
		// Game Scene作成
		//===================
        /*
            if (UIDevice.current.model.range(of: "iPad") != nil){
                gameScene.scaleMode = .fill
            } else {
                self.gameScene = GameScene(size: CGSize(width: frame1.size.width,height: frame1.size.height))
                self.gameScene.scaleMode = .aspectFill
                //シーンをビューと同じサイズに調整する
                self.gameScene.size = CGSize(width: frame1.size.width, height: frame1.size.height)
                // ゲームシーンを表示
                self.gameView.presentScene(self.gameScene)
                print("画面サイズ＝\(frame)")
                print("画面サイズ１＝\(frame1)")
            }
                self.gameScene = GameScene(size: CGSize(width: frame1.size.width,height: frame1.size.height))
                self.gameScene.scaleMode = .aspectFill
                //シーンをビューと同じサイズに調整する
                self.gameScene.size = CGSize(width: frame1.size.width, height: frame1.size.height)
                // ゲームシーンを表示
                self.gameView.presentScene(self.gameScene)
                print("画面サイズ＝\(frame)")
                print("画面サイズ１＝\(frame1)")
*/
        self.gameScene = GameScene(size: CGSize(width: frame.size.width,height: frame.size.height))
		self.gameScene.scaleMode = .aspectFill
		//シーンをビューと同じサイズに調整する
		self.gameScene.size = CGSize(width: frame.size.width, height: frame.size.height)
		// ゲームシーンを表示
		self.gameView.presentScene(self.gameScene)
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
