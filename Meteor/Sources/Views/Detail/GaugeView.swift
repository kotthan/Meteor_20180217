//
//  GaugeView.swift
//  Meteor
//
//  Created by Kazuaki Oe on 2018/03/01.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//
import SpriteKit
import CoreImage

@available(iOS 9.0, *)
class GaugeView: SKSpriteNode {
    let meteorGaugeMask: SKShapeNode
    let guardGaugeMask: SKShapeNode
    let podGaugeMask: SKShapeNode
    let podIcon: SKSpriteNode
    let ultraAttackIcon: SKSpriteNode
    let ultraAttackMonoIcon: SKSpriteNode
    let ultraAttackPush: SKSpriteNode
    
    init(frame: CGRect) {
        //ゲージベース枠
        let base = SKSpriteNode(imageNamed: "gaugeBase")
        base.name = "base"
        //ゲージ背景追加
        let back = SKSpriteNode(imageNamed: "gaugeBack")
        back.name = "back"
        //透けてる部分のサイズ分しか背景がないので引き延ばす
        back.xScale = base.size.width / back.size.width
        back.yScale = base.size.height / back.size.height
        //メテオゲージSpriteNode
        let meteorGaugeSprite = SKSpriteNode(imageNamed: "meteorGauge")
        meteorGaugeSprite.xScale = 2.0
        meteorGaugeSprite.yScale = 2.0
        //メテオゲージ調整用マスク
        meteorGaugeMask = SKShapeNode(rect: CGRect(x: 0, y: 0,
                                                   width: meteorGaugeSprite.size.width,
                                                   height: meteorGaugeSprite.size.height))
        meteorGaugeMask.position.x = -meteorGaugeSprite.size.width / 2
        meteorGaugeMask.position.y = -meteorGaugeSprite.size.height / 2
        meteorGaugeMask.fillColor = UIColor.red
        //メテオゲージ
        let meteorGauge = SKCropNode()
        meteorGauge.maskNode = meteorGaugeMask
        meteorGaugeMask.xScale = 0
        meteorGauge.position.x = 60 //思考錯誤で決めたゲージの位置
        meteorGauge.addChild(meteorGaugeSprite)
        //ガードゲージSprite
        let guardGaugeSprite = SKSpriteNode(imageNamed: "guardGauge")
        guardGaugeSprite.xScale = 2.0
        guardGaugeSprite.yScale = 2.0
        //メテオゲージ調整用マスク
        guardGaugeMask = SKShapeNode(rect: CGRect(x: 0, y: 0,
                                                   width: guardGaugeSprite.size.width,
                                                   height: guardGaugeSprite.size.height))
        guardGaugeMask.position.x = -guardGaugeSprite.size.width / 2
        guardGaugeMask.position.y = -guardGaugeSprite.size.height / 2
        guardGaugeMask.fillColor = UIColor.green
        //ガードゲージ
        let guardGauge = SKCropNode()
        guardGauge.maskNode = guardGaugeMask
        guardGauge.addChild(guardGaugeSprite)
        //試行錯誤による位置調整
        guardGauge.position.x -= 22
        guardGauge.position.y += 41.5
        //Podアイコン
        podIcon = SKSpriteNode(imageNamed: "podIcon_red")
        podIcon.position.x -= 255
        podIcon.zRotation += 10 / 180 * CGFloat.pi
        //必殺技アイコン
        let texture = SKTexture(imageNamed: "ultraAttackIcon")
        ultraAttackIcon = SKSpriteNode(texture: texture)
        ultraAttackIcon.name = "ultraOKbutton"
        //普段の必殺技アイコン
        //モノクロのフィルタをかける
        let filter:CIFilter = CIFilter(name: "CIColorMonochrome")!
        filter.setValue(CIImage(image: #imageLiteral(resourceName: "ultraAttackIcon")), forKey: kCIInputImageKey)
        filter.setValue(CIColor(red: 0.75, green: 0.75, blue: 0.75), forKey: kCIInputColorKey)
        filter.setValue(1.0, forKey: kCIInputIntensityKey)
        let ciContext:CIContext = CIContext(options: nil)
        let cgimg = ciContext.createCGImage(filter.outputImage!, from:filter.outputImage!.extent)
        ultraAttackMonoIcon = SKSpriteNode(texture: SKTexture(image: UIImage(cgImage: cgimg!)))
        //フィルタをかけるとサイズがおかしくなるので
        ultraAttackMonoIcon.xScale = ultraAttackIcon.size.width / ultraAttackMonoIcon.size.width
        ultraAttackMonoIcon.yScale = ultraAttackIcon.size.height / ultraAttackMonoIcon.size.height
        ultraAttackMonoIcon.name = "ultrabutton"
        //podアイコンゲージSprite
        let podGaugeSprite = SKSpriteNode(imageNamed: "podGauge")
        podGaugeSprite.yScale = 2.75
        //podアイコンゲージ用マスク
        podGaugeMask = SKShapeNode(rect: CGRect(x: 0, y: 0,
                                                width: podGaugeSprite.size.width,
                                                height: podGaugeSprite.size.height ))
        podGaugeMask.position.x = -podGaugeSprite.size.width / 2
        podGaugeMask.position.y = -podGaugeSprite.size.height / 2
        podGaugeMask.fillColor = UIColor.green
        //podアイコンゲージ
        let podGauge = SKCropNode()
        podGauge.maskNode = podGaugeMask
        podGauge.addChild(podGaugeSprite)
        //podアイコン
        let podGlass = SKSpriteNode(imageNamed: "podGlass")
        podGlass.xScale = 0.95
        let podTop = SKSpriteNode(imageNamed: "podTop_green")
        podTop.position.y += (podGlass.size.height / 2 + 17)
        let podBottom = SKSpriteNode(imageNamed: "podBottom")
        podBottom.position.y -= (podGlass.size.height / 2 + 18) //上下の枠隠すために
        //試行錯誤による位置調整
        ultraAttackIcon.position.x += 219
        ultraAttackIcon.position.y -= 0.5
        ultraAttackIcon.isHidden = true
        //背景で常に表示するIcon
        ultraAttackMonoIcon.position = ultraAttackIcon.position
        //必殺技Push
        ultraAttackPush = SKSpriteNode(imageNamed: "ultraAttackPush")
        ultraAttackPush.xScale = 2.0
        ultraAttackPush.yScale = 2.0
        ultraAttackPush.position.x += 0
        ultraAttackPush.position.y -= 46
        //継承元クラスの初期化
        super.init(texture: nil, color: UIColor.clear, size:base.size)
        //ノード追加
        addChild(meteorGauge)
        addChild(guardGauge)
        addChild(back)
        addChild(base)
        addChild(podIcon)
        let podBase = SKNode()
        podBase.addChild(podGauge)
        podBase.addChild(podTop)
        podBase.addChild(podGlass)
        podBase.addChild(podBottom)
        podBase.yScale = 0.95
        podBase.xScale = 0.95
        podIcon.addChild(podBase)
        addChild(ultraAttackIcon)
        addChild(ultraAttackMonoIcon)
        addChild(ultraAttackPush)
        //zPosion設定
        setzPos(.Gauge)
        back.zPosition = zPosition + 0.1
        meteorGauge.zPosition = zPosition + 0.2
        base.zPosition = zPosition + 0.3
        guardGauge.zPosition = zPosition + 0.4
        podIcon.zPosition = zPosition + 0.5
        podGauge.zPosition = zPosition + 0.51
        podGlass.zPosition = zPosition + 0.52
        podTop.zPosition = zPosition + 0.53
        podBottom.zPosition = zPosition + 0.54
        ultraAttackMonoIcon.zPosition = zPosition + 0.6
        ultraAttackIcon.zPosition = zPosition + 0.61
        ultraAttackPush.zPosition = zPosition + 0.7
        //スケール調整
        xScale = 0.58
        yScale = 0.58
        //フレームの一番下に配置する
        position.y = -frame.size.height / 2 + size.height / 2
    }
    
    func setMeteorGaugeScale(ultraPower: CGFloat){
        print(ultraPower)
        let ultraPowerMax:CGFloat = 1
        if ultraPower < ultraPowerMax {
            let ultraPowerRate:CGFloat = ultraPower / ultraPowerMax
            let scale = ultraPowerRate * 0.69 / ( (ultraPowerMax-1) / ultraPowerMax )
            print("scale\(scale)")
            meteorGaugeMask.run(SKAction.scaleX(to: scale, duration: 0.5))
            ultraAttackIcon.isHidden = true
            ultraAttackPush.isHidden = true
        }
        else{
            meteorGaugeMask.removeAllActions()
            meteorGaugeMask.xScale = 1.0
            ultraAttackIcon.isHidden = false
            ultraAttackPush.isHidden = false
        }
    }
    
    func useMeteorGauge(){
        //Push!の文字は隠す
        ultraAttackPush.isHidden = true
        //Iconの下の分のメータはあらかじめ減らしておく
        meteorGaugeMask.xScale = 0.69
        let gaugeScale = SKAction.scaleX(to: 0, duration: 2)
        let iconHidden = SKAction.run{
            self.ultraAttackIcon.isHidden = true
        }
        meteorGaugeMask.run(SKAction.sequence([gaugeScale,iconHidden]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
