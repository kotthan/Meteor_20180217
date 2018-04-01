//
//  BaseScene.swift
//  Meteor
//
//  Created by Ryota on 2018/04/01.
//  Copyright © 2018年 Kazuaki Oe. All rights reserved.
//

import SpriteKit

class BaseScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: タッチ関係プロパティ
    private var beganPos: CGPoint = CGPoint.zero
    private var beganPosOnView: CGPoint = CGPoint.zero  //viewの座標系でのタッチ位置
    private var tapPoint: CGPoint = CGPoint.zero
    private var endPyPos:CGFloat = 0.0
    private var movePyPos:CGFloat = 0.0
    private var touchNode: SKSpriteNode?
    enum TouchAction {  //タッチアクション
        case tap        //タップ
        case swipeUp    //上スワイプ
        case swipeDown  //下スワイプ
        case swipeLeft  //左スワイプ
        case swipeRight //右スワイプ
    }
    
    override init(size: CGSize) {
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first as UITouch?
        {
            self.beganPosOnView = CGPoint(x: touch.location(in: view).x,
                                          y: frame.maxY - touch.location(in: view).y ) //y座標を反転する
            self.beganPos = touch.location(in: self)
            //タッチしたノードを記録しておく
            self.touchNode = self.atPoint(beganPos) as? SKSpriteNode
            if let node = touchNode{
                touchBegan(node: node)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first as UITouch?
        {
            let endPosOnView = CGPoint(x: touch.location(in: view).x,
                                       y: frame.maxY - touch.location(in: view).y )
            //タッチアクション取得
            let touchAction = getTouchAction(begin: beganPosOnView, end: endPosOnView)
            touchMoved(action: touchAction)
            //タップノード取得
            if let touchingNode = self.atPoint(touch.location(in: self)) as? SKSpriteNode {
                if self.touchNode == touchingNode {     //同じノードをタップし続けている場合
                    touchMoved(node: touchingNode)
                }
                else {                                  //別のノードをタップした場合
                    touchBegan(node: touchingNode)
                    self.touchNode = touchingNode
                }
            }
            else {
                if let touchedNode = self.touchNode {   //タッチしているノードがなくなった
                    touchCancelled(node: touchedNode)
                    self.touchNode = nil
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first as UITouch?
        {
            let endPosOnView = CGPoint(x: touch.location(in: view).x,
                                       y: frame.maxY - touch.location(in: view).y )
            //タッチアクション取得
            let touchAction = getTouchAction(begin: beganPosOnView, end: endPosOnView)
            touchMoved(action: touchAction)
            //タップノード取得
            if let touchingNode = self.atPoint(touch.location(in: self)) as? SKSpriteNode {
                if self.touchNode == touchingNode {     //同じノードをタップし続けていた場合
                    touchEnded(node: touchingNode)
                }
                else {                                  //別のノードをタップした場合
                    touchBegan(node: touchingNode)
                    self.touchNode = touchingNode
                }
            }
            else {
                if let touchedNode = self.touchNode {   //タッチしているノードがなくなった
                    touchCancelled(node: touchedNode)
                    self.touchNode = nil
                }
            }
        }
    }
    
    func touchBegan(node: SKSpriteNode){}
    func touchMoved(node: SKSpriteNode){}
    func touchEnded(node: SKSpriteNode){}
    func touchCancelled(node: SKSpriteNode){}
    func touchBegan(action: TouchAction){}
    func touchMoved(action: TouchAction){}
    func touchEnded(action: TouchAction){}
    
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
