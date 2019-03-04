package org.uqbar.project.wollok.interpreter.api

import org.eclipse.emf.ecore.EObject

/**
 * 
 * New interface (previous embedded in XDebugger) - its intention is to decouple
 * interpreter listeners and debuggers itself
 * 
 */
interface XInterpreterListener {
	
	/** Program execution started */
	def void started()
	
	/** Program execution terminated */
	def void terminated()
	
	/**
	 * Notifies it's about to evaluate a given element.
	 * Allows the debugger to pause the thread.
	 */
	def void aboutToEvaluate(EObject element)

	/** Already evaluated element */	
	def void evaluated(EObject element)
	
}