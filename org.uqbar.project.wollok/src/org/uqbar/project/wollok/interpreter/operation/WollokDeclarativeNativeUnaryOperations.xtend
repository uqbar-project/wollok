package org.uqbar.project.wollok.interpreter.operation

import java.lang.reflect.Method
import org.uqbar.project.wollok.interpreter.MessageNotUnderstood
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * WollokBasicBinaryOperations implementations which includes native
 * code for all unary operations, but it also delegates as a regular method
 * call to WollokObjects. This allows you operator overloading in your own objects.
 * 
 * Also this implementations is "declarative", since it uses reflection
 * to look for a method annotation with UnaryOperation("..") which indicates
 * which operator does it implements (as a string in grammar).
 * 
 * On top of that, the operations are implemented as multiple dispatch methods.
 * Allowing to have different behaviors based on the parameter types.
 * 
 * 
 * @author tesonep
 * @author jfernandes
 */
class WollokDeclarativeNativeUnaryOperations implements WollokBasicUnaryOperations {
	
	override asUnaryOperation(String operationSymbol) {
		val op = class.methods.findFirst[hasAnnotationForOperation(operationSymbol)]
		if (op == null) {
			throw new MessageNotUnderstood("Operation '" + operationSymbol + "' not supported by interpreter")
		}
		[Object a | op.invoke(this, a) ]
	}
	
	def hasAnnotationForOperation(Method m, String op) {
		m.isAnnotationPresent(UnaryOperation) && m.getAnnotation(UnaryOperation).value == op
	}
	
	// OPERATIONS
	
	@UnaryOperation('!')
	def Object negateOperation(Object a) { negate(a) }  
	def dispatch negate(WollokObject a) { a.call("negate") }
	def dispatch negate(Boolean a) { !a }
	def dispatch negate(Object a) { throw new MessageNotUnderstood("Type " + a + "does not implement negate operation (!)") }
	@UnaryOperation('not')
	def Object notOperation(Object a) { negate(a) }
	
	@UnaryOperation('-')
	def Object invertOperation(Object a) { invert(a) }  
	def dispatch invert(WollokObject a) { a.call("invert") }
	def dispatch invert(Integer a) { -a }
	def dispatch invert(Double a) { -a }
	def dispatch invert(Object a) { throw new MessageNotUnderstood("Type " + a + "does not implement invert operation (-)") }

	@UnaryOperation('+')
	def Object plusOperation(Object a) { plus(a) }  
	def dispatch plus(WollokObject a) { a.call("plus") }
	def dispatch plus(Integer a) { a }
	def dispatch plus(Double a) { a }
	def dispatch plus(Object a) { throw new MessageNotUnderstood("Type " + a + "does not implement plus operation (+)") }

}