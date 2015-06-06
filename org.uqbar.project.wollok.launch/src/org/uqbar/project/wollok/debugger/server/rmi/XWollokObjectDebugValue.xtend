package org.uqbar.project.wollok.debugger.server.rmi

import java.util.List

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension java.lang.System.*
import static extension org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrame.debugVariables
import static extension org.uqbar.project.wollok.interpreter.core.ToStringBuilder.shortLabel

/**
 * A stack frame variable's value that holds a wollok
 * comple object.
 * Meaning that it can have inner variables.
 * 
 * @author jfernandes
 */
class XWollokObjectDebugValue extends XDebugValue {
	String varName
	// debería ser lazy
	@Accessors List<XDebugStackFrameVariable> variables = newArrayList

	new(String varName, WollokObject obj) {
		super(obj.shortLabel + " (id=" + obj.identityHashCode + ")")
		this.varName = varName
		variables = obj.debugVariables
	}

}