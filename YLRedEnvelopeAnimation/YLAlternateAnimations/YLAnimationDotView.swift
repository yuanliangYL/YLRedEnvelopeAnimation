//
//  YLAnimationDotView.swift
//  YLRedEnvelopeAnimation
//
//  Created by AlbertYuan on 2021/10/12.
//

import UIKit

enum DotDitection:Int {

    case DotDitectionLeft = 1

    case  DotDitectionRight = -1

}

class YLAnimationDotView: UIView {

    var direction:DotDitection = .DotDitectionLeft

    //字体颜色
    var textColor:UIColor = UIColor.white {
        didSet{
            textlabel.textColor = textColor
        }
    }

    lazy var textlabel:UILabel = {

        let lable = UILabel(frame: .zero)
        lable.text = "￥"
        lable.textAlignment = .center
        lable.font = UIFont.boldSystemFont(ofSize: 20)
        lable.adjustsFontSizeToFitWidth = true
        //adjustsFontSizeToFitWidth:对于UILabel 如果想让文字在固定宽度内，适应宽度，就是文字越多，字体越少
        return lable
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        layer.cornerRadius = bounds.size.width / 2
        layer.masksToBounds = true
        self.addSubview(textlabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textlabel.frame = self.bounds
    }
}
