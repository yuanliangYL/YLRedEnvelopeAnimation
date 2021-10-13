//
//  YLAlternateAnimations.swift
//  YLRedEnvelopeAnimation
//
//  Created by AlbertYuan on 2021/10/12.
//

import UIKit

class YLAlternateAnimations: UIView {

    lazy var dotContentView:UIView = {
        let content = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 50))
        content.center = self.center
        content.backgroundColor = .clear
        return content
    }()

    var leftDot:YLAnimationDotView?

    var rightDot:YLAnimationDotView?

    var displaylink: CADisplayLink?

    var speed:Int = 2

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setDisplayLink()
    }

    func setupUI(){

        backgroundColor = .clear
        self.addSubview(dotContentView)

        let dotColor = [UIColor(red: 192/255.0, green: 192/255.0, blue: 192/255.0, alpha: 1), UIColor(red: 255/255.0, green: 215/255.0, blue: 0/255.0, alpha: 1)]
        for i in 0 ..< dotColor.count {
            //首位位置设置
            let dotX:CGFloat =  (i == 0) ? 0 : dotContentView.bounds.width - dotWidth()
            let dotView:YLAnimationDotView = YLAnimationDotView(frame: CGRect(x: dotX, y: 0, width: dotWidth(), height: dotWidth()))
            dotView.backgroundColor = dotColor[i]
            dotView.textColor = .white
            //垂直居中
            dotView.center = CGPoint(x: dotView.center.x, y: dotContentView.bounds.size.height/2)
            dotContentView.addSubview(dotView)
            if i == 0 {
                leftDot = dotView
                leftDot?.direction = .DotDitectionLeft
            }else{
                rightDot = dotView
                rightDot?.direction = .DotDitectionRight
            }
        }
    }

    func dotWidth() -> CGFloat {
        let margin = dotContentView.bounds.size.width / 5
        let dotwidth = (dotContentView.bounds.size.width - margin) / 2
        return dotwidth
    }

    func setDisplayLink(){
        displaylink = CADisplayLink(target: self, selector: #selector(reloadView))
        //displaylink?.add(to: RunLoop.main, forMode: .common)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dotContentView.center = self.center
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


// MARK: -- animation
extension YLAlternateAnimations:CAAnimationDelegate{
    //位置
   @objc func reloadView(){
//        print(#function)
    guard let left = leftDot,let right = rightDot else {
        return
    }

    //改变移动方向、约束移动范围
    //移动到右边距时:最右侧
    if ((left.center.x) >= dotContentView.bounds.width - dotWidth()/2.0) {

        left.center.x = dotContentView.bounds.width - dotWidth()/2.0
        left.direction = .DotDitectionRight
        right.direction = .DotDitectionLeft
        dotContentView.bringSubviewToFront(left)
    }


    //移动到左边距时
    if ((left.center.x) <=  dotWidth()/2.0) {
        left.center.x =  dotWidth()/2.0
        left.direction = .DotDitectionLeft
        right.direction = .DotDitectionRight
        dotContentView.sendSubviewToBack(left)
    }


    //更新第一个豆的位置:位置核心：这里可以考虑使用正弦函数
    left.center.x += CGFloat(left.direction.rawValue * speed)
    //根据第一个豆的位置确定第二个豆的位置
    //间隔
    let apart:CGFloat = left.center.x - dotContentView.bounds.size.width / 2.0
//    print(apart)
    right.center.x = dotContentView.bounds.width/2.0 - apart

    //显示缩放效果
    scaleAnimation(dot: left)
    scaleAnimation(dot: right)
    }

    func scaleAnimation(dot:YLAnimationDotView){

        let apart:CGFloat = dot.center.x - dotContentView.bounds.size.width / 2.0
        //最大距离
        let maxAppart = dotContentView.bounds.width - dotWidth()/2
        //移动距离和最大距离的比例
        let appartScale = apart/maxAppart
        //获取比例对应余弦曲线的Y值 -π/2~π/2 (0-1-0)
        let tramscale = cos(appartScale * CGFloat.pi/2)

        switch dot.direction {
        case .DotDitectionLeft:
            //向右移动则 中间变大 两边变小
            dot.transform = CGAffineTransform(scaleX: 1-tramscale/4.0, y: 1-tramscale/4.0)
        default:
            //向左移动则 中间变小 两边变大
            dot.transform = CGAffineTransform(scaleX: 1+tramscale/4.0, y: 1+tramscale/4.0)
        }
    }
}

//对外操作
extension YLAlternateAnimations{

   public class func showInView(view: UIView){

        let showView:YLAlternateAnimations = YLAlternateAnimations(frame: view.bounds)
        view.addSubview(showView)
        showView.start()

    }

   public class func hideInView(view: UIView){

        for loadingview in view.subviews {
            if loadingview.isKind(of: YLAlternateAnimations.self) {
                UIView.animate(withDuration: 0.5) {
                    loadingview.alpha = 0
                } completion: { _ in
                    loadingview.removeFromSuperview()
                    (loadingview as! YLAlternateAnimations).stop()
                }
            }
        }
    }

    func start(){
        displaylink?.add(to: RunLoop.main, forMode: .common)
    }

    func stop(){
        displaylink?.remove(from: RunLoop.main, forMode: .common)
    }
}



/*

 动画方案：

 func reloadView(){
     //print(#function)
     //改变移动方向、约束移动范围
     //移动到右边距时:最右侧
     let changeCenterX  = dotContentView.bounds.size.width -  dotWidth()/2
     let duration:Double = 0.6

     // MARK: -- 左侧动画
     let leftAnimation = CABasicAnimation()
     leftAnimation.keyPath = "position.x"
     leftAnimation.fromValue = leftDot?.center.x
     leftAnimation.toValue = changeCenterX
     leftAnimation.autoreverses = true
     leftAnimation.duration = duration
     leftAnimation.repeatCount = MAXFLOAT
     leftAnimation.delegate = self
     leftAnimation.fillMode = .forwards
     leftAnimation.isRemovedOnCompletion = false
     leftDot?.layer.add(leftAnimation, forKey: "leftAnimation")

     // MARK: -- 缩放动画
     let leftScale = CAKeyframeAnimation()
     leftScale.keyPath = "transform.scale"
     leftScale.fillMode = .forwards
     leftScale.isRemovedOnCompletion = false
     leftScale.repeatCount = MAXFLOAT
     leftScale.autoreverses = false
//        leftScale.keyTimes = [NSNumber(value: 0.2 as Float),
//                              NSNumber(value: 0.2 as Float),
//                              NSNumber(value: 0.2 as Float),
//                              NSNumber(value: 0.2 as Float),
//                              NSNumber(value: 0.2 as Float)]
     leftScale.values = [NSNumber(value: 1.0 as Float),
                         NSNumber(value: 0.5 as Float),
                         NSNumber(value: 1.0 as Float),
                         NSNumber(value: 1.5 as Float),
                         NSNumber(value: 1.0 as Float)]
     leftScale.duration = duration * 2
     leftScale.timingFunction = CAMediaTimingFunction(name: .linear)
     leftDot?.layer.add(leftScale, forKey: "leftScale")
//
//        // MARK: -- 右侧动画
     let rightAnimation = CABasicAnimation()
     rightAnimation.keyPath = "position.x"
     rightAnimation.fromValue = changeCenterX
     rightAnimation.toValue = leftDot?.center.x
     rightAnimation.autoreverses = true
     rightAnimation.duration = duration
     rightAnimation.repeatCount = MAXFLOAT
     rightAnimation.delegate = self
     rightAnimation.fillMode = .forwards
     rightAnimation.isRemovedOnCompletion = false
     rightDot?.layer.add(rightAnimation, forKey: "rightAnimation")
//
//        // MARK: -- 缩放动画
     let rightScale = CAKeyframeAnimation()
     rightScale.keyPath = "transform.scale"
     rightScale.fillMode = .forwards
     rightScale.isRemovedOnCompletion = false
     rightScale.repeatCount = MAXFLOAT
     rightScale.autoreverses = false
     rightScale.values = [1.0,1.5,1.0,0.5,1.0]
     let rightvaluesArray:[NSNumber] = [NSNumber(value: 1.0 as Float),
                                   NSNumber(value: 0.5 as Float),
                                   NSNumber(value: 1.0 as Float),
                                   NSNumber(value: 1.5 as Float),
                                   NSNumber(value: 1.0 as Float)]
     rightScale.values = rightvaluesArray
     rightScale.duration = duration * 2
     rightDot?.layer.add(rightScale, forKey: nil)

     UIView.animate(withDuration: duration, delay: 0, options: [.repeat]) {
         self.dotContentView.bringSubviewToFront(self.leftDot!)
     } completion: { _ in
         UIView.animate(withDuration: duration) {
             self.dotContentView.sendSubviewToBack(self.leftDot!)
         } completion: { _ in

         }
     }
 }


 func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {

     print(anim)

     if (flag) {
         let animation:CABasicAnimation = anim as! CABasicAnimation
         if  animation.value(forKey: "AnimationKey") as! String == "leftAnimation" {
             print("in left")
         }else{
             print("in right")

         }
        }
 }

 */
