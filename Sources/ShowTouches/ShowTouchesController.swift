import UIKit

public struct ShowTouchesConfig {
	let touchColor: UIColor
	let circleSize: CGFloat
	let shortTapTresholdDuration: Double
	let shortTapInitialCircleRadius: CGFloat
	let shortTapFinalCircleRadius: CGFloat
	
	public init(touchColor: UIColor = UIColor(red: 0.0 / 255, green: 135.0 / 255, blue: 244.0 / 255, alpha: 0.8),
				circleSize: CGFloat = 61.0,
				shortTapTresholdDuration: Double = 0.11,
				shortTapInitialCircleRadius: CGFloat = 22.0,
				shortTapFinalCircleRadius: CGFloat = 57.0) {
		self.touchColor = touchColor
		self.circleSize = circleSize
		self.shortTapTresholdDuration = shortTapTresholdDuration
		self.shortTapInitialCircleRadius = shortTapInitialCircleRadius
		self.shortTapFinalCircleRadius = shortTapFinalCircleRadius
	}
}

class ShowTouchesController {
	let touchImageViewQueue: GSTouchImageViewQueue
	var touchImgViewsDict = [String: UIView]()
	var touchesStartDateDict = [String: NSDate]()
	let config: ShowTouchesConfig
	
	init(config: ShowTouchesConfig) {
		self.config = config
		touchImageViewQueue = GSTouchImageViewQueue(touchesCount: 8, config: config)
	}
	
	public func touchBegan(_ touch: UITouch, view: UIView) {
		let touchImgView = touchImageViewQueue.popTouchImageView()
		touchImgView.center = touch.location(in: view)
		view.addSubview(touchImgView)

		touchImgView.alpha = 0.0
		touchImgView.transform = CGAffineTransform(scaleX: 1.13, y: 1.13)
		setTouchImageView(touchImgView, for: touch)

		UIView.animate(withDuration: 0.1) {
			touchImgView.alpha = 1.0
			touchImgView.transform = CGAffineTransform(scaleX: 1, y: 1)
		}

		touchesStartDateDict[String(format: "%p", touch)] = NSDate()
	}

	public func touchMoved(_ touch: UITouch, view: UIView) {
		touchImageView(for: touch)?.center = touch.location(in: view)
	}

	public func touchEnded(_ touch: UITouch, view: UIView) {
		guard let touchStartDate = touchesStartDateDict[String(format: "%p", touch)], let touchImgView = touchImageView(for: touch) else { return }
		let touchDuration = NSDate().timeIntervalSince(touchStartDate as Date)
		touchesStartDateDict.removeValue(forKey: String(format: "%p", touch))

		if touchDuration < config.shortTapTresholdDuration {
			showExpandingCircle(at: touch.location(in: view), in: view)
		}

		UIView.animate(withDuration: 0.1, animations: {
			touchImgView.alpha = 0.0
			touchImgView.transform = CGAffineTransform(scaleX: 1.13, y: 1.13)
		}) { _ in
			touchImgView.removeFromSuperview()
			touchImgView.alpha = 1.0
			self.touchImageViewQueue.push(touchImgView)
			self.removeTouchImageView(for: touch)
		}
	}

	func showExpandingCircle(at position: CGPoint, in view: UIView) {
		let circleLayer = CAShapeLayer()
		let initialRadius = config.shortTapInitialCircleRadius
		let finalRadius = config.shortTapFinalCircleRadius
		circleLayer.position = CGPoint(x: position.x - initialRadius, y: position.y - initialRadius)

		let startPathRect = CGRect(x: 0, y: 0, width: initialRadius * 2, height: initialRadius * 2)
		let startPath = UIBezierPath(roundedRect: startPathRect, cornerRadius: initialRadius)

		let endPathOrigin = initialRadius - finalRadius
		let endPathRect = CGRect(x: endPathOrigin, y: endPathOrigin, width: finalRadius * 2, height: finalRadius * 2)
		let endPath = UIBezierPath(roundedRect: endPathRect, cornerRadius: finalRadius)

		circleLayer.path = startPath.cgPath
		circleLayer.fillColor = UIColor.clear.cgColor
		circleLayer.strokeColor = config.touchColor.cgColor
		circleLayer.lineWidth = 2.0
		view.layer.addSublayer(circleLayer)

		CATransaction.begin()
		CATransaction.setCompletionBlock {
			circleLayer.removeFromSuperlayer()
		}

		// Expanding animation
		let expandingAnimation = CABasicAnimation(keyPath: "path")
		expandingAnimation.fromValue = startPath.cgPath
		expandingAnimation.toValue = endPath.cgPath
		expandingAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
		expandingAnimation.duration = 0.4
		expandingAnimation.repeatCount = 1.0
		circleLayer.add(expandingAnimation, forKey: "expandingAnimation")
		circleLayer.path = endPath.cgPath

		// Delayed fade out animation
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
			let fadingOutAnimation = CABasicAnimation(keyPath: "opacity")
			fadingOutAnimation.fromValue = 1.0
			fadingOutAnimation.toValue = 0.0
			fadingOutAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
			fadingOutAnimation.duration = 0.15
			circleLayer.add(fadingOutAnimation, forKey: "fadeOutAnimation")
			circleLayer.opacity = 0.0
		}

		CATransaction.commit()
	}

	func touchImageView(for touch: UITouch) -> UIView? {
		touchImgViewsDict[String(format: "%p", touch)]
	}

	func setTouchImageView(_ touchImageView: UIView, for touch: UITouch) {
		touchImgViewsDict[String(format: "%p", touch)] = touchImageView
	}

	func removeTouchImageView(for touch: UITouch) {
		touchImgViewsDict.removeValue(forKey: String(format: "%p", touch))
	}
}

class GSTouchImageViewQueue {
	var backingArray = [UIView]()

	convenience init(touchesCount: Int, config: ShowTouchesConfig) {
		self.init()

		for _ in 0 ..< touchesCount {
			let imageView = UIView(frame: CGRect(x: 0, y: 0, width: config.circleSize, height: config.circleSize))
			imageView.backgroundColor = config.touchColor
			imageView.layer.cornerRadius = config.circleSize / 2
			backingArray.append(imageView)
		}
	}

	func popTouchImageView() -> UIView {
		backingArray.removeFirst()
	}

	func push(_ touchImageView: UIView) {
		backingArray.append(touchImageView)
	}
}
