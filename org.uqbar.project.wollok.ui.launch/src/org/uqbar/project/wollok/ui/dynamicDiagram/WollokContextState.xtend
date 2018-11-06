package org.uqbar.project.wollok.ui.dynamicDiagram

import java.util.List
import org.uqbar.project.wollok.contextState.server.XContextStateListener
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrameVariable

class WollokContextState implements XContextStateListener {
	
	override stateChanged(List<XDebugStackFrameVariable> variables) {
		println("Thread " + Thread.currentThread)
		println("Cambió el estado. " + variables.size + " variables")
		variables.forEach [ variable |
			println('''variable «variable.variable.name» => «variable.value.stringValue»''')
		]
	}
	
}
