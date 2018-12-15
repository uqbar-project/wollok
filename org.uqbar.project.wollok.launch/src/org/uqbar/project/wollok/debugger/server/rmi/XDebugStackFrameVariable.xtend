package org.uqbar.project.wollok.debugger.server.rmi

import java.io.Serializable
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static org.uqbar.project.wollok.sdk.WollokDSK.*

/**
 * A variable within a stack execution.
 * 
 * @author jfernandes
 */
@Accessors
class XDebugStackFrameVariable implements Serializable {
	WVariable variable
	XDebugValue value

	new(WVariable variable, WollokObject value) {
		this.variable = variable
		this.value = if(value === null) null else value.asRemoteValue
	}

	def asRemoteValue(WollokObject object) {
		if (object.hasNativeType(LIST))
			new XWollokListDebugValue(object, LIST)
		else if (object.hasNativeType(SET))
			new XWollokSetDebugValue(object, SET)
		else if (object.hasNativeType(DICTIONARY))
			new XWollokDictionaryDebugValue(object, DICTIONARY)
		else
			new XWollokObjectDebugValue(variable.name, object)
	}

	override equals(Object obj) {
		try {
			val other = obj as XDebugStackFrameVariable
			return other.variable.toString.equals(variable.toString)
		} catch (ClassCastException e) {
			return false
		}
	}

	override hashCode() {
		this.variable.toString.hashCode
	}

	override toString() {
		val valueToString = if (this.value === null) "null" else this.value.toString
		this.variable.toString + " = " + valueToString
	}

	def void collectValues(Map<String, XDebugStackFrameVariable> variableValues) {
		if (this.value !== null) {
			variableValues.put(this.variable.id.toString, this)
			this.value.variables.forEach [ variable | variable.collectValues(variableValues) ]
		}
	}
	
}
