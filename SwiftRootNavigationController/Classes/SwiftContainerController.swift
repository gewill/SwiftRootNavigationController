import UIKit

extension UIViewController {
    var unwrapViewController: UIViewController {
        return (self as? SwiftContainerController)?.contentViewController ?? self
    }
}

open class SwiftContainerController: UIViewController {
    open private(set) var contentViewController: UIViewController?
    fileprivate var containerNavigationController: UINavigationController?

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(controller: UIViewController, navigationBarClass: AnyClass?, withPlaceholder: Bool = false, backItem: UIBarButtonItem? = nil, backTitle: String? = nil) {
        super.init(nibName: nil, bundle: nil)

        contentViewController = controller
        containerNavigationController = SwiftContainerNavigationController(navigationBarClass: navigationBarClass, toolbarClass: nil)

        if withPlaceholder {
            let vc = UIViewController()
            vc.title = backTitle
            vc.navigationItem.backBarButtonItem = backItem
            containerNavigationController?.viewControllers = [vc, controller]
        } else {
            containerNavigationController?.viewControllers = [controller]
        }

        addChild(containerNavigationController!)
        containerNavigationController?.didMove(toParent: self)
    }

    init(contentController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        contentViewController = contentController
        addChild(contentViewController!)
        contentViewController?.didMove(toParent: self)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        if let containerNav = containerNavigationController {
            containerNav.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(containerNav.view)
            containerNav.view.frame = view.bounds
        } else {
            contentViewController?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentViewController?.view.frame = view.bounds
            view.addSubview((contentViewController?.view)!)
        }
    }

    override open var shouldAutorotate: Bool {
        return (self.contentViewController?.shouldAutorotate)!
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (self.contentViewController?.supportedInterfaceOrientations)!
    }

    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return (self.contentViewController?.preferredInterfaceOrientationForPresentation)!
    }

    override open func becomeFirstResponder() -> Bool {
        return (contentViewController?.becomeFirstResponder())!
    }

    override open var canBecomeFirstResponder: Bool {
        return (self.contentViewController?.canBecomeFirstResponder)!
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return (self.contentViewController?.preferredStatusBarStyle)!
    }

    override open var prefersStatusBarHidden: Bool {
        return (self.contentViewController?.prefersStatusBarHidden)!
    }

    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return (contentViewController?.preferredStatusBarUpdateAnimation)!
    }

    @available(iOS 11.0, *)
    override open var prefersHomeIndicatorAutoHidden: Bool {
        return (contentViewController?.prefersHomeIndicatorAutoHidden) ?? false
    }

    @available(iOS 11.0, *)
    override open var childForHomeIndicatorAutoHidden: UIViewController? {
        return contentViewController
    }

    override open func forUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any?) -> UIViewController? {
        guard #available(iOS 9.0, *) else {
            let viewController = contentViewController?.forUnwindSegueAction(_: action, from: fromViewController, withSender: sender)
            return viewController
        }
        return nil
    }

    @available(iOS 9.0, *)
    override open func allowedChildrenForUnwinding(from source: UIStoryboardUnwindSegueSource) -> [UIViewController] {
        return contentViewController?.allowedChildrenForUnwinding(from: source) ?? []
    }

    override open var hidesBottomBarWhenPushed: Bool {
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
        get {
            return (contentViewController?.hidesBottomBarWhenPushed)!
        }
    }

    override open var title: String? {
        set {
            super.title = newValue
        }
        get {
            return contentViewController?.title
        }
    }

    override open var tabBarItem: UITabBarItem! {
        set {
            super.tabBarItem = newValue
        }
        get {
            return contentViewController?.tabBarItem
        }
    }
}
