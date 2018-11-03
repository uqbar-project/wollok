package org.uqbar.project.wollok.interpreter.listeners

import java.util.List
import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Client
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.contextState.server.XContextStateListener
import org.uqbar.project.wollok.debugger.server.rmi.XDebugValue
import org.uqbar.project.wollok.debugger.server.rmi.XWollokObjectDebugValue
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.api.XInterpreterListener
import org.uqbar.project.wollok.interpreter.core.WollokObject

class WollokRemoteContextStateListener implements XInterpreterListener {
	
	WollokInterpreter interpreter
	Client client
	CallHandler callHandler = new CallHandler
	XContextStateListener contextStateListener

	new(WollokInterpreter interpreter, int requestPort) {
		this.interpreter = interpreter
		println("requestPort ===> " + requestPort)
		this.client = new Client("localhost", requestPort, callHandler)
		this.contextStateListener = client.getGlobal(XContextStateListener) as XContextStateListener
	}
	
	// We don't care
	override started() { }
	
	override terminated() { }
	
	override aboutToEvaluate(EObject element) {}
	
	override evaluated(EObject element) {
		println("evaluó " + element)
		val List<XDebugValue> variables = newArrayList
		//variables.add(new XWollokObjectDebugValue("pepita", new WollokObject(interpreter, null)))
		println("variables " + variables)
		contextStateListener.stateChanged(variables)
	}
	
}
