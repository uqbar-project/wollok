package org.uqbar.vainilla.components.behavior

import com.uqbar.vainilla.DeltaState
import com.uqbar.vainilla.GameComponent

/**
 * Makes the component live just for the given amount of time.
 * Then it will destroy it.
 * 
 * @author jfernandes
 */
class TimeBoxed extends Behavior {
	long attachedTime
	long lifeSpanInMillis
	
	new(long lifeSpanInMillis) {
		this.lifeSpanInMillis = lifeSpanInMillis
	}
	
	override attachedTo(GameComponent c) {
		super.attachedTo(c)
		attachedTime = System.currentTimeMillis	
	}
	
	override update(DeltaState s) {
		if  (System.currentTimeMillis >= attachedTime + lifeSpanInMillis)
			component.destroy
	}
	
}