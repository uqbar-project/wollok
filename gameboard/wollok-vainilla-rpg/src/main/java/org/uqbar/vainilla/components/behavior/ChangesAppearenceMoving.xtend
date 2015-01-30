package org.uqbar.vainilla.components.behavior

import com.uqbar.vainilla.DeltaState
import com.uqbar.vainilla.appearances.Animation
import com.uqbar.vainilla.events.constants.Key
import resource.Resource

import static org.uqbar.vainilla.components.behavior.VainillaExtensions.*

/**
 * Changes the component's appearence while it is moving.
 * It uses differente animation for each direction (up, down, left, right).
 * 
 * All animation are parsed from a single image file (a tileset)
 * 
 * @author jfernandes
 */
class ChangesAppearenceMoving extends Behavior {
	Animation downAnimation
	Animation leftAnimation
	Animation rightAnimation
	Animation upAnimation
	
	new(String tilesFileName, int tileWidth, int tileHeight, double meanTime) {
		val tiles = Resource.getSprite(tilesFileName)
		downAnimation = 	parseAnimation(tiles, 0 * tileHeight, tileWidth, tileHeight, meanTime)
		leftAnimation = 	parseAnimation(tiles, 1 * tileHeight, tileWidth, tileHeight, meanTime)
		rightAnimation = 	parseAnimation(tiles, 2 * tileHeight, tileWidth, tileHeight, meanTime)
		upAnimation = 		parseAnimation(tiles, 3 * tileHeight, tileWidth, tileHeight, meanTime)		
	}
	
	override update(DeltaState s) {
		if (s.isKeyBeingHold(Key.UP))
			movingUp
		else if (s.isKeyBeingHold(Key.DOWN))
			movingDown
		else if (s.isKeyBeingHold(Key.RIGHT))
			movingRight
		else if (s.isKeyBeingHold(Key.LEFT))
			movingLeft
		else
			idle
	}
	
	def movingDown() { component.appearance = downAnimation }
	def movingLeft() { component.appearance = leftAnimation }
	def movingRight() { component.appearance = rightAnimation }
	def movingUp() { component.appearance = upAnimation }
	def idle() { component.appearance = downAnimation.sprites.get(0) }
	
}