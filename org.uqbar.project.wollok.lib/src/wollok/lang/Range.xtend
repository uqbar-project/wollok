package wollok.lang

import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokClosure
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

/**
 * 
 * @author jfernandes
 */
class Range extends AbstractJavaWrapper<IntegerRange> {
	
	new(WollokObject obj, WollokInterpreter interpreter) {
		super(obj, interpreter) 
	}
	
	def void forEach(WollokClosure proc) {
		initWrapped.forEach[e| proc.apply(e.javaToWollok) ]
	}
	
	def initWrapped() {
		if (wrapped == null)
			wrapped = new IntegerRange(obj.resolve("start").wollokToJava(Integer) as Integer, obj.resolve("end").wollokToJava(Integer) as Integer)
		wrapped
	}
	
}