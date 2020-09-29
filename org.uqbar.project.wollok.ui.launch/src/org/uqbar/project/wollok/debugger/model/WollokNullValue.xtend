package org.uqbar.project.wollok.debugger.model

import org.eclipse.debug.core.DebugException
import org.eclipse.debug.core.model.IValue
import org.uqbar.project.wollok.debugger.WollokDebugTarget

class WollokNullValue extends WollokValue implements IValue {
	
	new(WollokDebugTarget target) {
		super(target, null)
	}
	
	override getValueString() throws DebugException {
		 "null"
	}
	
}