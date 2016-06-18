package wollok.lang

import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

class Interval {
	
	WollokObject obj
	double start 
	double end
	
	new(WollokObject obj, WollokInterpreter interpreter) {
		start = solve("start")
		end = solve("end")
	}
	
	def solve(String fieldName) {
		obj.resolve(fieldName).wollokToJava(Double) as Double
	}
	
	def Double validate(Object value) {
		try {
			return value.wollokToJava(Double) as Double
		} catch (Throwable e) {
			throw new IllegalArgumentException(value.toString() + " : only reals are allowed in an Interval")
		}
	}
	
	def random() {
		(Math.random * (end - start)) + start
	}
	
}