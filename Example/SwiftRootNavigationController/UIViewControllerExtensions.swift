import SwiftRootNavigationController
import UIKit

extension UIViewController: SwiftNavigationItemCustomizable {
    public func sw_customBackItemWithTarget(target: Any, action: Selector) -> UIBarButtonItem? {
        if #available(iOS 13.0, *) {
            return UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: UIBarButtonItem.Style.plain, target: target, action: action)
        } else {
            return UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: target, action: action)
        }
    }
}
