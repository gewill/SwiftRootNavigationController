import UIKit

open class SwiftRootNavigationController: UINavigationController {
    fileprivate var sw_delegate: UINavigationControllerDelegate?
    fileprivate var animationComplete: ((Bool) -> Swift.Void)?

    // MARK: override

    override open var delegate: UINavigationControllerDelegate? {
        set {
            self.sw_delegate = newValue
        }
        get {
            return self.sw_delegate
        }
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        viewControllers = super.viewControllers
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override public init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        commonInit()
    }

    override public init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        commonInit()
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    init(rootViewControllerNoWrapping: UIViewController) {
        super.init(rootViewController: SwiftContainerController(contentController: rootViewControllerNoWrapping))
        commonInit()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        super.delegate = self
        super.setNavigationBarHidden(true, animated: false)
    }

    override open func forUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any?) -> UIViewController? {
        guard #available(iOS 9.0, *) else {
            var controller: UIViewController? = super.forUnwindSegueAction(action, from: fromViewController, withSender: sender)

            if controller == nil {
                if let index = viewControllers.index(of: fromViewController) {
                    for i in (index - 1) ... 0 {
                        controller = viewControllers[i].forUnwindSegueAction(action, from: fromViewController, withSender: sender)

                        if controller != nil { break }
                    }
                }
            }
            return controller
        }
        return nil
    }

    @available(iOS 9.0, *)
    override open func allowedChildrenForUnwinding(from source: UIStoryboardUnwindSegueSource) -> [UIViewController] {
        var controller: [UIViewController]? = super.allowedChildrenForUnwinding(from: source)

        if controller?.count == 0 {
            if let index = viewControllers.firstIndex(of: source.source) {
                for i in (index - 1) ... 0 {
                    controller = viewControllers[i].allowedChildrenForUnwinding(from: source)

                    if controller?.count != 0 { break }
                }
            }
        }
        return controller ?? []
    }

    override open func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        // Override to protect
    }

    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let last = viewControllers.last {
            let currentLast = last.unwrapViewController

            super.pushViewController(SwiftContainerController(controller: viewController, navigationBarClass: viewController.sw_navigationBarClass(), withPlaceholder: useSystemBackBarButtonItem, backItem: currentLast.navigationItem.backBarButtonItem, backTitle: currentLast.navigationItem.title), animated: animated)
        } else {
            super.pushViewController(SwiftContainerController(controller: viewController, navigationBarClass: viewController.sw_navigationBarClass()), animated: animated)
        }
    }

    override open func popViewController(animated: Bool) -> UIViewController? {
        return super.popViewController(animated: animated)?.unwrapViewController
    }

    override open func popToRootViewController(animated: Bool) -> [UIViewController]? {
        return super.popToRootViewController(animated: animated)?.map {
            return $0.unwrapViewController
        }
    }

    override open func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        var controllerToPop: UIViewController?

        for vc in super.viewControllers {
            if vc.unwrapViewController == viewController {
                controllerToPop = vc
                break
            }
        }

        if let ctp = controllerToPop {
            return super.popToViewController(ctp, animated: animated)?.map {
                return $0.unwrapViewController
            }
        }
        return nil
    }

    override open func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers.enumerated().map { index, item
            in
            if self.useSystemBackBarButtonItem && index > 0 {
                return SwiftContainerController(controller: item, navigationBarClass: item.sw_navigationBarClass(), withPlaceholder: self.useSystemBackBarButtonItem, backItem: viewControllers[index - 1].navigationItem.backBarButtonItem, backTitle: viewControllers[index - 1].navigationItem.title)
            } else {
                return SwiftContainerController(controller: item, navigationBarClass: item.sw_navigationBarClass())
            }

        }, animated: animated)
    }

    override open var shouldAutorotate: Bool {
        return (self.topViewController?.shouldAutorotate) ?? false
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (self.topViewController?.supportedInterfaceOrientations) ?? .portrait
    }

    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return (self.topViewController?.preferredInterfaceOrientationForPresentation) ?? .portrait
    }

    override open func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) {
            return true
        }
        return sw_delegate?.responds(to: aSelector) ?? false
    }

    override open func forwardingTarget(for aSelector: Selector!) -> Any? {
        return sw_delegate
    }

    // MARK: Public

    var transferNavigationBarAttributes: Bool = false
    var useSystemBackBarButtonItem: Bool = false

    var sw_topViewController: UIViewController? {
        return super.topViewController?.unwrapViewController
    }

    var sw_visibleViewController: UIViewController? {
        return super.visibleViewController?.unwrapViewController
    }

    var sw_viewControllers: [UIViewController]? {
        return super.viewControllers.map {
            return $0.unwrapViewController
        }
    }

    func removeViewController(controller: UIViewController, animated flag: Bool = false) {
        var viewControllers: [UIViewController] = super.viewControllers
        var controllerToRemove: UIViewController?

        for vc in viewControllers {
            if vc.unwrapViewController == controller {
                controllerToRemove = vc
                break
            }
        }

        if let ctp = controllerToRemove, let index = viewControllers.firstIndex(of: ctp) {
            viewControllers.remove(at: index)
            super.setViewControllers(viewControllers, animated: flag)
        }
    }

    func pushViewController(viewController: UIViewController, animated: Bool, complete: @escaping (Bool) -> Swift.Void) {
        animationComplete?(false)
        animationComplete = complete
        pushViewController(viewController, animated: animated)
    }

    func popViewController(animated: Bool, complete: @escaping (Bool) -> Swift.Void) -> UIViewController? {
        animationComplete?(false)
        animationComplete = complete

        let vc = popViewController(animated: animated)

        animationComplete?(true)
        animationComplete = nil

        return vc
    }

    func popToViewController(viewController: UIViewController, animated: Bool, complete: @escaping (Bool) -> Swift.Void) -> [UIViewController]? {
        animationComplete?(false)
        animationComplete = complete

        let vcs = popToViewController(viewController, animated: animated)

        if let count = vcs?.count, count > 0 {
            animationComplete?(true)
            animationComplete = nil
        }
        return vcs
    }

    func popToRootViewController(animated: Bool, complete: @escaping (Bool) -> Swift.Void) -> [UIViewController]? {
        animationComplete?(false)
        animationComplete = complete

        let vcs = popToRootViewController(animated: animated)

        if let count = vcs?.count, count > 0 {
            animationComplete?(true)
            animationComplete = nil
        }
        return vcs
    }
}

