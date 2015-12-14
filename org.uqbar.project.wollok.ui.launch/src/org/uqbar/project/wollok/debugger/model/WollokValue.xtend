package org.uqbar.project.wollok.debugger.model

import org.eclipse.debug.core.DebugException
import org.eclipse.debug.core.model.IValue
import org.uqbar.project.wollok.debugger.WollokDebugTarget

/**
 * Dummy value impl
 * 
 * @author jfernandes
 */
class WollokValue extends WollokDebugElement implements IValue {
	String value
	
	new(WollokDebugTarget target, String value) {
		super(target)
		this.value = value
	}
	
	override getValueString() throws DebugException { value }
	
	// unimplemented
	
	override getReferenceTypeName() throws DebugException { "unknown" }
	
	override getVariables() throws DebugException { #[] }
	
	override hasVariables() throws DebugException { false }
	
	override isAllocated() throws DebugException { true }
	
}