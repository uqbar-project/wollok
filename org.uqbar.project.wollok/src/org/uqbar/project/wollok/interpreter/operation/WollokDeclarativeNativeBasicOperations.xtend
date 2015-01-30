package org.uqbar.project.wollok.interpreter.operation

import java.lang.reflect.Method
import org.uqbar.project.wollok.interpreter.context.MessageNotUnderstood
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

/**
 * WollokBasicBinaryOperations implementations which includes native
 * code for all binary operations, but it also delegates as a regular method
 * call to WollokObjects. This allows you operator overloading in your own objects.
 * 
 * Also this implementations is "declarative", since it uses reflection
 * to look for a method annotation with BinaryOperation("..") which indicates
 * which operator does it implements (as a string in grammar).
 * 
 * On top of that, the operations are implemented as multiple dispatch methods.
 * Allowing to have different behaviors based on the parameter types.
 * 
 * @author jfernandes
 */
class WollokDeclarativeNativeBasicOperations implements WollokBasicBinaryOperations {
	
	override asBinaryOperation(String operationSymbol) {
		val op = class.methods.findFirst[hasAnnotationForOperation(operationSymbol)]
		if (op == null) {
			throw new MessageNotUnderstood("Operation '" + operationSymbol + "' not supported by interpreter")
		}
		[Object a, Object b| op.invoke(this, a, b) ]
	}
	
	def hasAnnotationForOperation(Method m, String op) {
		m.isAnnotationPresent(BinaryOperation) && m.getAnnotation(BinaryOperation).value == op
	}
	
	// OPERATIONS
	
	@BinaryOperation('+') // needed 2 methods: 1st for the annotation, then the multi-dispatch
	def Object sumOperation(Object a, Object b) {
		if (a == null) b
		else if (b == null) a
		else sum(a, b)
	}  
		def dispatch sum(Object a, Object b) { throw new MessageNotUnderstood(a + " does not understand + operator" ) }
		def dispatch sum(WollokObject a, Object b) { a.call("+", b) }
		def dispatch sum(Integer a, Double b) { a + b }
		def dispatch sum(Integer a, Integer b) { a + b }
		def dispatch sum(Double a, Number b) { a + b.doubleValue }
		def dispatch sum(String a, Object b) { a + b }
	
	def zero(Object nonNull) { minus(nonNull, nonNull) }
	
	@BinaryOperation('-')	
	def Object minusOperation(Object a, Object b) { 
		if (a == null) { 
			if (b != null) minus(b.zero, b)
			else null
		}
		else if (b == null) a
		else minus(a, b)
	}
		def dispatch minus(Object a, Object b) { throw new MessageNotUnderstood(a + " does not understand - operator" ) }  
		def dispatch minus(WollokObject a, Object b) { a.call("-", b) }
		def dispatch minus(Integer a, Double b) { a - b }
		def dispatch minus(Integer a, Integer b) { a - b }
		def dispatch minus(Double a, Number b) { a - b.doubleValue }
		def dispatch minus(String a, Integer b) { a.substring(0, a.length - b) }
		def dispatch minus(String a, String b) { a.replace(b, "") }
	
	@BinaryOperation('*')  
	def Object multiplyOperation(Object a, Object b) { 
		if (a == null || b == null) null
		else multiply(a, b)
	}
		def dispatch multiply(Object a, Object b) { throw new MessageNotUnderstood(a + " does not understand * operator" ) }  
		def dispatch multiply(WollokObject a, Object b) { a.call("*", b) }
		def dispatch multiply(Integer a, Number b) { a * b.intValue }
		def dispatch multiply(Double a, Number b) { a * b.doubleValue }
		def dispatch multiply(String a, Integer b) { (1..b).map[a].join }
		def dispatch multiply(Integer a, String b) { (1..a).map[b].join }
	
	@BinaryOperation('/')
	def Object divideOperation(Object a, Object b) { divide(a, b) }
		def dispatch divide(Object a, Object b) { throw new MessageNotUnderstood(a + " does not understand / operator" ) }  
		def dispatch divide(WollokObject a, Object b) { a.call("/", b) }
		def dispatch divide(Integer a, Integer b) { a / b }
		def dispatch divide(Double a, Number b) { a / b.doubleValue }
		def dispatch divide(Number a, Double b) { a.doubleValue / b }
	
	@BinaryOperation('**')
	def Object raiseOperation(Object a, Object b) { raise(a, b) }
		def dispatch raise(Object a, Object b) { throw new MessageNotUnderstood(a + " does not understand ** operator" ) }  
		def dispatch raise(WollokObject a, Object b) { a.call("**", b) }
		def dispatch raise(Integer a, Number b) { a ** b.intValue }
		def dispatch raise(Double a, Number b) { a ** b.doubleValue }
	
