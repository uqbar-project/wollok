package org.uqbar.project.wollok.debugger.server.rmi

import com.google.common.collect.Lists
import java.io.Serializable
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.stack.SourceCodeLocation
import org.uqbar.project.wollok.interpreter.stack.XStackFrame
import org.uqbar.project.wollok.sdk.WollokDSK

/**
 * 
 * @author jfernandes
 */
@Accessors
class XDebugStackFrame implements Serializable {
	SourceCodeLocation sourceLocation
	List<XDebugStackFrameVariable> variables
	
	new(XStackFrame<WollokObject> frame) {
		sourceLocation = frame.currentLocation
		variables = frame.context.debugVariables
	}
	
	def static unwantedObjects() {
		#[WollokConstants.SELF, WollokDSK.VOID, WollokDSK.CONSOLE]
	}
	
	def static List<XDebugStackFrameVariable> debugVariables(EvaluationContext<WollokObject> context) {
		Lists.newArrayList(context.allReferenceNames
			.filter[ !local && context.showableInDynamicDiagram(name) && !unwantedObjects.exists
				[ unwanted | name.toLowerCase.contains(unwanted) ]
			]
			.map[ toVariable(context) ])
	}
	
	def static toVariable(WVariable variable, EvaluationContext<WollokObject> context) {
		new XDebugStackFrameVariable(variable, context.resolve(variable.name))
	}
	
}