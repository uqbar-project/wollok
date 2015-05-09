package org.uqbar.project.wollok.interpreter.operation

import java.lang.reflect.Method
import org.uqbar.project.wollok.interpreter.IllegalBinaryOperation
import org.uqbar.project.wollok.interpreter.MessageNotUnderstood
import org.uqbar.project.wollok.interpreter.core.WCallable
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.WollokDouble
import org.uqbar.project.wollok.interpreter.nativeobj.WollokInteger
import org.uqbar.project.wollok.interpreter.nativeobj.WollokNumber

import static org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*
import org.uqbar.project.wollok.interpreter.nativeobj.WollokRange

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
		if (op != null) {
			[Object a, Object b| op.invoke(this, a, b) ]
		}
		else
			[Object a, Object b | 
				unknownOperator(a, operationSymbol, b)
			]
	}
	
	// if not resolved by methods in this class: overload or fail
	def dispatch unknownOperator(WCallable callable, String operationSymbol, Object b) { callable.call(operationSymbol, b) }
	def dispatch unknownOperator(Object a, String operationSymbol, Object b) {
		throw new IllegalBinaryOperation("Operation '" + operationSymbol + "' not supported by interpreter")
	}
	
	def hasAnnotationForOperation(Method m, String op) {
		m.isAnnotationPresent(BinaryOperation) && m.getAnnotation(BinaryOperation).value == op
	}
	
	// ********************************************************************************************
	// ** Math
	// ********************************************************************************************
	
	@BinaryOperation('+') // needed 2 methods: 1st for the annotation, then the multi-dispatch
	def Object sumOperation(Object a, Object b) {
		if (a == null) b
		else if (b == null) a
		else sum(a, b)
	}  
		def dispatch sum(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to add «a» + «b»''') }
		def dispatch sum(WCallable a, Object b) { a.call("+", b) }
		def dispatch sum(WollokInteger a, WollokInteger b) { new WollokInteger(a.wrapped + b.wrapped) }
		def dispatch sum(WollokNumber<?> a, WollokNumber<?> b) { new WollokDouble(a.doubleValue + b.doubleValue) }
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
		def dispatch minus(Object a, Object b) { throw new IllegalBinaryOperation('''Unable tu subtract «a» - «b»''') }  
		def dispatch minus(WCallable a, Object b) { a.call("-", b) }
		def dispatch minus(WollokInteger a, WollokInteger b) { new WollokInteger(a.wrapped - b.wrapped) }
		def dispatch minus(WollokNumber<?> a, WollokNumber<?> b) { new WollokDouble(a.doubleValue - b.doubleValue) }
		def dispatch minus(String a, WollokInteger b) { a.substring(0, a.length - b.wrapped) }
		def dispatch minus(String a, String b) { a.replace(b, "") }
	
	@BinaryOperation('*')  
	def Object multiplyOperation(Object a, Object b) { 
		if (a == null || b == null) null
		else multiply(a, b)
	}
		def dispatch multiply(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to multiply «a» * «b»''') }  
		def dispatch multiply(WCallable a, Object b) { a.call("*", b) }
		def dispatch multiply(WollokInteger a, WollokInteger b) { new WollokInteger(a.wrapped * b.wrapped) }
		def dispatch multiply(WollokNumber<?> a, WollokNumber<?> b) { new WollokDouble(a.doubleValue * b.doubleValue) }
		def dispatch multiply(String a, WollokInteger b) { (1..b.wrapped).map[a].join }
		def dispatch multiply(WollokInteger a, String b) { (1..a.wrapped).map[b].join }
	
	@BinaryOperation('/')
	def Object divideOperation(Object a, Object b) { divide(a, b) }
		def dispatch divide(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to divide «a» / «b»''') }  
		def dispatch divide(WCallable a, Object b) { a.call("/", b) }
		def dispatch divide(WollokInteger a, WollokInteger b) { new WollokInteger(a.wrapped / b.wrapped) }
		def dispatch divide(WollokNumber<?> a, WollokNumber<?> b) { new WollokDouble(a.doubleValue / b.doubleValue) }
	
	@BinaryOperation('**')
	def Object raiseOperation(Object a, Object b) { raise(a, b) }
		def dispatch raise(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to raise «a» ** «b»''') }  
		def dispatch raise(WCallable a, Object b) { a.call("**", b) }
		def dispatch raise(WollokInteger a, WollokInteger b) { new WollokInteger((a.wrapped ** b.wrapped) as int) }
		def dispatch raise(WollokNumber<?> a, WollokNumber<?> b) { new WollokDouble(a.doubleValue ** b.doubleValue) }
	
	@BinaryOperation('%')
	def Object moduleOperation(Object a, Object b) { module(a, b) }
		def dispatch module(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to compute module «a» % «b»''' ) }  
		def dispatch module(WCallable a, Object b) { a.call("%", b) }
		def dispatch module(WollokInteger a, WollokInteger b) { new WollokInteger(a.wrapped % b.wrapped) }

	// ********************************************************************************************
	// ** Booleans
	// ********************************************************************************************	
	
	@BinaryOperation('&&')
	def Object andOperation(Object a, Object b) { and(a, b) }  
		def dispatch and(Object a, Object b) { throw new IllegalBinaryOperation(a + " does not understand && operator" ) }
		def dispatch and(WollokObject a, Object b) { a.call("&&", b) }
		def dispatch and(Boolean a, Boolean b) { a && b }
	@BinaryOperation('and')	
	def Object andPhrase(Object a, Object b) { andOperation(a, b)}
	
	@BinaryOperation('||')
	def Object orOperation(Object a, Object b) { or(a, b) }
		def dispatch or(Object a, Object b) { throw new IllegalBinaryOperation(a + " does not understand || operator" ) }  
		def dispatch or(WollokObject a, Object b) { a.call("||", b) }
		def dispatch or(Boolean a, Boolean b) { a || b }
	@BinaryOperation('or')	
	def Object orPhrase(Object a, Object b) { orOperation(a, b)}

	// ********************************************************************************************
	// ** Equality comparisons
	// ********************************************************************************************	
	
	@BinaryOperation('==')
	def Object equalsOperation(Object a, Object b) { 
		if (bothNull(a,b)) true				// Two nulls => they are equal
		else if (noneAreNull(a,b)) a.eq(b) 	// Two not nulls => they can handle => dispatch
		else false							// Only one is null => they aren't equal
	}
		def dispatch eq(Object a, Object b) { a == b }
		def dispatch eq(WCallable a, Object b) { a.call("==", b) }
		def dispatch eq(WollokInteger a, WollokInteger b) { a.wrapped == b.wrapped }
		def dispatch eq(WollokNumber<?> a, WollokNumber<?> b) { a.doubleValue == b.doubleValue }
	
	@BinaryOperation('!=')
	def Object notEqualsOperation(Object a, Object b) {
		if  (bothNull(a,b)) false  				// Two nulls => they are equal => false
		else if (noneAreNull(a,b)) a.neq(b)		// Two not nulls => they can handle => dispatch
		else true 								// Only one is null => they aren't equal
	}	
		def dispatch neq(Object a, Object b) { a != b }
		def dispatch neq(WCallable a, Object b) { a.call("!=", b) }
		def dispatch neq(WollokInteger a, WollokInteger b) { a.wrapped != b.wrapped }
		def dispatch neq(WollokNumber<?> a, WollokNumber<?> b) { a.doubleValue != b.doubleValue }

	@BinaryOperation('===')
	def Object identicalOperation(Object a, Object b) { overloadOr(a, '===', b) [| a === b ] }

	@BinaryOperation('!==')
	def Object notIdenticalOperation(Object a, Object b) { overloadOr(a, '!==', b) [| a !== b ] }
	
	/** 
	 * Tries sending the message to the wollok object so it can be overloading, otherwise the block
	 */
	def protected overloadOr(Object a, String message, Object b, ()=>Object otherwise) {
		if (a instanceof WollokObject)
			try
				return a.call(message, b)
			catch(MessageNotUnderstood e) {
				// not understood, fallback !
			}
		otherwise.apply
	}
	
	// ********************************************************************************************
	// ** Inequality operators
	// ********************************************************************************************	
	
	@BinaryOperation('>=')
	def Boolean greaterOrEqualsOperation(Object a, Object b) { ge(a, b) }  
		def dispatch ge(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to compare «a» >= «b»''') }
		def dispatch ge(WCallable a, Object b) { a.call(">=", b) as Boolean }
		def dispatch ge(WollokInteger a, WollokInteger b) { a.wrapped >= b.wrapped }
		def dispatch ge(WollokNumber<?> a, WollokNumber<?> b) { a.doubleValue >= b.doubleValue }

	@BinaryOperation('<=')
	def Boolean lesserOrEqualsOperation(Object a, Object b) { le(a, b) }
		def dispatch le(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to compare «a» <= «b»''') }  
		def dispatch le(WCallable a, Object b) { a.call("<=", b) as Boolean }
		def dispatch le(WollokInteger a, WollokInteger b) { a.wrapped <= b.wrapped }
		def dispatch le(WollokNumber<?> a, WollokNumber<?> b) { a.doubleValue <= b.doubleValue }

	@BinaryOperation('>')
	def Boolean greaterOperation(Object a, Object b) { gt(a, b) }
		def dispatch gt(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to compare «a» > «b»''') }
		def dispatch gt(WCallable a, Object b) { a.call(">", b) as Boolean }
		def dispatch gt(WollokInteger a, WollokInteger b) { a.wrapped > b.wrapped }
		def dispatch gt(WollokNumber<?> a, WollokNumber<?> b) { a.doubleValue > b.doubleValue }

	@BinaryOperation('<')
	def Boolean lesserOperation(Object a, Object b) { lt(a, b) as Boolean }
		def dispatch lt(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to compare «a» < «b»''') }  
		def dispatch lt(WCallable a, Object b) { a.call("<", b) }
		def dispatch lt(WollokInteger a, WollokInteger b) { a.wrapped < b.wrapped }
		def dispatch lt(WollokNumber<?> a, WollokNumber<?> b) { a.doubleValue < b.doubleValue }
		
	// ********************************************************************************************
	// ** Ranges
	// ********************************************************************************************
	
	@BinaryOperation('..')
	def WollokRange rangeOperation(Object a, Object b) { range(a, b) }
		def dispatch range(Object a, Object b) { throw new IllegalBinaryOperation(a + " does not understand .. operator" ) }  
		def dispatch range(WCallable a, Object b) { a.call("..", b) as WollokRange }
		def dispatch range(WollokInteger a, WollokInteger b) { new WollokRange(a.wrapped .. b.wrapped) }
		def dispatch range(WollokNumber<?> a, WollokNumber<?> b) { throw new IllegalBinaryOperation("Operator .. can only be used for integer numbers") }
}