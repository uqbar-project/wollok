package org.uqbar.wollok.rpg.components

import com.uqbar.vainilla.GameComponent
import org.uqbar.wollok.rpg.WollokMovingGameComponent
import com.uqbar.vainilla.DeltaState
import com.uqbar.vainilla.appearances.Label
import java.awt.Font
import java.awt.Color
import org.uqbar.vainilla.components.behavior.TimeBoxed

/**
 * 
 * @author jfernandes
 */
class PropertyChanged extends WollokMovingGameComponent {
	
	new(GameComponent component, String fieldName, Object oldValue, Object newValue) {
		super(createAppearance(component, fieldName, newValue), component.x, component.y, 1, 1, 0)
		alignHorizontalCenterTo(component.x + component.width / 2)
	}
	
	def static createAppearance(GameComponent component, String fieldName, Object newValue) {
		new Label(new Font("SansSerif", Font.PLAIN, 18), Color.YELLOW, fieldName + " = " + newValue, true)
	}
	
	override protected nowOnScene() {
		super.nowOnScene()
		addBehavior(new TimeBoxed(2200))
	}
	
	override Label getAppearance() {
		super.getAppearance() as Label	
	}
	
	override update(DeltaState deltaState) {
		super.update(deltaState)
		y = y - 1
		appearance.color = appearance.color.alpha(-3) 
	}
	
	def alpha(Color color, int alphaDelta) {
		 new Color(color.red, color.green, color.blue, Math.max(0, color.alpha + alphaDelta))
	}
	
}