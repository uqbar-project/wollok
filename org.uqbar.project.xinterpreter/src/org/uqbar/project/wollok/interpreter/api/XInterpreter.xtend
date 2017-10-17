package org.uqbar.project.wollok.interpreter.api

import org.eclipse.emf.ecore.EObject

/**
 * Interface all interpreters must implement in order to
 * be used by the debugger mechanism
 * 
 * @author jfernandes
 */
interface XInterpreter<E extends EObject, T> {

	def XThread getCurrentThread()
	
	// TODO: return value should be WollokObject
	def T interpret(E program)
	def T interpret(E program, Boolean propagatingErrors)
	
}