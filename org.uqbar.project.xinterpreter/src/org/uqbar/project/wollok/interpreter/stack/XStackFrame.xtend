package org.uqbar.project.wollok.interpreter.stack

import java.io.Serializable
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.context.EvaluationContext

import static extension org.uqbar.project.xtext.utils.SourceCodeExtensions.*

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
class XStackFrame<T> implements Serializable, Cloneable {

	SourceCodeLocation currentLocation
	EvaluationContext<T> context
	SourceCodeLocator sl
	
	new(EObject object, EvaluationContext<T> context, extension SourceCodeLocator sl) {
		this.sl = sl
		this.context = context
		this.defineCurrentLocation(object)
	}
	
	def void defineCurrentLocation(EObject object) {
		currentLocation = object.toSourceCodeLocation(sl)
	}
	
	override toString() '''«context» («currentLocation»)'''
	
	override XStackFrame<T> clone() {
		super.clone as XStackFrame<T>
	}
	
	def showableInStackTrace() {
		context.showableInStackTrace
	}
	
}