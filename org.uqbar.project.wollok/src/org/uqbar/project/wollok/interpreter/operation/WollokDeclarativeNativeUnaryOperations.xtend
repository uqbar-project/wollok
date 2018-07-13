package org.uqbar.project.wollok.interpreter.operation

import java.lang.reflect.Method
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.interpreter.core.WCallable
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
// I18N !
class WollokDeclarativeNativeUnaryOperations implements WollokBasicUnaryOperations {
	
	override asUnaryOperation(String operationSymbol) {
		val op = class.methods.findFirst[hasAnnotationForOperation(operationSymbol)]
		if (op === null) {
			//TODO: model a generic WollokVMException
			throw new RuntimeException(NLS.bind(Messages.WollokInterpreter_operationNotSupported, operationSymbol))
		}
		[ a | op.invoke(this, a) as WollokObject ]
	}
	
	def hasAnnotationForOperation(Method m, String op) {
		m.isAnnotationPresent(UnaryOperation) && m.getAnnotation(UnaryOperation).value == op
	}
	
	def throwOperationNotSupported(String operator, Object target) {
		throw new RuntimeException(NLS.bind(Messages.WollokInterpreter_operatorNotSupported, operator, target))
	}
	
	// OPERATIONS
	
	@UnaryOperation('!')
	def Object negateOperation(Object a) { negate(a) }  
	def dispatch negate(WCallable a) { a.call("negate") }
	def dispatch negate(Boolean a) { !a }
	def dispatch negate(Object a) { throwOperationNotSupported("!", a) }
	
	@UnaryOperation('not')
	def Object notOperation(Object a) { negate(a) }
	
	@UnaryOperation('-')
	def Object invertOperation(Object a) { invert(a) }  
	def dispatch invert(WCallable a) { a.call("invert") }
	def dispatch invert(Object a) { throwOperationNotSupported("-", a)  }

	@UnaryOperation('+')
	def Object plusOperation(Object a) { plus(a) }  
	def dispatch plus(WCallable a) { a.call("plus") }
	def dispatch plus(Object a) { throwOperationNotSupported("+", a)  }

}