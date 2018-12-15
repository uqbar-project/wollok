package org.uqbar.project.wollok.interpreter.core

import java.util.Map
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterConsole
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.context.UnresolvableReference
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokDeclarativeNativeObject
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * Contiene metodos "nativos" que están disponibles
 * para todo script como funciones de "this" (aunque solo 
 * a nivel root del archivo. Es decir que estas funciones
 * no están disponibles dentro de un objeto).
 * 
 * @deprecated this is the only "special" evalcontext which is not a WollokObject.
 * That's not happy at all.
 * 
 * @author jfernandes
 */
class WollokNativeLobby extends AbstractWollokDeclarativeNativeObject implements EvaluationContext<WollokObject> {
	val Map<String, WollokObject> localProgramVariables = newHashMap
	WollokInterpreterConsole console
	
	new(WollokInterpreterConsole console, WollokInterpreter interpreter) {
		super(null, interpreter)
		this.console = console
	}
	
	override getThisObject() { throw new UnsupportedOperationException(Messages.WollokDslValidator_CANNOT_USE_SELF_IN_A_PROGRAM)}

	def allVariables() {
		val allVariables = localProgramVariables
		allVariables.putAll(interpreter.globalVariables)
		allVariables
	}
	
	override allReferenceNames() {
		allVariables.keySet.map[ variableName |
			new WVariable(variableName, System.identityHashCode(allVariables.get(variableName)), false)
		]
	}

	override resolve(String variableName) throws UnresolvableReference {
		if (localProgramVariables.containsKey(variableName))
			localProgramVariables.get(variableName)
		else interpreter.resolve(variableName)
	}
	
	override setReference(String variableName, WollokObject value) {
		if (!localProgramVariables.containsKey(variableName)){
			interpreter.setReference(variableName, value)
		}
		else
			localProgramVariables.put(variableName,value)
	}
	
	override addReference(String variable, WollokObject value) {
		localProgramVariables.put(variable, value)
		value
	}
	
	// ******************************
	// ** native
	// ******************************
	
	def println(Object args) {
		console.logMessage("" + args)
	}
	
	def sleep(Integer milis) {
		Thread.sleep(milis)
	}
	
	override addGlobalReference(String name, WollokObject value) {
		interpreter.globalVariables.put(name,value)
		value
	}
	
	override removeGlobalReference(String name) {
		interpreter.globalVariables.remove(name)
	}
	
	
	// ******************************
	// ** Object methods (for debugging interpreter)
	// ******************************
	
	override toString() { "Lobby" }

	override showableInStackTrace() { !interpreter.isRootFile }
	
	override showableInDynamicDiagram(String name) {
		true
//		val value = allVariables.get(name)
//		(value === null || !value.behavior.name.toLowerCase.contains("exception"))
	}
	
}
