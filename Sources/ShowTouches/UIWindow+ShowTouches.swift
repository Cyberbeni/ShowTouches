import ObjectiveC
import UIKit

extension UIWindow {
	static var touchesShowingControllerKey = 0
	private static var config: ShowTouchesConfig = ShowTouchesConfig()
	
	var controller: ShowTouchesController {
		var controller: ShowTouchesController? = objc_getAssociatedObject(self, &UIWindow.touchesShowingControllerKey) as? ShowTouchesController
		if controller == nil {
			controller = ShowTouchesController(config: Self.config)
			objc_setAssociatedObject(self, &UIWindow.touchesShowingControllerKey, controller, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
		return controller!
	}

	@objc(showTouches_sendEvent:) func showTouches_sendEvent(_ event: UIEvent) {
		showTouches_sendEvent(event)
		if let touches = event.allTouches {
			for touch in touches {
				switch touch.phase {
				case .began:
					controller.touchBegan(touch, view: self)

				case .moved:
					controller.touchMoved(touch, view: self)

				case .ended, .cancelled:
					controller.touchEnded(touch, view: self)

				default:
					break
				}
			}
		}
	}
	
	public static func configure(_ config: ShowTouchesConfig) {
		Self.config = config
	}
	
	@objc public static func showTouches(_ show: Bool = true) {
		guard let originalMethod = class_getInstanceMethod(UIWindow.self, #selector(sendEvent(_:))),
		      let newMethod = class_getInstanceMethod(UIWindow.self, #selector(showTouches_sendEvent(_:)))
		else {
			return
		}
		
		if show {
			method_exchangeImplementations(originalMethod, newMethod)
		} else {
			method_exchangeImplementations(newMethod, originalMethod)
		}
	}	

	@available(*, deprecated, message: "Use 'showTouches()' instead.")
	@objc public static func startShowingTouches() {
		showTouches()
	}
}
