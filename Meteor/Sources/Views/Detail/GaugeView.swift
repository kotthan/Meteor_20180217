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
    
    init(frame: CGRect) {
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
        let meteorGauge = SKSpriteNode(imageNamed: "meteorGauge")
        meteorGauge.xScale = 2.0
        meteorGauge.yScale = 2.0
        meteorGauge.position.x = 60
        addChild(meteorGauge)
        //zPosion
        zPosition = 1000
        back.zPosition = zPosition
        meteorGauge.zPosition = zPosition + 0.1
        base.zPosition = zPosition + 0.2
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
