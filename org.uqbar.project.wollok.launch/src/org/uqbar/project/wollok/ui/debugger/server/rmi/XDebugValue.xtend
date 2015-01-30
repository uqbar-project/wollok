package org.uqbar.project.wollok.ui.debugger.server.rmi

import java.io.Serializable
import java.util.List

/**
 * @author jfernandes
 */
class XDebugValue implements Serializable {
	@Property String stringValue
	
	new(String stringValue) {
		this.stringValue = stringValue
	}
	
	def List<XDebugStackFrameVariable> getVariables() { #[] }
	
}