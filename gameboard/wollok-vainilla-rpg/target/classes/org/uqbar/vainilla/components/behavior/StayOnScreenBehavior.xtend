package org.uqbar.vainilla.components.behavior

import com.uqbar.vainilla.DeltaState

/**
 * Makes the component stay on screen by forcing the coordinates
 * to the maximum available for the display.
 * 
 * @author jfernandes
 */
class StayOnScreenBehavior extends Behavior {
	
	override update(DeltaState s) {
		if (component.x + component.width > component.game.displayWidth)
			component.x = component.game.displayWidth - component.width
		else if (component.x < 0)
			component.x = 0
		
		if (component.y + component.height > component.game.displayHeight)
			component.y = component.game.displayHeight - component.height
		else if (component.y < 0)
			component.y = 0
	}
	
}