	@BinaryOperation('%')
	def Object moduleOperation(Object a, Object b) { module(a, b) }
		def dispatch module(Object a, Object b) { throw new MessageNotUnderstood(a + " does not understand % operator" ) }  
		def dispatch module(WollokObject a, Object b) { a.call("%", b) }
		def dispatch module(Integer a, Number b) { a % b.intValue }
		def dispatch module(Double a, Number b) { a % b.doubleValue }
	
	@BinaryOperation('&&')
	def Object andOperation(Object a, Object b) { and(a, b) }  
		def dispatch and(Object a, Object b) { throw new MessageNotUnderstood(a + " does not understand && operator" ) }
		def dispatch and(WollokObject a, Object b) { a.call("&&", b) }
		def dispatch and(Boolean a, Boolean b) { a && b }
	@BinaryOperation('and')	
	def Object andPhrase(Object a, Object b) { andOperation(a, b)}
	
	@BinaryOperation('||')
	def Object orOperation(Object a, Object b) { or(a, b) }
		def dispatch or(Object a, Object b) { throw new MessageNotUnderstood(a + " does not understand || operator" ) }  
		def dispatch or(WollokObject a, Object b) { a.call("||", b) }
		def dispatch or(Boolean a, Boolean b) { a || b }
	@BinaryOperation('or')	
	def Object orPhrase(Object a, Object b) { orOperation(a, b)}
	
	@BinaryOperation('==')
	def Object equalsOperation(Object a, Object b) { 
		overloadOr(a, '==', b) [| bothNull(a,b) || (noneAreNull(a,b) && a.eq(b)) ]
	}
		def dispatch Boolean eq(Object a, Object b) { a == b }
		def dispatch Boolean eq(Double a, Integer b) { a == b.doubleValue }
		def dispatch Boolean eq(Integer a, Double b) { a.doubleValue == b }
		def dispatch Boolean eq(double a, double b) { a == b }
		def dispatch Boolean eq(int a, int b) { a == b }
	
	@BinaryOperation('!=')
	def Object notEqualsOperation(Object a, Object b) { overloadOr(a, '!=', b) [| a != b ] }
	@BinaryOperation('===')
	def Object identicalOperation(Object a, Object b) { overloadOr(a, '===', b) [| a === b ] }
	@BinaryOperation('!==')
	def Object notIdenticalOperation(Object a, Object b) { overloadOr(a, '!==', b) [| a !== b ] }
	
		/** tries sending the message to the wollok object so it can be overloading, otherwise the block */
	def protected overloadOr(Object a, String message, Object b, ()=>Object otherwise) {
		if (a instanceof WollokObject)
			try
				return a.call(message, b)
			catch(MessageNotUnderstood e){
				// not understood, fallback !
			}
		otherwise.apply
	}
	
	// <, >, >=, <=
	
	@BinaryOperation('>=')
	def Boolean greaterOrEqualsOperation(Object a, Object b) { ge(a, b) }  
		def dispatch ge(Object a, Object b) { throw new MessageNotUnderstood(a + " does not understand >= operator" ) }
		def dispatch ge(WollokObject a, Object b) { a.call(">=", b) as Boolean }
		def dispatch ge(Integer a, Integer b) { a >= b }
		def dispatch ge(Double a, Number b) { a >= b.doubleValue }
		def dispatch ge(Number a, Double b) { a.doubleValue >= b }
	@BinaryOperation('<=')
	def Boolean lesserOrEqualsOperation(Object a, Object b) { le(a, b) }
		def dispatch le(Object a, Object b) { throw new MessageNotUnderstood(a + " does not understand <= operator" ) }  
		def dispatch le(WollokObject a, Object b) { a.call("<=", b) as Boolean }
		def dispatch le(Integer a, Integer b) { a <= b }
		def dispatch le(Double a, Number b) { a <= b.doubleValue }
		def dispatch le(Number a, Double b) { a.doubleValue <= b }
	@BinaryOperation('>')
	def Boolean greaterOperation(Object a, Object b) { gt(a, b) }
		def dispatch gt(Object a, Object b) { throw new MessageNotUnderstood(a + " does not understand > operator" ) }
		def dispatch gt(WollokObject a, Object b) { a.call(">", b) as Boolean }
		def dispatch gt(Integer a, Integer b) { a > b }
		def dispatch gt(Double a, Number b) { a > b.doubleValue }
		def dispatch gt(Number a, Double b) { a.doubleValue > b }
	@BinaryOperation('<')
	def Boolean lesserOperation(Object a, Object b) { lt(a, b) as Boolean }
		def dispatch lt(Object a, Object b) { throw new MessageNotUnderstood(a + " does not understand < operator" ) }  
		def dispatch lt(WollokObject a, Object b) { a.call("<", b) }
		def dispatch lt(Integer a, Integer b) { a < b }
		def dispatch lt(Double a, Number b) { a < b.doubleValue }
		def dispatch lt(Number a, Double b) { a.doubleValue < b }
		
}