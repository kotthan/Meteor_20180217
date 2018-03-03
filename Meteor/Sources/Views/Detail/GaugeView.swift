//
//  File.swift
//  Meteor
//
//  Created by Kazuaki Oe on 2018/03/01.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//
import SpriteKit

@available(iOS 9.0, *)
class GaugeView: SKSpriteNode {
    let meteorGaugeMask: SKShapeNode
    
    init(frame: CGRect) {
        let meteorGaugeSprite = SKSpriteNode(imageNamed: "meteorGauge")
        meteorGaugeMask = SKShapeNode(rect: CGRect(x: 0, y: 0,
                                                   width: meteorGaugeSprite.size.width * 2,
                                                   height: meteorGaugeSprite.size.height * 2))
        meteorGaugeMask.position.x = -meteorGaugeSprite.size.width
        meteorGaugeMask.position.y = -meteorGaugeSprite.size.height
        let baseTexture = SKTexture(imageNamed: "gaugeBase")
        super.init(texture: nil, color: UIColor.clear, size:baseTexture.size())
        //ゲージベース枠
        let base = SKSpriteNode(texture: baseTexture)
        addChild(base)
        //ゲージ背景追加
        let back = SKSpriteNode(imageNamed: "gaugeBack")
        back.name = "back"
        //透けてる部分のサイズ分しか背景がないので引き延ばす
        back.xScale = base.size.width / back.size.width
        back.yScale = base.size.height / back.size.height
        addChild(back)
        //meteorゲージ
        meteorGaugeMask.fillColor = UIColor.red
        let meteorGauge = SKCropNode()
        meteorGauge.maskNode = meteorGaugeMask
        meteorGaugeSprite.xScale = 2.0
        meteorGaugeSprite.yScale = 2.0
        meteorGauge.position.x = 60
        meteorGauge.addChild(meteorGaugeSprite)
        addChild(meteorGauge)
        //zPosion
        zPosition = 1000
        back.zPosition = zPosition + 0.1
        meteorGauge.zPosition = zPosition + 0.2
        base.zPosition = zPosition + 0.3
        //縮尺を合わせる
        xScale = 0.58
        yScale = 0.58
        //フレームの一番下に配置する
        position.y = -frame.size.height / 2 + size.height / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
