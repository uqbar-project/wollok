package org.uqbar.project.wollok.debugger.server.rmi

import java.io.Serializable
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static org.uqbar.project.wollok.sdk.WollokDSK.*

/**
 * A variable within a stack execution.
 * 
 * @author jfernandes
 */
class XDebugStackFrameVariable implements Serializable {
	@Accessors WVariable variable
	@Accessors XDebugValue value
		
	new(WVariable variable, WollokObject value) {
		this.variable = variable
		this.value = if (value == null) null else value.asRemoteValue
	}
	
	def asRemoteValue(WollokObject object) {
		if (object.hasNativeType(LIST) || object.hasNativeType(COLLECTION))
			 new XWollokListDebugValue(object)
		else
			new XWollokObjectDebugValue(variable.name, object)
	}
	
}