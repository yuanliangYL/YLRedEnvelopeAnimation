//
//  ViewController.swift
//  YLRedEnvelopeAnimation
//
//  Created by AlbertYuan on 2021/10/12.
//

import UIKit

class ViewController: UIViewController {

    //let dotView = YLAlternateAnimations(frame: UIScreen.main.bounds)

    override func viewDidLoad() {
        super.viewDidLoad()

        YLAlternateAnimations.showInView(view: view)

        DispatchQueue.main.asyncAfter(deadline:DispatchTime.now()+5) {
            YLAlternateAnimations.hideInView(view: self.view)
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

}

