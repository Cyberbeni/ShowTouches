import UIKit

public class ShowTouchesGestureRecognizer: UIGestureRecognizer, UIGestureRecognizerDelegate {
	let touchesShowingController: ShowTouchesController

	public init(config: ShowTouchesConfig = ShowTouchesConfig()) {
		touchesShowingController = ShowTouchesController(config: config)
		super.init(target: nil, action: nil)
		cancelsTouchesInView = false
		delaysTouchesBegan = false
		delaysTouchesEnded = false
		delegate = self
	}

	override public func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent) {
		for touch in touches {
			touchesShowingController.touchBegan(touch, view: view!)
		}
	}

	override public func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent) {
		for touch in touches {
			touchesShowingController.touchMoved(touch, view: view!)
		}
	}

	override public func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent) {
		for touch in touches {
			touchesShowingController.touchEnded(touch, view: view!)
		}
	}

	override public func touchesCancelled(_ touches: Set<UITouch>, with _: UIEvent) {
		for touch in touches {
			touchesShowingController.touchEnded(touch, view: view!)
		}
	}

	public func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
		true
	}
}
