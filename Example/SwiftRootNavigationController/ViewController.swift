//
//  ViewController.swift
//  SwiftRootNavigationController
//
//  Created by Ge Will on 04/01/2021.
//  Copyright (c) 2021 Ge Will. All rights reserved.
//

import SwiftRootNavigationController
import UIKit

class ViewController: UIViewController {
    // MARK: - outlets

    @IBOutlet var isHiddenNavigationSwitch: UISwitch!

    // MARK: - properties

    var isHiddenNavigation = false

    // MARK: - life cycle

    static func create(_ isHiddenNavigation: Bool = false) -> ViewController {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.isHiddenNavigation = isHiddenNavigation
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.random

        title = "viewControllers: \(navigationController?.viewControllers.count ?? 0)"
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor.random, size: CGSize(width: 1, height: 1)), for: .default)
        
        navigationController?.isNavigationBarHidden = isHiddenNavigation
    }

    // MARK: - response methods

    @IBAction func pushButtonClick(_ sender: UIButton) {
        let vc = ViewController.create(isHiddenNavigationSwitch.isOn)
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func popButtonClick(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func popToRootButtonClick(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension UIColor {
    static var random: UIColor {
        let red = Int.random(in: 0 ... 255)
        let green = Int.random(in: 0 ... 255)
        let blue = Int.random(in: 0 ... 255)
        return UIColor(red: red, green: green, blue: blue)!
    }

    convenience init?(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        guard red >= 0 && red <= 255 else { return nil }
        guard green >= 0 && green <= 255 else { return nil }
        guard blue >= 0 && blue <= 255 else { return nil }

        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }
}

public extension UIImage {
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)

        defer {
            UIGraphicsEndImageContext()
        }

        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))

        guard let aCgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }

        self.init(cgImage: aCgImage)
    }
}
