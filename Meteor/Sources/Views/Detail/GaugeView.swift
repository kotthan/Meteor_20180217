//
//  GaugeView.swift
//  Meteor
//
//  Created by Kazuaki Oe on 2018/03/01.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//
import SpriteKit

@available(iOS 9.0, *)
class GaugeView: SKSpriteNode {
    let meteorGaugeMask: SKShapeNode
    let guardGaugeMask: SKShapeNode
    let podIcon: SKSpriteNode
    
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
        //継承元クラスの初期化
        super.init(texture: nil, color: UIColor.clear, size:base.size)
        //ノード追加
        addChild(meteorGauge)
        addChild(guardGauge)
        addChild(back)
        addChild(base)
        addChild(podIcon)
        //zPosion設定
        zPosition = 1000
        back.zPosition = zPosition + 0.1
        meteorGauge.zPosition = zPosition + 0.2
        base.zPosition = zPosition + 0.3
        guardGauge.zPosition = zPosition + 0.4
        podIcon.zPosition = zPosition + 0.5
        //スケール調整
        xScale = 0.58
        yScale = 0.58
        //フレームの一番下に配置する
        position.y = -frame.size.height / 2 + size.height / 2
    }
    
    func setMeteorGaugeScale(to: CGFloat){
        if to < 1 {
            meteorGaugeMask.xScale = to * 0.69 / 0.9
        }
        else{
            meteorGaugeMask.xScale = 1.0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
