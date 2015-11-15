package org.uqbar.project.wollok.debugger.server.rmi

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static org.uqbar.project.wollok.sdk.WollokDSK.*

import static extension java.lang.System.*
import static extension org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrame.debugVariables
import static extension org.uqbar.project.wollok.interpreter.core.ToStringBuilder.shortLabel
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.uqbar.project.wollok.sdk.WollokDSK
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper

/**
 * A stack frame variable's value that holds a wollok
 * comple object.
 * Meaning that it can have inner variables.
 * 
 * @author jfernandes
 */
class XWollokObjectDebugValue extends XDebugValue {
	String typeName
	String varName
	// debería ser lazy
	@Accessors List<XDebugStackFrameVariable> variables = newArrayList

	new(String varName, WollokObject obj) {
		super(obj.description)
		this.typeName = obj.behavior.fqn
		this.varName = varName
		variables = obj.debugVariables
	}
	
	def static description(WollokObject obj) {
		val fqn = obj.behavior.fqn
		println("Creating FQN for " + obj)
		if (fqn == Integer || fqn == DOUBLE)
			((obj.call("toString") as WollokObject).getNativeObject(WollokDSK.STRING) as JavaWrapper<String>).wrapped
		else
			obj.shortLabel + " (id=" + obj.identityHashCode + ")"
	}
	
	def isList() { typeName == LIST }
	def isSet() { typeName == SET }
	def isCollection() { isList || isSet }
	def isInteger() { typeName == INTEGER }
	def isDouble() { typeName == DOUBLE }
	def isString() { typeName == STRING }
	def isBoolean() { typeName == BOOLEAN }

}