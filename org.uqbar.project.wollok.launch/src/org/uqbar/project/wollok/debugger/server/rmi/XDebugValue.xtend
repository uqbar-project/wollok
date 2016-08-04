package org.uqbar.project.wollok.debugger.server.rmi

import java.io.Serializable
import java.util.ArrayList
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * @author jfernandes
 */
class XDebugValue implements Serializable {
	static val ArrayList<XDebugStackFrameVariable> EMPTY_LIST = newArrayList
	@Accessors String stringValue
	
	new(String stringValue) {
		this.stringValue = stringValue
	}
	
	def ArrayList<XDebugStackFrameVariable> getVariables() { EMPTY_LIST }
	
}