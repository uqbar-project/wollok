package org.uqbar.vainilla.components.behavior

/**
 * A component to which one could attach new Behaviors
 * or remove them.
 * 
 * @author jfernandes
 */
interface DynamicBehavior {
	
	def void addBehavior(Behavior b)
	def void removeBehavior(Behavior b)
	def Iterable<Behavior> getBehaviors()
	
}