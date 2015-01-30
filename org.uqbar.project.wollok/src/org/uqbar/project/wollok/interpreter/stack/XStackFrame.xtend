package org.uqbar.project.wollok.interpreter.stack

import java.io.Serializable
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.context.EvaluationContext

import static extension org.uqbar.project.wollok.utils.XTextExtensions.*

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
class XStackFrame implements Serializable {
	@Property SourceCodeLocation currentLocation
	@Property EvaluationContext context
	
	new(EObject currentLocation, EvaluationContext context) {
		this.currentLocation = currentLocation.toSourceCodeLocation
		this.context = context
	}
	
	def void defineCurrentLocation(EObject object) {
		currentLocation = object.toSourceCodeLocation
	}
	
}