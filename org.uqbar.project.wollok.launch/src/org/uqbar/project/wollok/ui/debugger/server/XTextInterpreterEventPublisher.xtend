package org.uqbar.project.wollok.ui.debugger.server

/**
 * An object that your interpreter will have in order to publish events.
 * It's an abstraction to communicate with the debugger/UI
 * 
 * @author jfernandes
 */
// probably this will become a remote interface
interface XTextInterpreterEventPublisher {
	
	def void started()
	def void terminated()
	
	def void suspendStep()
	def void resumeStep()

	// BP's	
	def void breakpointHit(String fileName, int lineNumber)
	
}