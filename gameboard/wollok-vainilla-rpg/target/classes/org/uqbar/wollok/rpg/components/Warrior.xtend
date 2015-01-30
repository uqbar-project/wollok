package org.uqbar.wollok.rpg.components

import com.uqbar.vainilla.DeltaState
import com.uqbar.vainilla.events.constants.Key
import org.uqbar.vainilla.components.behavior.MovesWithKeyboard
import org.uqbar.vainilla.components.behavior.StayOnScreenBehavior
import org.uqbar.wollok.rpg.WollokMovingGameComponent
import resource.Resource

/**
 * 
 * @author jfernandes
 */
class Warrior extends WollokMovingGameComponent {
	
	new() {
		super(Resource.getSprite("warrior.png"), 0, 0, 1, 1, 0)
		addBehavior(new MovesWithKeyboard => [
			upKey = Key.W
			downKey = Key.S
			leftKey = Key.A
			rightKey = Key.D  
		])
		addBehavior(new StayOnScreenBehavior)
	}
	
	override update(DeltaState deltaState) {
        super.update(deltaState);
	}
	
}