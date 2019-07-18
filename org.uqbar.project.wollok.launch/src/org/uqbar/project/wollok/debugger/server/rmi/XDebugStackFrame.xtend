package org.uqbar.project.wollok.debugger.server.rmi

import com.google.common.collect.Lists
import java.io.Serializable
import java.util.List
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.stack.SourceCodeLocation
import org.uqbar.project.wollok.interpreter.stack.XStackFrame
import org.uqbar.project.wollok.sdk.WollokSDK

/**
 * 
 * @author jfernandes
 */
@Accessors
class XDebugStackFrame implements Serializable {
	SourceCodeLocation sourceLocation
	List<XDebugStackFrameVariable> variables
	public static Map<WVariable, WollokObject> allValues
	public static List<WVariable> allVariables

	new(XStackFrame<WollokObject> frame) {
		sourceLocation = frame.currentLocation
		variables = frame.context.debugVariables
	}

	def static unwantedObjects() {
		#[WollokConstants.SELF, WollokSDK.VOID, WollokSDK.CONSOLE]
	}

	def static List<XDebugStackFrameVariable> debugVariables(EvaluationContext<WollokObject> context) {
		val vars = Lists.newArrayList(context.allReferenceNames.filter [
			!local && context.showableInDynamicDiagram(name) && !unwantedObjects.exists [ unwanted |
				name.toLowerCase.contains(unwanted)
			]
		])
		Lists.newArrayList(vars.map [
			toVariable(context)
		])
	}

	def static toVariable(WVariable variable, EvaluationContext<WollokObject> context) {
		if (allVariables.contains(variable)) {
			return new XDebugStackFrameVariable(variable, null) // Evita que el listener entre en loop infinito por referencias circulares. Luego el diagrama de objetos enlaza los objetos por id interno.
		}
		val value = allValues.get(variable)
		if (value !== null) {
			return new XDebugStackFrameVariable(variable, value)
		}
		allVariables.add(variable)
		val newValue = context.resolve(variable.name)
		allValues.put(variable, newValue)
		new XDebugStackFrameVariable(variable, newValue)
	}

	def static initAllVariables() {
		allVariables = newArrayList
		allValues = newHashMap
	}

}
