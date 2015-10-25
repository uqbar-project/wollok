package wollok.lang

import org.uqbar.project.wollok.ui.utils.XTendUtilExtensions
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.ToStringBuilder

/**
 * Wollok Object class. It's the native part
 * 
 * @author jfernandes
 */
class WObject {
	val WollokObject obj
	
	new(WollokObject obj) {
		this.obj = obj
	}
	
	def identity() { System.identityHashCode(obj) }
	
	def randomBetween(int start, int end) { XTendUtilExtensions.randomBetween(start, end) }
	
	def className() { ToStringBuilder.objectDescription(obj.behavior) }
	
}