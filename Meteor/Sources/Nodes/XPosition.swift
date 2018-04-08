//
//  XPosition.swift
//  Meteor
//
//  Created by Ryota on 2018/04/08.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

//横位置
enum XPositon: CGFloat {
    case left = 93.75
    case center = 187.5
    case right = 281.25
}

//ランダムな値を返す参考
//https://qiita.com/noppefoxwolf/items/d216479dcc66431d7136
extension XPositon: EnumRandomized {
    static var all: [XPositon] {
        return [left, center, right]
    }
}

protocol EnumRandomized {
    static var all: [Self] { get }
    static var random: Self? { get }
}

extension EnumRandomized {
    static var random: Self? {
        let all = self.all
        if all.isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(all.count)))
        return all[index]
    }
}
