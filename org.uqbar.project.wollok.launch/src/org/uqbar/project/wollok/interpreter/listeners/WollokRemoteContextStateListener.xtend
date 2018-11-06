package org.uqbar.project.wollok.interpreter.listeners

import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Client
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.contextState.server.XContextStateListener
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrame
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrameVariable
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.api.XInterpreterListener
import org.uqbar.project.wollok.interpreter.context.WVariable
import java.util.HashSet

class WollokRemoteContextStateListener implements XInterpreterListener {
	
	WollokInterpreter interpreter
	Client client
	CallHandler callHandler = new CallHandler
	XContextStateListener contextStateListener

	new(WollokInterpreter interpreter, int requestPort) {
		this.interpreter = interpreter
		this.client = new Client("localhost", requestPort, callHandler)
		this.contextStateListener = client.getGlobal(XContextStateListener) as XContextStateListener
	}
	
	// We don't care
	override started() { }
	
	override terminated() { }
	
	override aboutToEvaluate(EObject element) {}
	
	override evaluated(EObject element) {
		val variables = interpreter.currentThread.stack.map [
			new XDebugStackFrame(it).variables
		].flatten.toList
		
		val setVariables = new HashSet
		setVariables.addAll(variables)
		contextStateListener.stateChanged(setVariables.toList)
	}
	
}
