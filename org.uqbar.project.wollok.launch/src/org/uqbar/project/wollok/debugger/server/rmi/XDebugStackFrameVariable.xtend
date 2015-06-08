package org.uqbar.project.wollok.debugger.server.rmi

import java.io.Serializable
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.collections.WollokList
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * A variable within a stack execution.
 * 
 * @author jfernandes
 */
class XDebugStackFrameVariable implements Serializable {
	@Accessors WVariable variable
	@Accessors XDebugValue value
		
	new(WVariable variable, Object value) {
		this.variable = variable
		this.value = if (value == null) null else value.asRemoteValue
	}
	
	def dispatch asRemoteValue(WollokObject object) { new XWollokObjectDebugValue(variable.name, object) }
	def dispatch asRemoteValue(WollokList list) { new XWollokListDebugValue(list) }
	def dispatch asRemoteValue(Object o) { new XDebugValue(o.toString) }
	
}