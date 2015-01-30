package org.uqbar.project.wollok.interpreter

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

/**
 * Main exceptions for WollokInterpreter, indicates
 * that something when wrong while executing (interpreting)
 * 
 * @author jfernandes
 */
class WollokInterpreterException extends RuntimeException {
	@Property EObject sourceElement
	
	new(EObject sourceElement) {
		this("", sourceElement)
	}
	
	new(String message, EObject sourceElement) {
		super(message + createMessage(sourceElement))
		this.sourceElement = sourceElement
	}
	
	new(EObject sourceElement, Throwable cause) {
		super(createMessage(sourceElement), cause)
		this.sourceElement = sourceElement
	}
	
	def static String createMessage(EObject object) {
		val node = NodeModelUtils.findActualNodeFor(object)
		'''Error evaluating line «object.eResource.URI»:[«node.textRegionWithLineInformation.lineNumber»]: «node.text.trim»'''
	}

}