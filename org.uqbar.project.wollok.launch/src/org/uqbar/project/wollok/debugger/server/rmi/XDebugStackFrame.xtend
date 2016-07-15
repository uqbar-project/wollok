package org.uqbar.project.wollok.debugger.server.rmi

import java.io.Serializable
import java.util.List
import org.eclipse.xtend.lib.Property
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.core.WollokObject
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
	
	def static List<XDebugStackFrameVariable> debugVariables(EvaluationContext<WollokObject> context) {
		newArrayList(context.allReferenceNames.filter[name != WollokConstants.SELF].map[toVariable(context)])
	}
	
	def static toVariable(WVariable variable, EvaluationContext<WollokObject> context) {
		new XDebugStackFrameVariable(variable, context.resolve(variable.name))
	}
	
}