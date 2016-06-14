package wollok.lang

import java.util.Collection
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.core.ToStringBuilder
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.sdk.WollokDSK

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

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
	
	def kindName() { ToStringBuilder.objectDescription(obj.behavior) }
	def className() { (obj.kind).fqn }
	
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
		val wArgs = arguments.map[javaToWollok]
		(interpreter.evaluator as WollokInterpreterEvaluator).newInstance(className, wArgs)
	}
	
	def newList(Collection<WollokObject> elements) {
		val list = newInstance(WollokDSK.LIST)
		elements.forEach[ 
			list.call("add", it.javaToWollok)
		]
		list
	}
	
}