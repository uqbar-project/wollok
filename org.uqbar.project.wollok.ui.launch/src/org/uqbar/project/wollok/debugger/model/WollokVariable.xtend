package org.uqbar.project.wollok.debugger.model

import java.util.List
import org.eclipse.debug.core.model.IValue
import org.eclipse.debug.core.model.IVariable
import org.uqbar.project.wollok.debugger.WollokDebugTarget
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrameVariable
import org.uqbar.project.wollok.debugger.server.rmi.XDebugValue
import org.uqbar.project.wollok.debugger.server.rmi.XWollokCollectionDebugValue
import org.uqbar.project.wollok.debugger.server.rmi.XWollokObjectDebugValue
import org.uqbar.project.wollok.model.ResourceUtils

/**
 * 
 * @author jfernandes
 */
class WollokVariable extends WollokDebugElement implements IVariable {
	XDebugStackFrameVariable adaptee
	IValue value
	
	new(WollokDebugTarget target, XDebugStackFrameVariable adaptee) {
		super(target)
		this.adaptee = adaptee
		value = if (adaptee.value === null) null else adaptee.value.toEclipseValue
	}
	
	def dispatch toEclipseValue(XWollokObjectDebugValue value) { new WollokObjectValue(target, value) }
	def dispatch toEclipseValue(XWollokCollectionDebugValue value) { new WollokObjectValue(target, value) }
	def dispatch toEclipseValue(XDebugValue value) { 
		new WollokValue(target, value.stringValue)
	}
	
	override getName() { adaptee.variable.name }
	override getValue() { value }
	// TYPE SYSTEM (?)
	override getReferenceTypeName() { "Any" }

	// *******************************
	// ** UNIMPLEMENTED methods
	// *******************************
	
	override hasValueChanged() { false }
	override setValue(String expression) { throw new UnsupportedOperationException("Not implemented yet") }
	override setValue(IValue value) { throw new UnsupportedOperationException("Not implemented") }
	override supportsValueModification() { false }
	override verifyValue(String expression) { false }
	override verifyValue(IValue value) { false }
	
	def String getIcon() {
		// eventually all variables will know their custom icons
		if (adaptee.value instanceof XWollokCollectionDebugValue) 
			'icons/listVariableIcon.gif'
		else if (adaptee.variable.local)
			'icons/localvariable_obj.png'
		else
			null
	}
	
	override toString() {
		this.adaptee.variable.id.toString
	}
	
	override equals(Object o) {
		try {
			val other = o as WollokVariable
			return other.toString.equals(this.toString) 
		} catch (ClassCastException e) {
			return super.equals(o)
		}
	}
	
	override hashCode() {
		this.toString.hashCode
	}
		
	def shouldShowRootConnection(List<IVariable> variables) {
		val finalValue = getActualValue(variables)
		finalValue === null || !isGlobalReferenceToWKO(finalValue)
	}

	def IValue getActualValue(List<IVariable> variables) {
		if (this.value === null) {
			// If value was already taken, find it
			val replacedVariable = variables.findFirst [ toString.equals(adaptee.identifier) ]
			if (replacedVariable !== null) {
				return replacedVariable.value
			}
		}
		return this.value
	}

	def dispatch isGlobalReferenceToWKO(WollokValue value) {
		value.isWKO && ResourceUtils.implicitPackagePreffixes.values.map[
			it + value.referenceTypeName
		].exists[
			adaptee.name.equals(it)
		]
	}
	
	def dispatch isGlobalReferenceToWKO(IValue value) {
		false
	}
		
	def isConstantReference() {
		adaptee.variable.constant
	}

}