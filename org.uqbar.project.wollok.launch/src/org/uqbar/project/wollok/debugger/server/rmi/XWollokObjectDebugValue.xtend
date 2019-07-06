package org.uqbar.project.wollok.debugger.server.rmi

import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper

import static extension org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrame.debugVariables
import static extension org.uqbar.project.wollok.interpreter.core.ToStringBuilder.shortLabel
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.sdk.WollokDSK.*
import static extension org.uqbar.project.wollok.utils.WollokObjectUtils.*
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * A stack frame variable's value that holds a wollok object.
 * Meaning that it can have inner variables.
 * 
 * @author jfernandes
 */
class XWollokObjectDebugValue extends XDebugValue {
	@Accessors(PUBLIC_GETTER) String typeName
	String varName

	new(String varName, WollokObject obj) {
		super(obj.description, System.identityHashCode(obj))
		this.typeName = obj.behavior.fqn
		this.varName = varName
		if (!obj.isBasicType)
			variables = obj.debugVariables
	}
	
	def static description(WollokObject obj) {
		if (obj.isBasicType)
			obj.asString
		else {
			if (obj.hasShortDescription)
				obj.asString("shortDescription")
			else obj.shortLabel
		}
	}
	
}