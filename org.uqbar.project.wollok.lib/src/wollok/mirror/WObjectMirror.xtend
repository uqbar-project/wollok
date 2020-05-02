package wollok.mirror

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokObject
import wollok.lang.WObject

@Accessors(PUBLIC_GETTER)
class WObjectMirror {

	WollokObject obj
	WollokInterpreter interpreter
	
	new(WollokObject obj, WollokInterpreter interpreter) {
		this.obj = obj
		this.interpreter = interpreter
	}
	
	def WollokObject resolve(String attributeName) {
		internalTarget.resolve(attributeName)		
	}

	def instanceVariables() {
		internalTarget.instanceVariables
	}
	
	def instanceVariableFor(String name) {
		internalTarget.instanceVariableFor(name)
	}
	
	def target() {
		obj.resolve("target") as WollokObject
	}

	def internalTarget() {
		new WObject(target, interpreter)
	}
}