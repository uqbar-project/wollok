package org.uqbar.project.wollok.ui.dynamicDiagram

import java.util.List
import org.uqbar.project.wollok.contextState.server.XContextStateListener
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrameVariable

// TODO: Volarla , es una clase Middle Man solamente que le habla al Diagrama Dinámico
class WollokContextStateListener implements XContextStateListener {
	
	List<XContextStateListener> allListeners = newArrayList
	
	def void addContextStateListener(XContextStateListener listener) {
		println("******************************")
		println("agrego listener " + listener)
		println("******************************")
		allListeners.add(listener)
	}
	
	override stateChanged(List<XDebugStackFrameVariable> variables) {
		println("==================================================")
		variables.forEach [ variable |
			println('''variable «variable.variable.name» => «variable.value.stringValue»''')
		]
		println("==================================================")
		allListeners.forEach [ listener | 
			listener.stateChanged(variables)
			//variables.stateChanged
		]
	}
	
}
