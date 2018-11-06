package org.uqbar.project.wollok.contextState.server

import java.util.List
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrameVariable

/**
 * Listens to the state of a certain context of execution 
 */
interface XContextStateListener {
	
	def void stateChanged(List<XDebugStackFrameVariable> variables)
	
}
