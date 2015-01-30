package org.uqbar.wollok.rpg.components

import com.uqbar.vainilla.appearances.Invisible
import com.uqbar.vainilla.appearances.Label
import java.awt.Color
import java.awt.Font
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.vainilla.components.behavior.ChangesAppearenceMoving
import org.uqbar.vainilla.components.behavior.FeedbackPropertyChanges
import org.uqbar.vainilla.components.behavior.MovesWithKeyboard
import org.uqbar.vainilla.components.behavior.StayOnScreenBehavior
import org.uqbar.vainilla.components.behavior.TimeBoxed
import org.uqbar.vainilla.components.collision.Collidable
import org.uqbar.wollok.rpg.WollokMovingGameComponent

/**
 * @author jfernandes
 */
class Coronel extends WollokMovingGameComponent implements Collidable {
	
	new(WollokObject model) {
		super(new Invisible, 30, 30, 1, 1, 0)
		this.model = model
		addBehavior(new MovesWithKeyboard)
		addBehavior(new ChangesAppearenceMoving("coronel_tiles.png", 38, 57, 0.3))
		addBehavior(new StayOnScreenBehavior)
		addBehavior(new FeedbackPropertyChanges(model))
		addBehavior(new SendMessageOnCollision)
	}

	override collidesWith(Collidable other) {
	}
	
	override mouseButtonPressed() {
		scene.addComponent(new WollokMovingGameComponent(new Label(new Font("SansSerif", Font.PLAIN, 18), Color.WHITE, model.toString)) => [
			alignTopTo(this.bottom + 5)
			// alignCenters
			alignCenterWith(this)
			addBehavior(new TimeBoxed(2300))
		])
	}

}