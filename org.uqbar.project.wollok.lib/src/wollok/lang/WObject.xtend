package wollok.lang

import java.util.Collection
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.core.ToStringBuilder
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.ui.utils.XTendUtilExtensions

/**
 * Wollok Object class. It's the native part
 * 
 * @author jfernandes
 */
class WObject {
	val WollokObject obj
	val WollokInterpreter interpreter
	
	new(WollokObject obj, WollokInterpreter interpreter) {
		this.obj = obj
		this.interpreter = interpreter
	}
	
	def identity() { System.identityHashCode(obj) }
	
	def randomBetween(Integer start, Integer end) { XTendUtilExtensions.randomBetween(start, end) }
	
	def kindName() { ToStringBuilder.objectDescription(obj.behavior) }
	
	def instanceVariables() {
		newList(obj.instanceVariables.keySet.map[ variableMirror(it) ].toList)
	}
	
	def instanceVariableFor(String name) {
		variableMirror(name)
	}
	
	def variableMirror(String name) {
		newInstance("wollok.mirror.InstanceVariableMirror", obj, name)
	}
	
	def resolve(String instVarName) {
		obj.resolve(instVarName)
	}
	
	def newInstance(String className, Object... arguments) {
		(interpreter.evaluator as WollokInterpreterEvaluator).newInstance(className, arguments)
	}
	
	def newList(Collection<?> elements) {
		val list = newInstance("wollok.lang.WList")
		elements.forEach[ 
			list.call("add", it)
		]
		list
	}
	
}