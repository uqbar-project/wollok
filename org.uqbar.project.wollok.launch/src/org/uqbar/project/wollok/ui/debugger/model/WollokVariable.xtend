package org.uqbar.project.wollok.ui.debugger.model

import org.eclipse.debug.core.model.IValue
import org.eclipse.debug.core.model.IVariable
import org.uqbar.project.wollok.ui.debugger.WollokDebugTarget
import org.uqbar.project.wollok.ui.debugger.server.rmi.XDebugStackFrameVariable
import org.uqbar.project.wollok.ui.debugger.server.rmi.XDebugValue
import org.uqbar.project.wollok.ui.debugger.server.rmi.XWollokListDebugValue
import org.uqbar.project.wollok.ui.debugger.server.rmi.XWollokObjectDebugValue

/**
 * 
 * @author jfernandes
 */
class WollokVariable extends WollokDebugElement implements IVariable {
	XDebugStackFrameVariable adaptee
	IValue value
	
	new(WollokDebugTarget target, XDebugStackFrameVariable adaptee) {
		super(target)
		this.adaptee = adaptee
		value = if (adaptee.value == null) null else adaptee.value.toEclipseValue
	}
	
	def dispatch toEclipseValue(XWollokObjectDebugValue value) { new WollokObjectValue	(target, value) }
	def dispatch toEclipseValue(XWollokListDebugValue value) { new WollokObjectValue(target, value) }
	def dispatch toEclipseValue(XDebugValue value) { new WollokValue(target, value.stringValue) }
	
	override getName() { adaptee.variable.name }
	override getValue() { value }
	// TYPE SYSTEM (?)
	override getReferenceTypeName() { "Any" }

	// *******************************
	// ** UNIMPLEMENTED methods
	// *******************************
	
	override hasValueChanged() { false }
	override setValue(String expression) { throw new UnsupportedOperationException("Not implemented yet") }
	override setValue(IValue value) { throw new UnsupportedOperationException("Not implemented") }
	override supportsValueModification() { false }
	override verifyValue(String expression) { false }
	override verifyValue(IValue value) { false }
	
	def getIcon() {
		// eventually all variables will know their custom icons
		if (adaptee.value instanceof XWollokListDebugValue) 
			'icons/listVariableIcon.gif'
		else if (adaptee.variable.local)
			'icons/localvariable_obj.png'
		else
			null
	}
	
}