extension SwiftRootNavigationController: UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    @objc fileprivate func onBack(_ sender: Any) {
        _ = popViewController(animated: true)
    }

    fileprivate func commonInit() {
    }

    // MARK: - UINavigationControllerDelegate

    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let isRootVC = viewController == navigationController.viewControllers.first
        let unwrapVC = viewController.unwrapViewController

        if !isRootVC {
            let hasSetLeftItem = unwrapVC.navigationItem.leftBarButtonItem != nil

            if hasSetLeftItem && unwrapVC.sw_disableInteractivePop == true {
                unwrapVC.sw_disableInteractivePop = true
            } else if unwrapVC.sw_disableInteractivePop == true {
                unwrapVC.sw_disableInteractivePop = false
            }

            if !useSystemBackBarButtonItem && !hasSetLeftItem {
                if let customVC = unwrapVC as? SwiftNavigationItemCustomizable,
                   let customBackItem = customVC.sw_customBackItemWithTarget?(target: self, action: #selector(onBack(_:))) {
                    unwrapVC.navigationItem.leftBarButtonItem = customBackItem
                } else {
                    unwrapVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .plain, target: self,
                                                                                action: #selector(onBack(_:)))
                }
            }
        }
        sw_delegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }

    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let isRootVC = viewController == navigationController.viewControllers.first
        let unwrapVC = viewController.unwrapViewController

        if animated == false {
            viewController.loadViewIfNeeded()
        }

        if unwrapVC.sw_disableInteractivePop {
            interactivePopGestureRecognizer?.delegate = nil
            interactivePopGestureRecognizer?.isEnabled = false
        } else {
            interactivePopGestureRecognizer?.delegate = self
            interactivePopGestureRecognizer?.isEnabled = !isRootVC
        }

        SwiftRootNavigationController.attemptRotationToDeviceOrientation()

        animationComplete?(true)
        animationComplete = nil

        sw_delegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }

    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return sw_delegate?.navigationControllerSupportedInterfaceOrientations?(_: navigationController) ?? .all
    }

    public func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return sw_delegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(_: navigationController) ?? .portrait
    }

    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return sw_delegate?.navigationController?(navigationController, interactionControllerFor: animationController)
    }

    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return sw_delegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }

    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == interactivePopGestureRecognizer
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == interactivePopGestureRecognizer
    }
}
