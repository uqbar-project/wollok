package org.uqbar.project.wollok.interpreter.stack

import org.eclipse.emf.ecore.EObject

/**
 * A strategy that knows how to translate from an EObject
 * to a sourcecode location string used for the stack trace.
 * 
 * This is custom per language
 * 
 * @author jfernandes
 */
interface SourceCodeLocator {
	
	def String contextDescription(EObject o)
	
}