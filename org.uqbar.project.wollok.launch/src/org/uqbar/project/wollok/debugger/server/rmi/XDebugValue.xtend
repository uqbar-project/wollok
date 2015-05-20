package org.uqbar.project.wollok.debugger.server.rmi

import java.io.Serializable
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * @author jfernandes
 */
class XDebugValue implements Serializable {
	@Accessors String stringValue
	
	new(String stringValue) {
		this.stringValue = stringValue
	}
	
	def List<XDebugStackFrameVariable> getVariables() { #[] }
	
}