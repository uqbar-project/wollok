package org.uqbar.project.wollok.ui.objectDiagram

import org.uqbar.project.wollok.contextState.server.XContextStateListener
import java.util.List
import org.uqbar.project.wollok.debugger.server.rmi.XDebugValue

class WollokContextState implements XContextStateListener {
	
	override stateChanged(List<XDebugValue> variables) {
		println("Re - cambió el estado")
	}
	
}
