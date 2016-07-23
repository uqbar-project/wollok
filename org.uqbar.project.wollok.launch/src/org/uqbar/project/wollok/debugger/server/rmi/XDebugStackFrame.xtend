package org.uqbar.project.wollok.debugger.server.rmi

import com.google.common.collect.Lists
import java.io.Serializable
import java.util.ArrayList
import org.eclipse.xtend.lib.annotations.Accessors
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
@Accessors
class XDebugStackFrame implements Serializable {
	SourceCodeLocation sourceLocation
	ArrayList<XDebugStackFrameVariable> variables
	
	new() {} // compatible with serialization
	
	new(XStackFrame frame) {
		sourceLocation = frame.currentLocation
		variables = frame.context.debugVariables
//		variables = new ArrayList
//		variables.add(new XDebugStackFrameVariable(new WVariable("abc", true), null))
	}
	
	def static ArrayList<XDebugStackFrameVariable> debugVariables(EvaluationContext<WollokObject> context) {
		Lists.newArrayList(context.allReferenceNames.filter[name != WollokConstants.SELF].map[
//			println("[VM] Mapping variable " + it.name)
			toVariable(context)
		])
	}
	
	def static toVariable(WVariable variable, EvaluationContext<WollokObject> context) {
		new XDebugStackFrameVariable(variable, context.resolve(variable.name))
	}
	
}