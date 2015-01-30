package org.uqbar.wollok.rpg

import com.uqbar.vainilla.DeltaState
import com.uqbar.vainilla.MovingGameComponent
import com.uqbar.vainilla.appearances.Appearance
import com.uqbar.vainilla.appearances.Invisible
import com.uqbar.vainilla.events.constants.MouseButton
import java.util.List
import org.eclipse.xtend.lib.Property
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.vainilla.components.behavior.Behavior
import org.uqbar.vainilla.components.behavior.DynamicBehavior
import org.uqbar.wollok.rpg.scenes.WollokRPGScene

import static extension org.uqbar.vainilla.components.behavior.VainillaExtensions.*

/**
 * 
 * @author jfernandes
 */
class WollokMovingGameComponent extends MovingGameComponent<WollokRPGScene> implements DynamicBehavior, WollokObjectView {
	@Property WollokObject model
	List<Behavior> behaviors = newArrayList
	
	new() {
		super(new Invisible, 0, 0, 1, 1, 0)
	}
	
	new(Appearance appearance) {
		super(appearance, 0, 0, 1, 1, 0)
	}
	
	new(Appearance appearance, double xPos, double yPos, int i, int i1, int i2) {
        super(appearance, xPos, yPos, i, i1, i2)
    }

    override addBehavior(Behavior b) {
		behaviors.add(b)
		b.attachedTo(this)
	}

	override removeBehavior(Behavior b) {
		behaviors.remove(b)
		b.removeFrom(this)
	}
	override getBehaviors() { behaviors }
	
	// **************************
	// ** coordinates helpers
	// **************************
	
	def bottom() { y + height }
	def top() { y }
	def left() { x }
	def rigth() { x + width }
	def horizontalCenter() { x + width / 2 }
	def verticalCenter() { y + height / 2 }
	
	def alignCenterWith(WollokMovingGameComponent other) {
		x = other.horizontalCenter - (width / 2)
	}
	
	// **************************
	// ** update
	// **************************

	override update(DeltaState deltaState) {
    	super.update(deltaState)
    	behaviors.forEach[update(deltaState)]
    	
    	if (mousePressedOnThis(deltaState))
			mouseButtonPressed    		
    }
				
	def mousePressedOnThis(DeltaState d) {
		d.isMouseButtonPressed(MouseButton.LEFT) 
		&& this.rect.contains(d.currentMousePosition)
	}
	
	// **************************
	// ** mouse events
	// **************************

   	// aca habría mas métodos onda mouseLeftButtonPRessed, rightButtonPressed, mouseOverIn, mouseOverOut 	
	def void mouseButtonPressed() {}

}