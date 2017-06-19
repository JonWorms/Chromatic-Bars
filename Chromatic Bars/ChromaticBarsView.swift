//
//  ChromaticBarsView.swift
//  Chromatic Bars
//
//  Created by Jon Worms on 5/24/17.
//

import ScreenSaver



let barWidth: CGFloat = 4
let animationTime: TimeInterval = 1/10 // one tenth of a second





class ChromaticBarsView: ScreenSaverView {


	private var columns: [Column] = []
	
	private let mask: CALayer = CALayer() // columns are added here, their shapes will mask the gradients below
	
	private let gradient: CAGradientLayer = CAGradientLayer()   // colors
	private let bgGradient: CAGradientLayer = CAGradientLayer() // darkness
	

	override init?(frame: NSRect, isPreview: Bool) {
		super.init(frame: frame, isPreview: isPreview)
		
		animationTimeInterval = animationTime
		
		gradient.colors = [NSColor.red.cgColor,NSColor.yellow.cgColor,NSColor.green.cgColor, NSColor.blue.cgColor]
		gradient.frame = CGRect(origin: CGPoint.zero, size: frame.size)
		gradient.startPoint = CGPoint(x: 0, y: 0.5)
		gradient.endPoint = CGPoint(x: 1, y: 0.5)
		
		bgGradient.frame = gradient.frame
		bgGradient.colors = [NSColor.clear.cgColor, NSColor.black.cgColor]
		bgGradient.locations = [0.25]
		mask.frame = gradient.frame
		
		
		var x: CGFloat = 0
		while x < frame.width - 4 {
			let c = Column()
			c.frame = CGRect(x: x, y: 0, width: 4, height: frame.height)
			c.addCounter = arc4random_cg() % (frame.height * 0.25)
			columns.append(c)
			mask.addSublayer(c)
			x += 6
		}
		
		gradient.mask = mask
		layer = CALayer()
		layer?.backgroundColor = .black
		layer?.addSublayer(gradient)
		layer?.addSublayer(bgGradient)
		wantsLayer = true
	}
	
	
	override func animateOneFrame() {
		super.animateOneFrame()
		for c in columns {
			c.step()
		}
	}
	
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	
	
	
	///
	/// A CALayer that holds multiple CAShapeLayers and provides movement and generation code as the screensaver progresses
	///
	private class Column: CALayer {
		
		// some size constraints for the bars
		var minBarHeight: CGFloat { return bounds.height * 0.25 }
		var maxBarHeight: CGFloat {	return bounds.height * 0.5 }
		
		var bars: [CAShapeLayer] = []
		var addCounter: CGFloat = 0 // count down until a new bar is added
		var gap = false // used for vertical space between bars
		
		
		// move the bars, generate a new one, remove an old one
		func step() {
			var i = 0
			while i < bars.count {
				bars[i].position.y += 1
				if bars[i].position.y > bounds.height {			// if bar is offscreen
					bars.remove(at: i).removeFromSuperlayer()	// remove
				} else {
					i += 1										// move
				}
			}
			
			addCounter -= 1
			
			if addCounter <= 0 {
				// use the addCounter as the length of the new bar/gap
				addCounter = (arc4random_cg() % (maxBarHeight - minBarHeight)) + minBarHeight
				if !gap {
					let bar: CAShapeLayer = CAShapeLayer()
					bar.anchorPoint = CGPoint(x: 0, y: 0)
					bar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: addCounter)
					bar.path = CGPath(rect: bar.frame, transform: nil)
					bar.position.y = -addCounter
					bars.append(bar)
					addSublayer(bar)
				}
				gap = !gap
			}
		}
		
	}
	

}




// Some convenience functions:
func arc4random_cg() -> CGFloat {
	return CGFloat(arc4random())
}
func %(lhs: CGFloat, rhs: CGFloat) -> CGFloat {
	return CGFloat(fmodf(Float(lhs), Float(rhs)));
}


