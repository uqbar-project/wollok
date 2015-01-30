package org.uqbar.vainilla.components.behavior

import com.uqbar.vainilla.DeltaState
import com.uqbar.vainilla.GameComponent

/**
 * 
 * @author jfernandes
 */
abstract class Behavior<C extends GameComponent> {
	protected var C component
	def void update(DeltaState s)
	
	def void attachedTo(C c) { component = c }
	def void removeFrom(C c) { 	component = null }
	
}