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
	
	public static val UNWANTED_OBJECTS = #[WollokConstants.SELF, WollokSDK.VOID, WollokSDK.CONSOLE, WollokSDK.ASSERT, WollokSDK.OBJECT, WollokSDK.GAME, WollokSDK.DAYS_OF_WEEK]

	new(XStackFrame<WollokObject> frame) {
		sourceLocation = frame.currentLocation
		variables = frame.context.debugVariables
	}

	def static List<XDebugStackFrameVariable> debugVariables(EvaluationContext<WollokObject> context) {
		val vars = Lists.newArrayList(context.allReferenceNamesForDynamicDiagram
			.filter [
			!local && context.variableShowableInDynamicDiagram(name) && !UNWANTED_OBJECTS.exists [ unwanted |
				name.contains(unwanted)
			]
		])
		Lists.newArrayList(vars.map [
			toVariable(context)
		])
	}

	def static toVariable(WVariable variable, EvaluationContext<WollokObject> context) {
		if (allVariables.contains(variable)) {
			// Evita que el listener entre en loop infinito por referencias circulares. (parte 1) 
			// Luego el diagrama de objetos enlaza los objetos por id interno.
			return new XDebugStackFrameVariable(variable, null)
		}
		val value = allValues.get(variable)
		if (value !== null) {
			return new XDebugStackFrameVariable(variable, value)
		}
		val newValue = context.resolve(variable.name)
		val result = new XDebugStackFrameVariable(variable, newValue)
		result
	}

	def static initAllVariables() {
		allVariables = newArrayList
		allValues = newHashMap
	}

}
