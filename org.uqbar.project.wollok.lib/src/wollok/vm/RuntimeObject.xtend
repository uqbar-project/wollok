package wollok.vm

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokObject

class RuntimeObject {
	@Accessors(PUBLIC_GETTER) val WollokObject obj
	val WollokInterpreter interpreter
	
	new(WollokObject obj, WollokInterpreter interpreter) {
		this.obj = obj
		this.interpreter = interpreter
	}
	
	def isInteractive(){
		interpreter.interactive
	}
}