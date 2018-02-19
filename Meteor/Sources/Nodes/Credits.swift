//
//  Credits.swift
//  Meteor
//
//  Created by Ryota on 2018/02/19.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class Credits: SKNode {
    
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
        LabelData(text: "Credits",          size: .Title),
        LabelData(text: "Program",          size: .SubTitle),
        LabelData(text: "Mr.Elaborate",     size: .Name),
        LabelData(text: "Tamiwo",           size: .Name),
        LabelData(text: "Design",           size: .SubTitle),
        LabelData(text: "R.Yamamoto",       size: .Name),
        LabelData(text: "Produce",          size: .SubTitle),
        LabelData(text: "Mr.Elabrate",      size: .Name),
        LabelData(text: "Special Thanks",   size: .SubTitle),
        LabelData(text: "and you!",         size: .Name)]
        
    override init() {
        super.init()
        var yPos:CGFloat = 20.0
        for data in contents.reversed() {
            let label = SKLabelNode(fontNamed: "GillSansStd-ExtraBold")
            label.text = data.text
            label.fontSize = data.size.rawValue
            switch( data.size ){ //下余白
            case .Title:
                yPos += 50
            case .SubTitle:
                yPos += 25
            case .Name:
                yPos += 20
            }
            label.position.y = yPos
            switch( data.size ){ //上余白
            case .Title:
                yPos += 50
            case .SubTitle:
                yPos += 50
            case .Name:
                yPos += 20
            }
            self.addChild(label)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
