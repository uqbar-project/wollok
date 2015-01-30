package org.uqbar.vainilla.components.behavior

import com.uqbar.vainilla.DeltaState
import com.uqbar.vainilla.MovingGameComponent
import com.uqbar.vainilla.UnitVector2D
import com.uqbar.vainilla.events.constants.Key

/**
 * Moves the component along x and y axis based on keyboard hits.
 * right, left, up and down.
 * 
 * @author jfernandes
 */
class MovesWithKeyboard extends Behavior<MovingGameComponent> {
	@Property var Key upKey = Key.UP
	@Property var Key downKey = Key.DOWN
	@Property var Key leftKey = Key.LEFT
	@Property var Key rightKey = Key.RIGHT
	
	def getMaxSpeed() { 250 }
	
	override update(DeltaState s) {
		val xV = xVector(s)
		val yV = yVector(s)
		if (xV == 0 && yV == 0)
			component.speed = 0
		else {
			component.UVector.set(xV, yV)
        	component.speed = maxSpeed
       	}
    }
	
	def yVector(DeltaState s) {
		if (s.isKeyBeingHold(upKey)) -1
        else if (s.isKeyBeingHold(downKey)) 1
        else 0
	}
	
	def xVector(DeltaState s) {
		if (s.isKeyBeingHold(leftKey)) -1
        else if(s.isKeyBeingHold(rightKey)) 1
        else 0
	}
    
    def isZero(UnitVector2D v) { v.x == 0 && v.y == 0}
	
}