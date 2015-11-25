package org.uqbar.project.wollok.interpreter.operation

import java.lang.reflect.InvocationTargetException
import java.lang.reflect.Method
import org.uqbar.project.wollok.interpreter.IllegalBinaryOperation
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.core.WCallable
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

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
// I18N !
class WollokDeclarativeNativeBasicOperations implements WollokBasicBinaryOperations {
	
	override asBinaryOperation(String operationSymbol) {
		val op = class.methods.findFirst[hasAnnotationForOperation(operationSymbol)]
		if (op != null) {
			[Object a, ()=>Object b| 
				try {
					op.invoke(this, a, b)
				}
				catch(InvocationTargetException e) {
					throw new WollokRuntimeException('''Error while resolving «a» «operationSymbol» «b»''', e.cause)
				}
			]
		}
		else
			[Object a, ()=>Object b | 
				unknownOperator(a, operationSymbol, b.apply)
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
	def Object sumOperation(Object a, ()=>Object e) {
		val b = e.apply;
		if (a == null) b 
		else if (b == null) a
		else sum(a, b)
	}  
		def dispatch sum(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to add «a» («a.class.simpleName») + «b» («a.class.simpleName»)''') }
		def dispatch sum(WCallable a, Object b) { a.call("+", b) }
	
	def zero(Object nonNull) { minus(nonNull, nonNull) }
	
	@BinaryOperation('-')	
	def Object minusOperation(Object a, ()=>Object eb) {
		val b = eb.apply
		if (a == null) { 
			if (b != null) minus(b.zero, b)
			else null
		}
		else if (b == null) a
		else minus(a, b)
	}
		def dispatch minus(Object a, Object b) { throw new IllegalBinaryOperation('''Unable tu subtract «a» - «b»''') }  
		def dispatch minus(String a, String b) { a.replace(b, "") }
		def dispatch minus(WCallable a, Object b) { a.call("-", b) }
	
	@BinaryOperation('*')  
	def Object multiplyOperation(Object a, ()=>Object eb) { 
		val b = eb.apply
		if (a == null || b == null) null
		else multiply(a, b)
	}
		def dispatch multiply(WCallable a, Object b) { a.call("*", b) }
		def dispatch multiply(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to multiply «a» * «b»''') }
	
	@BinaryOperation('/')
	def Object divideOperation(Object a, ()=>Object eb) { val b = eb.apply; divide(a, b)
	}
		def dispatch divide(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to divide «a» / «b»''') }  
		def dispatch divide(WCallable a, Object b) { a.call("/", b) }
	
	@BinaryOperation('**')
	def Object raiseOperation(Object a, ()=>Object eb) { val b = eb.apply; raise(a, b) }
		def dispatch raise(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to raise «a» ** «b»''') }  
		def dispatch raise(WCallable a, Object b) { a.call("**", b) }
	
