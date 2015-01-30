package org.uqbar.project.wollok.ui.debugger.server.rmi

import java.io.Serializable
import java.util.List
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.stack.SourceCodeLocation
import org.uqbar.project.wollok.interpreter.stack.XStackFrame

/**
 * 
 * @author jfernandes
 */
class XDebugStackFrame implements Serializable {
	@Property SourceCodeLocation sourceLocation
	@Property List<XDebugStackFrameVariable> variables = newArrayList
	
	new(XStackFrame frame) {
		sourceLocation = frame.currentLocation
		variables = frame.context.debugVariables
	}
	
	def static List<XDebugStackFrameVariable> debugVariables(EvaluationContext context) {
		newArrayList(context.allReferenceNames.map[it.toVariable(context)])
	}
	
	def static toVariable(WVariable variable, EvaluationContext context) {
		new XDebugStackFrameVariable(variable, context.resolve(variable.name))
	}
	
}