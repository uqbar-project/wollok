package org.uqbar.project.wollok.interpreter.api

import org.eclipse.emf.ecore.EObject

/**
 * Interface all interpreters must implement in order to
 * be used by the debugger mechanism
 * 
 * @author jfernandes
 */
interface XInterpreter<E extends EObject> {

	def XThread getCurrentThread()
	
	// TODO: return value should be WollokObject
	def Object interpret(E program)
	def Object interpret(E program, Boolean propagatingErrors)
	
}