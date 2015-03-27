package org.uqbar.project.wollok.interpreter

import java.util.Stack
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WFeatureCall

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * Superclass for all exceptions that the wollok interpreter can throw while evaluating a program.
 */
class WollokRuntimeException extends RuntimeException {
	new(String message) {
		super(message)
	}	
}

class UnresolvableReference extends WollokRuntimeException {
	new(String message) {
		super(message)
	}
}

class MessageNotUnderstood extends WollokRuntimeException {
	// Esto es previo a tener la infraestructura de debugging
	// probablemente seria bueno unificar el manejo de errores con eso
	var Stack<WFeatureCall> wollokStack = new Stack
	
	new(String message) {
		super(message)
	}
	
	def pushStack(WFeatureCall call) { wollokStack.push(call) }
	
	override getMessage() '''«super.getMessage()»
		«FOR m : wollokStack»
		«(m as WExpression).method?.declaringContext?.contextName».«(m as WExpression).method?.name»():«NodeModelUtils.findActualNodeFor(m).textRegionWithLineInformation.lineNumber»
		«ENDFOR»
	'''
	
	def getInternalMessage(){
		super.message
	}
}

class IllegalBinaryOperation extends WollokRuntimeException {
	new(String message) {
		super(message)
	}
}

class AssertionFailed extends WollokRuntimeException {
	new(String message) {
		super(message)
	}
}