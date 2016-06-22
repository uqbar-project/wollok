package wollok.lang

import java.math.BigDecimal
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

class Interval {
	
	WollokObject obj
	
	new(WollokObject _obj) {
		obj = _obj
	}
	
	def solve(String fieldName) {
		obj.resolve(fieldName).wollokToJava(Double) as BigDecimal
	}

	/**
	 * Type constraint: only numbers allowed, integers and doubles
	 */	
	def void validate(WollokObject value) {
		try {
			value.wollokToJava(Double) as BigDecimal
		} catch (Throwable e) {
			try {
				value.wollokToJava(Integer) as BigDecimal
			} catch (Throwable eInt) {
				throw new IllegalArgumentException(value.toString() + " : only numbers are allowed in an Interval")
			}
		}
	}
	
	def random() {
		val start = solve("start")
		val end = solve("end")
		(Math.random * (end - start)) + start
	}
	
}