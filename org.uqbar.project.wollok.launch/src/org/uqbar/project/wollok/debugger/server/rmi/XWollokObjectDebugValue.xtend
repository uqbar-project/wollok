package org.uqbar.project.wollok.debugger.server.rmi

import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.eclipse.xtend.lib.annotations.Accessors

import static extension org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrame.debugVariables
import static extension org.uqbar.project.wollok.interpreter.core.ToStringBuilder.shortLabel
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.WollokObjectUtils.*
import static extension org.uqbar.project.wollok.sdk.WollokSDK.*
import static org.uqbar.project.wollok.WollokConstants.*

/**
 * A stack frame variable's value that holds a wollok object.
 * Meaning that it can have inner variables.
 * 
 * @author jfernandes
 */
class XWollokObjectDebugValue extends XDebugValue {
	@Accessors(PUBLIC_GETTER) String typeName
	@Accessors(PUBLIC_GETTER) String varName
	@Accessors(PUBLIC_GETTER) boolean isNamedObject

	new(String varName, WollokObject obj) {
		super(obj.description, System.identityHashCode(obj))
		this.isNamedObject = obj.behavior.wellKnownObject
		this.typeName = obj.behavior.fqn
		this.varName = varName
		if (!obj.isBasicType && !obj.shouldUseShortDescriptionForDynamicDiagram)
			variables = obj.debugVariables
	}
	
	def static description(WollokObject obj) {
		if (obj.isBasicType) {
			obj.asString(TO_STRING_PRINTABLE)
		}
		else {
			if (obj.shouldUseShortDescriptionForDynamicDiagram)
				obj.asString(TO_STRING_SHORT)
			else obj.shortLabel
		}
	}

	override isWKO() { this.isNamedObject }

}