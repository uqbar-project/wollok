package org.uqbar.project.wollok.interpreter.listeners

import java.util.List
import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Client
import org.uqbar.project.wollok.contextState.server.XContextStateListener
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrame
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrameVariable
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.api.XInterpreterListener
import org.eclipse.emf.ecore.EObject

class WollokRemoteContextStateListener implements XInterpreterListener {

	WollokInterpreter interpreter
	Client client
	CallHandler callHandler = new CallHandler
	XContextStateListener contextStateListener
	List<XDebugStackFrameVariable> currentVariables = newArrayList
	boolean firstTime = true
	boolean forRepl
	List<XDebugStackFrameVariable> variables

	new(WollokInterpreter interpreter, int requestPort, boolean forRepl) {
		this.forRepl = forRepl
		this.interpreter = interpreter
		this.client = new Client("localhost", requestPort, callHandler)
		this.contextStateListener = client.getGlobal(XContextStateListener) as XContextStateListener
	}

	// We don't care
	override started() {}

	override terminated() {
		if (forRepl) {
			detectChanges
		}
		variables.notifyPossibleStateChanged	
	}

	static def Throwable getRealCause(Throwable e) {
		if(e.cause === null) e else e.cause.realCause
	}

	override aboutToEvaluate(EObject element) {}

	override evaluated(EObject element) {
		if (!forRepl) {
			this.detectChanges
		}
	}

	def void detectChanges() {
		try {
			XDebugStackFrame.initAllVariables()
			this.variables = #[]
			val currentStack = interpreter.currentThread.stack
			if (!currentStack.isEmpty) {
				this.variables = new XDebugStackFrame(currentStack.peek).variables
			}
		} catch (Exception e) {
			val realCause = e.realCause
			println("ERROR: " + realCause.class.name + ", " + realCause.message)
			realCause.stackTrace.forEach [ ste |
				println('''«ste.methodName» («ste.fileName»:«ste.lineNumber»)''')
			]
		}
	}

	def void notifyPossibleStateChanged(List<XDebugStackFrameVariable> newVariables) {
		if (newVariables !== null && newVariables.stateChanged) {
			currentVariables = newVariables
			contextStateListener.stateChanged(currentVariables)
			firstTime = false
		}
	}

	def stateChanged(List<XDebugStackFrameVariable> newVariables) {
		firstTime || !currentVariables.map[toString].equals(newVariables.map[toString])
	}

}
