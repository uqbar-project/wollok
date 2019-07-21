package org.uqbar.project.wollok.debugger.model

import org.eclipse.debug.core.DebugException
import org.eclipse.debug.core.model.IVariable
import org.uqbar.project.wollok.debugger.WollokDebugTarget
import org.uqbar.project.wollok.debugger.server.rmi.XDebugValue

/**
 * 
 * @author jfernandes
 */
class WollokObjectValue extends WollokValue {
	IVariable[] variables = #[]
	String typeName
	
	new(WollokDebugTarget target, XDebugValue adaptee) {
		super(target, adaptee.stringValue)
		this.typeName = adaptee.typeName
		variables = adaptee.variables.map[WollokStackFrame.toEclipseVariable(it, target)]
	}
	
	override hasVariables() throws DebugException { !variables.empty }
	override getVariables() throws DebugException { variables }
	override getReferenceTypeName() { typeName }
	
}