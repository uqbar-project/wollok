package wollok.lang

import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static org.uqbar.project.wollok.sdk.WollokDSK.*

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

/**
 * 
 * @author jfernandes
 */
class Range extends AbstractJavaWrapper<IntegerRange> {
	
	new(WollokObject obj, WollokInterpreter interpreter) {
		super(obj, interpreter) 
	}
	
	def void forEach(WollokObject proc) {
		val c = (proc.getNativeObject(CLOSURE) as Closure)
		initWrapped.forEach[e| c.doApply(e.javaToWollok) ]
	}
	
	def initWrapped() {
		if (wrapped == null) {
			val start = solve("start")
			val end = solve("end")
			wrapped = new IntegerRange(start, end)
		}
		wrapped
	}
	
	def solve(String fieldName) {
		obj.resolve(fieldName).wollokToJava(Integer) as Integer
	}
	
	def Integer validate(Object value) {
		try {
			return value.wollokToJava(Integer) as Integer
		} catch (Throwable e) {
			throw new IllegalArgumentException(value.toString() + " : only integers are allowed in a Range")
		}
	}
}