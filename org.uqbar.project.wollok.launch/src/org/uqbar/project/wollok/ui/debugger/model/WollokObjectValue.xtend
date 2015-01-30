package org.uqbar.project.wollok.ui.debugger.model

import org.eclipse.debug.core.DebugException
import org.eclipse.debug.core.model.IVariable
import org.uqbar.project.wollok.ui.debugger.WollokDebugTarget
import org.uqbar.project.wollok.ui.debugger.server.rmi.XDebugValue

/**
 * 
 * @author jfernandes
 */
class WollokObjectValue extends WollokValue {
	IVariable[] variables = #[]
	
	new(WollokDebugTarget target, XDebugValue adaptee) {
		super(target, adaptee.stringValue)
		variables = adaptee.variables.map[WollokStackFrame.toEclipseVariable(it, target)]
	}
	
	override hasVariables() throws DebugException { !variables.empty }
	override getVariables() throws DebugException { variables }
	
}