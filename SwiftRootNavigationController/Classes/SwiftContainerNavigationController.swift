import UIKit

open class SwiftContainerNavigationController: UINavigationController {
    override init(rootViewController: UIViewController) {
        super.init(navigationBarClass: rootViewController.sw_navigationBarClass(), toolbarClass: nil)
        pushViewController(rootViewController, animated: false)
    }

    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        interactivePopGestureRecognizer?.isEnabled = false

        if let _ = sw_navigationController?.transferNavigationBarAttributes {
            navigationBar.isTranslucent = (navigationController?.navigationBar.isTranslucent)!
            navigationBar.tintColor = navigationController?.navigationBar.tintColor
            navigationBar.barTintColor = navigationController?.navigationBar.barTintColor
            navigationBar.barStyle = (navigationController?.navigationBar.barStyle)!
            navigationBar.backgroundColor = navigationController?.navigationBar.backgroundColor

            navigationBar.setBackgroundImage(navigationController?.navigationBar.backgroundImage(for: .default), for: .default)
            navigationBar.setTitleVerticalPositionAdjustment((navigationController?.navigationBar.titleVerticalPositionAdjustment(for: .default))!, for: .default)

            navigationBar.titleTextAttributes = navigationController?.navigationBar.titleTextAttributes
            navigationBar.shadowImage = navigationController?.navigationBar.shadowImage
            navigationBar.backIndicatorImage = navigationController?.navigationBar.backIndicatorImage
            navigationBar.backIndicatorTransitionMaskImage = navigationController?.navigationBar.backIndicatorTransitionMaskImage
        }
        view.layoutIfNeeded()
    }

    override open var tabBarController: UITabBarController? {
        let tabbarController: UITabBarController? = super.tabBarController
        let navigationController: UINavigationController? = self.sw_navigationController

        if tabbarController != nil {
            if navigationController?.tabBarController != nil {
                return tabbarController!
            } else {
                let isHidden = navigationController?.viewControllers.contains { (item) -> Bool in
                    item.hidesBottomBarWhenPushed == true
                }
                return (!(tabbarController?.tabBar.isTranslucent)! || isHidden ?? false) ? nil : tabbarController!
            }
        }
        return nil
    }

    override open var viewControllers: [UIViewController] {
        set {
            if self.navigationController != nil {
                self.navigationController?.viewControllers = newValue
            } else {
                super.viewControllers = newValue
            }
        }

        get {
            if self.navigationController != nil {
                if self.navigationController is SwiftRootNavigationController {
                    return (self.sw_navigationController?.sw_viewControllers)!
                }
            }
            return super.viewControllers
        }
    }

    override open func forUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any?) -> UIViewController? {
        guard #available(iOS 9.0, *) else {
            if navigationController != nil {
                return navigationController?.forUnwindSegueAction(_: action, from: fromViewController, withSender: sender)
            }
            return super.forUnwindSegueAction(_: action, from: fromViewController, withSender: sender)
        }
        return nil
    }

    @available(iOS 9.0, *)
    override open func allowedChildViewControllersForUnwinding(from source: UIStoryboardUnwindSegueSource) -> [UIViewController] {
        if navigationController != nil {
            return navigationController?.allowedChildViewControllersForUnwinding(from: source) ?? []
        }
        return super.allowedChildViewControllersForUnwinding(from: source)
    }

    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if navigationController != nil {
            navigationController?.pushViewController(viewController, animated: animated)
        } else {
            super.pushViewController(viewController, animated: animated)
        }
    }

    override open func popViewController(animated: Bool) -> UIViewController? {
        if navigationController != nil {
            return navigationController?.popViewController(animated: animated)
        }
        return super.popViewController(animated: animated)
    }

    override open func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if navigationController != nil {
            return navigationController?.popToRootViewController(animated: animated)
        }
        return super.popToRootViewController(animated: animated)
    }

    override open func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if navigationController != nil {
            return navigationController?.popToViewController(viewController, animated: animated)
        }
        return super.popToViewController(viewController, animated: animated)
    }

    override open func forwardingTarget(for aSelector: Selector!) -> Any? {
        if let _ = navigationController?.responds(to: aSelector) {
            return navigationController
        }
        return nil
    }

    override open var delegate: UINavigationControllerDelegate? {
        set {
            if self.navigationController != nil {
                self.navigationController?.delegate = newValue
            } else {
                super.delegate = newValue
            }
        }

        get {
            return (self.navigationController != nil) ? self.navigationController?.delegate : super.delegate
        }
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return (self.topViewController?.preferredStatusBarStyle)!
    }

    override open var prefersStatusBarHidden: Bool {
        return (self.topViewController?.prefersStatusBarHidden)!
    }

    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return (topViewController?.preferredStatusBarUpdateAnimation)!
    }
}
