package org.uqbar.project.wollok.interpreter.stack

import java.io.Serializable
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.context.EvaluationContext

import static extension org.uqbar.project.xtext.utils.XTextExtensions.*
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * Represents a stack execution element.
 * 
 * Eventually once we refactor the interpreter to avoid using
 * java objects and to use native wrappers and therefore to
 * work 100% with WCallable's then there should be just one
 * implementation of this interface, purely based on the current
 * EObject as the context.
 * 
 * @author jfernandes
 */
@Accessors
class XStackFrame implements Serializable, Cloneable {
	SourceCodeLocation currentLocation
	EvaluationContext context
	SourceCodeLocator sl
	
	new(EObject currentLocation, EvaluationContext context, extension SourceCodeLocator sl) {
		this.sl = sl
		this.currentLocation = currentLocation.toSourceCodeLocation(sl)
		this.context = context
	}
	
	def void defineCurrentLocation(EObject object) {
		currentLocation = object.toSourceCodeLocation(sl)
	}
	
	override toString() '''«context» («currentLocation»)'''
	
	override XStackFrame clone() {
		super.clone as XStackFrame
	}
	
}