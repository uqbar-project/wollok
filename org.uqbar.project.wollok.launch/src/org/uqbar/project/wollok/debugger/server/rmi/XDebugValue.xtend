package org.uqbar.project.wollok.debugger.server.rmi

import java.io.Serializable
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * @author jfernandes
 * @author dodain       Added id
 */
@Accessors
abstract class XDebugValue implements Serializable {
	static val ArrayList<XDebugStackFrameVariable> EMPTY_LIST = newArrayList
	
	List<XDebugStackFrameVariable> variables = EMPTY_LIST
	String stringValue
	Integer id
	
	new(String stringValue, Integer id) {
		this.stringValue = stringValue
		this.id = id
	}
	
	override toString() {
		val variablesToString = if (variables.isEmpty) "" else " " + variables.map [ toString ].join(", ")
		(this.stringValue ?: "") + (if (id === null) "" else " (" + id + ")") + variablesToString
	}
	
	def String getTypeName()
	
	def boolean isWKO() { false }
}