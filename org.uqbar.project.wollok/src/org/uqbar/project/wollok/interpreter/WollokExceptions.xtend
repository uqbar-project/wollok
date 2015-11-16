package org.uqbar.project.wollok.interpreter

import java.util.Stack
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WFeatureCall

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * Superclass for all exceptions that the wollok interpreter can throw while evaluating a program.
 * 
 * @author jfernandes
 */
class WollokRuntimeException extends RuntimeException {
	new(String message) {
		super(message)
	}	
	new(String message, Throwable t) {
		super(message, t)
	}
}

/**
 * @deprecated This must be modeled in wollok itself and it will be replaced by WollokProgramExceptionWrapper
 */
class UnresolvableReference extends WollokRuntimeException {
	new(String message) {
		super(message)
	}
}

/**
 * @deprecated This must be modeled in wollok itself and it will be replaced by WollokProgramExceptionWrapper
 */
class MessageNotUnderstood extends WollokRuntimeException {
	// Esto es previo a tener la infraestructura de debugging
	// probablemente seria bueno unificar el manejo de errores con eso
	var Stack<WFeatureCall> wollokStack = new Stack
	var String precalculatedMessage = null	
	
	new(String message) {
		super(message)
	}
	
	def pushStack(WFeatureCall call) { wollokStack.push(call) }
	
	override getMessage(){
		if(precalculatedMessage == null){
			precalculatedMessage = this.calculateMessage().toString
			wollokStack = null
		}
		
		return precalculatedMessage
	}
	
	def calculateMessage() '''«super.getMessage()»
		«FOR m : wollokStack»
		«(m as WExpression).method?.declaringContext?.contextName».«(m as WExpression).method?.name»():«NodeModelUtils.findActualNodeFor(m).textRegionWithLineInformation.lineNumber»
		«ENDFOR»
	'''
	
	def getInternalMessage(){
		super.message
	}

	/* This method is only intended to be used when the exception is going to be sent to the UI. Because Wollok AST nodes are not serializable :( */	
	def prepareForSerialization(){
		if(precalculatedMessage == null){
			precalculatedMessage = this.calculateMessage.toString
			wollokStack = null;
		}
	}
}

class IllegalBinaryOperation extends WollokRuntimeException {
	new(String message) {
		super(message)
	}
}