	@BinaryOperation('%')
	def Object moduleOperation(Object a, ()=>Object eb) { val b = eb.apply; module(a, b) }
		def dispatch module(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to compute module «a» % «b»''' ) }  
		def dispatch module(WCallable a, Object b) { a.call("%", b) }

	// ********************************************************************************************
	// ** Booleans
	// ********************************************************************************************	
	
	@BinaryOperation('&&')
	def Object andOperation(Object a, ()=>Object b) { and(a, b) }  
		def dispatch and(Object a, ()=>Object b) { throw new IllegalBinaryOperation('''«a»(«a.class.simpleName») does not understand && operator''') }
		//TODO: hack we are sending the xtend closure here to the wollok object for shortcircuit
		//   the WBoolean implementation. If someone overloads the && message he will receive this 
		//   non-wollok object. I think that we should send a WollokClosure
		//   or have some language-level construction for "lazy" parameters
		def dispatch and(WCallable a, ()=>Object b) { a.call("&&", b) }
	@BinaryOperation('and')	
	def Object andPhrase(Object a, ()=>Object b) { andOperation(a, b)}
	
	@BinaryOperation('||')
	def Object orOperation(Object a, ()=>Object b) { or(a, b) }
		def dispatch or(Object a, Object b) { throw new IllegalBinaryOperation(a + " does not understand || operator" ) }
		// TODO: hack we are sending the xtend closure here to the wollok object for shortcircuit
		//   the WBoolean implementation. If someone overloads the && message he will receive this 
		//   non-wollok object. I think that we should send a WollokClosure
		//   or have some language-level construction for "lazy" parameters  
		def dispatch or(WCallable a, ()=>Object b) { a.call("||", b) }
	@BinaryOperation('or')	
	def Object orPhrase(Object a, ()=>Object b) { orOperation(a, b)}

	// ********************************************************************************************
	// ** Equality comparisons
	// ********************************************************************************************	
	
	@BinaryOperation('==')
	def Object equalsOperation(Object a, ()=>Object eb) {
		val b = eb.apply 
		if (bothNull(a,b)) true				// Two nulls => they are equal
		else if (noneAreNull(a,b)) a.eq(b) 	// Two not nulls => they can handle => dispatch
		else false							// Only one is null => they aren't equal
	}
		def dispatch eq(Object a, Object b) { a == b }
		def dispatch eq(WCallable a, Object b) { a.call("==", b) }
	
	@BinaryOperation('!=')
	def Object notEqualsOperation(Object a, ()=>Object eb) {
		val b = eb.apply
		if  (bothNull(a,b)) false  				// Two nulls => they are equal => false
		else if (noneAreNull(a,b)) a.neq(b)		// Two not nulls => they can handle => dispatch
		else true 								// Only one is null => they aren't equal
	}	
		def dispatch neq(Object a, Object b) { a != b }
		def dispatch neq(WCallable a, Object b) { a.call("!=", b) }

	@BinaryOperation('===')
	def Object identicalOperation(Object a, ()=>Object eb) { val b = eb.apply; overloadOr(a, '===', b) [| a === b ] }

	@BinaryOperation('!==')
	def Object notIdenticalOperation(Object a, ()=>Object eb) { val b = eb.apply; overloadOr(a, '!==', b) [| a !== b ] }
	
	/** 
	 * Tries sending the message to the wollok object so it can be overloading, otherwise the block
	 */
	def protected overloadOr(Object a, String message, Object b, ()=>Object otherwise) {
		if (a instanceof WollokObject)
			try
				return a.call(message, b)
			catch (WollokProgramExceptionWrapper e) {
				// if it's message not understood then ok, default to the closure
				if (!e.isMessageNotUnderstood)
					throw e
			}
		otherwise.apply
	}
	
	// ********************************************************************************************
	// ** Inequality operators
	// ********************************************************************************************	

	@BinaryOperation('>=')
	def greaterOrEqualsOperation(Object a, ()=>Object eb) { val b = eb.apply; ge(a, b) }  
		def dispatch ge(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to compare «a» >= «b»''') }
		def dispatch ge(WCallable a, Object b) { a.call(">=", b) }

	@BinaryOperation('<=')
	def lesserOrEqualsOperation(Object a, ()=>Object eb) { val b = eb.apply; le(a, b) }
		def dispatch le(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to compare «a» <= «b»''') }  
		def dispatch le(WCallable a, Object b) { a.call("<=", b) }

	@BinaryOperation('>')
	def greaterOperation(Object a, ()=>Object eb) { val b = eb.apply; gt(a, b) }
		def dispatch gt(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to compare «a» > «b»''') }
		def dispatch gt(WCallable a, Object b) { a.call(">", b) }

	@BinaryOperation('<')
	def lesserOperation(Object a, ()=>Object eb) { val b = eb.apply; lt(a, b) }
		def dispatch lt(Object a, Object b) { throw new IllegalBinaryOperation('''Unable to compare «a» < «b»''') }  
		def dispatch lt(WCallable a, Object b) { a.call("<", b) }
		
	// ********************************************************************************************
	// ** Ranges
	// ********************************************************************************************
	
	@BinaryOperation('..')
	def rangeOperation(Object a, ()=>Object eb) { val b = eb.apply; range(a, b) }
		def dispatch range(Object a, Object b) { throw new IllegalBinaryOperation(a + " does not understand .. operator" ) }  
		def dispatch range(WCallable a, Object b) { a.call("..", b) }
}