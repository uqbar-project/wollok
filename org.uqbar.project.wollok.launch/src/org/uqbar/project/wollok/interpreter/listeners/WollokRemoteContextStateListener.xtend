package org.uqbar.project.wollok.interpreter.listeners

import java.util.HashSet
import java.util.List
import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Client
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.contextState.server.XContextStateListener
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrame
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrameVariable
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.api.XInterpreterListener

class WollokRemoteContextStateListener implements XInterpreterListener {

	WollokInterpreter interpreter
	Client client
	CallHandler callHandler = new CallHandler
	XContextStateListener contextStateListener
	List<XDebugStackFrameVariable> currentVariables = newArrayList

	new(WollokInterpreter interpreter, int requestPort) {
		this.interpreter = interpreter
		this.client = new Client("localhost", requestPort, callHandler)
		this.contextStateListener = client.getGlobal(XContextStateListener) as XContextStateListener
	}

	// We don't care
	override started() {}

	override terminated() {
		/*
		 * Previous definition
		val variables = interpreter.currentThread.stack.map [
			val vars = new XDebugStackFrame(it).variables 
			vars
		].flatten.toList
		 */
		
		XDebugStackFrame.initAllVariables()
		val variables = new XDebugStackFrame(interpreter.currentThread.stack.peek).variables
		val setVariables = new HashSet
		setVariables.addAll(variables)
		setVariables.toList.notifyPossibleStateChanged
	}

	override aboutToEvaluate(EObject element) {}

	override evaluated(EObject element) {}

	def void notifyPossibleStateChanged(List<XDebugStackFrameVariable> newVariables) {
		if (newVariables.stateChanged) {
			currentVariables = newVariables
			contextStateListener.stateChanged(currentVariables)
		}
	}
	
	def stateChanged(List<XDebugStackFrameVariable> newVariables) {
		!currentVariables.map [ toString ].equals(newVariables.map [ toString ])
	}
	
}
