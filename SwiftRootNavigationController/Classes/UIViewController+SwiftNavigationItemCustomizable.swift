import UIKit

private var disableInteractivePopKey: String = "disableInteractivePop"

@objc public protocol SwiftNavigationItemCustomizable: AnyObject {
    @objc optional func sw_customBackItemWithTarget(target: Any, action: Selector) -> UIBarButtonItem?
}

extension UIViewController {
    public var sw_disableInteractivePop: Bool {
        set {
            objc_setAssociatedObject(self, &disableInteractivePopKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }

        get {
            return objc_getAssociatedObject(self, &disableInteractivePopKey) as? Bool ?? false
        }
    }

    public var sw_navigationController: SwiftRootNavigationController? {
        var vc: UIViewController? = self
        while vc != nil && !(vc is SwiftRootNavigationController) {
            vc = vc?.navigationController
        }
        return vc as? SwiftRootNavigationController
    }

    open func sw_navigationBarClass() -> Swift.AnyClass? {
        return nil
    }
}
