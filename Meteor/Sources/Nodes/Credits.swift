//
//  Credits.swift
//  Meteor
//
//  Created by Ryota on 2018/02/19.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class Credits: SKNode {
    
    var height:CGFloat = 0.0
    enum FontSize: CGFloat {
        case Title = 55
        case SubTitle = 35
        case Name = 20
    }
    struct LabelData {
        let text: String
        let size: FontSize
    }
    var Labels: [SKLabelNode] = []
    let contents: [LabelData] = [
        //LabelData(text: "Credits",          size: .Title),
        LabelData(text: "Program",          size: .SubTitle),
        LabelData(text: "Mr.Elaborate",     size: .Name),
        LabelData(text: "Tamiwo",           size: .Name),
        LabelData(text: "Design",           size: .SubTitle),
        LabelData(text: "R.Yamamoto",       size: .Name),
        LabelData(text: "Produce",          size: .SubTitle),
        LabelData(text: "Mr.Elabrate",      size: .Name),
        LabelData(text: "Special Thanks",   size: .SubTitle),
        LabelData(text: "Ajany",            size: .Name),
        LabelData(text: "and you!",         size: .Name)]
        
    init(frame: CGRect) {
        super.init()
        self.height = frame.size.height + 50.0
        for data in contents.reversed() {
            let label = SKLabelNode(fontNamed: "GillSansStd-ExtraBold")
            label.text = data.text
            label.fontSize = data.size.rawValue
            switch( data.size ){ //下余白
            case .Title:
                self.height += 50
            case .SubTitle:
                self.height += 25
            case .Name:
                self.height += 20
            }
            label.position.y = self.height
            switch( data.size ){ //上余白
            case .Title:
                self.height += 50
            case .SubTitle:
                self.height += 50
            case .Name:
                self.height += 20
            }
            self.addChild(label)
        }
        //ロゴほか
        let logo = SKSpriteNode(imageNamed: "otlogo")
        logo.position.y = frame.height * 0.75
        logo.setScale(0.8)
        self.addChild(logo)
        let soundLogo = SKSpriteNode(imageNamed: "hurt-logo")
        soundLogo.position.y = frame.height * 0.9
        soundLogo.setScale(1.0)
        self.addChild(soundLogo)
        let copyRight = SKLabelNode(fontNamed: "GillSansStd-ExtraBold")
        copyRight.fontSize = 20
        copyRight.text = "©︎ 2018 OTUTAMA STUDIO"
        copyRight.position.y = frame.height * 0.3
        self.addChild(copyRight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
