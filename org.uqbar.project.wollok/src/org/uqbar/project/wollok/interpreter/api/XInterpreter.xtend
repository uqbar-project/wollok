package org.uqbar.project.wollok.interpreter.api

import java.util.Stack
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.stack.XStackFrame

/**
 * Interface all interpreters must implement in order to
 * be used by the debugger mechanism
 * 
 * @author jfernandes
 */
interface XInterpreter<E extends EObject> {

	def Stack<XStackFrame> getStack()
	
	def void interpret(E program)
	def void interpret(E program, Boolean propagatingErrors)
	
}