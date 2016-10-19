package org.uqbar.project.wollok.interpreter

import com.google.inject.Inject
import java.lang.ref.WeakReference
import java.math.BigDecimal
import java.math.BigInteger
import java.util.List
import java.util.Map
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.api.XInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.context.UnresolvableReference
import org.uqbar.project.wollok.interpreter.core.CallableSuper
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper
import org.uqbar.project.wollok.interpreter.nativeobj.NodeAware
import org.uqbar.project.wollok.interpreter.natives.NativeObjectFactory
import org.uqbar.project.wollok.interpreter.operation.WollokBasicBinaryOperations
import org.uqbar.project.wollok.interpreter.operation.WollokBasicUnaryOperations
import org.uqbar.project.wollok.interpreter.operation.WollokDeclarativeNativeBasicOperations
import org.uqbar.project.wollok.interpreter.operation.WollokDeclarativeNativeUnaryOperations
import org.uqbar.project.wollok.interpreter.stack.ReturnValueException
import org.uqbar.project.wollok.scoping.WollokQualifiedNameProvider
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WCatch
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WFeatureCall
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WListLiteral
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WNullLiteral
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WSelf
import org.uqbar.project.wollok.wollokDsl.WSetLiteral
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WThrow
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WUnaryOperation
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.sdk.WollokDSK.*

import static extension org.uqbar.project.wollok.WollokConstants.*
import static extension org.uqbar.project.wollok.interpreter.context.EvaluationContextExtensions.*
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.xtext.utils.XTextExtensions.sourceCode

/**
 * It's the real "interpreter".
 * This object implements the logic to evaluate all Expression's and programs elements.
 * WollokInterpreter provides the execution logic and control flow.
 * This one is the one that has all the particular evaluation implementations
 * for each element.
 *
 * @author jfernandes
 */
class WollokInterpreterEvaluator implements XInterpreterEvaluator<WollokObject> {
	extension WollokBasicBinaryOperations = new WollokDeclarativeNativeBasicOperations
	extension WollokBasicUnaryOperations = new WollokDeclarativeNativeUnaryOperations

	// caches
	var Map<String, WeakReference<WollokObject>> numbersCache = newHashMap
	var WollokObject trueObject
	var WollokObject falseObject

	@Inject	protected WollokInterpreter interpreter
	@Inject	WollokQualifiedNameProvider qualifiedNameProvider
	@Inject WollokClassFinder classFinder
	@Inject extension NativeObjectFactory nativesFactory

	/* HELPER METHODS */
	/** helper method to evaluate an expression going all through the interpreter and back here. */
	protected def eval(EObject e) { interpreter.eval(e) }

	protected def evalAll(Iterable<? extends EObject> all) { all.fold(null)[a, e|e.eval] }

	protected def WollokObject[] evalEach(EList<WExpression> e) { e.map[eval] }

	/* BINARY */
	override resolveBinaryOperation(String operator) { operator.asBinaryOperation }

	// EVALUATIONS (as multimethods)
	def dispatch evaluate(WFile it) {
		// Files are not allowed to have both a main program and tests at the same time.
		if (main != null) main.eval else tests.evalAll
	}

	def dispatch evaluate(WClass it) {}
	def dispatch evaluate(WPackage it) {}
	def dispatch evaluate(WProgram it) { elements.evalAll }
	def dispatch evaluate(WTest it) { elements.evalAll }


	def dispatch evaluate(WVariableDeclaration it) {
		interpreter.currentContext.addReference(variable.name, right?.eval)
	}

	def dispatch evaluate(WVariableReference it) {
		if (ref instanceof WNamedObject)
			ref.eval
		else
			interpreter.currentContext.resolve(ref.name)
	}



	def dispatch evaluate(WIfExpression it) {
		val cond = condition.eval

		// I18N !
		if (cond == null) {
			throw newWollokExceptionAsJava('''Cannot use null in 'if' expression''')
		}
		if (!(cond.isWBoolean))
			throw new WollokInterpreterException('''Expression in 'if' must evaluate to a boolean. Instead got: «cond» («cond?.class.name»)''', it)
		if (wollokToJava(cond, Boolean) == Boolean.TRUE)
			then.eval
		else
			^else?.eval
	}

	def dispatch evaluate(WTry t) {
		try
			t.expression.eval
		catch (WollokProgramExceptionWrapper e) {
			val cach = t.catchBlocks.findFirst[ it.matches(e.wollokException) ]
			if (cach != null) {
				cach.evaluate(e)
			} else
				throw e
		} finally
			t.alwaysExpression?.eval
	}

	def evaluate(WCatch it, WollokProgramExceptionWrapper e) {
		val context = createEvaluationContext(e.wollokException).then(interpreter.currentContext)
		interpreter.performOnStack(it, context) [|
			expression.eval
		]
	}

	def createEvaluationContext(WCatch wCatch, WollokObject exception) {
		createEvaluationContext(wCatch.exceptionVarName.name, exception)
	}

	def dispatch evaluate(WThrow t) {
		// this must be checked!
		val obj = t.exception.eval as WollokObject
		throw new WollokProgramExceptionWrapper(obj, t)
	}

	def boolean matches(WCatch cach, WollokObject it) { cach.exceptionType == null || isKindOf(cach.exceptionType) }

	// literals
	def dispatch evaluate(WStringLiteral it) { newInstanceWithWrapped(STRING, value) }

	def dispatch evaluate(WBooleanLiteral it) { booleanValue(it.isIsTrue) }

	def dispatch evaluate(WNullLiteral it) { null }

	def dispatch evaluate(WNumberLiteral it) { value.orCreateNumber }

	def getOrCreateNumber(String value) {
		if (numbersCache.containsKey(value) && numbersCache.get(value).get != null) {
			numbersCache.get(value).get
		}
		else {
			val n = instantiateNumber(value)
			numbersCache.put(value, new WeakReference(n))
			n
		}
	}

	def booleanValue(boolean isTrue) {
		if (isTrue) {
			if (trueObject == null)
				trueObject = newInstanceWithWrapped(BOOLEAN, isTrue)
			return trueObject
		}
		else {
			if (falseObject == null)
				falseObject = newInstanceWithWrapped(BOOLEAN, isTrue)
			return falseObject
		}
	}

	def theTrue() { booleanValue(true) }
	def theFalse() { booleanValue(false) }

	def <T> newInstanceWithWrapped(String className, T wrapped) {
		newInstance(className) => [
			val JavaWrapper<T> native = getNativeObject(className)
			native.wrapped = wrapped
		]
	}

	def instantiateNumber(String value) {
		if (value.contains('.'))
			doInstantiateNumber(DOUBLE, new BigDecimal(value))
		else {
			doInstantiateNumber(INTEGER, Integer.valueOf(value))
		}
	}

	def doInstantiateNumber(String className, Object value) {
		val obj = newInstance(className)
		// hack because this project doesn't depend on wollok.lib project so we don't see the classes !
		val intNative = obj.getNativeObject(className) as JavaWrapper<Object>
		intNative.wrapped = value
		obj
	}

	def dispatch evaluate(WObjectLiteral l) {
		new WollokObject(interpreter, l) => [ wo |
			l.addObjectMembers(wo)
			l.parent.addInheritsMembers(wo)
			l.addMixinsMembers(wo)
		]
	}
	
	def addObjectMembers(WMethodContainer it, WollokObject wo) {
		members.forEach[wo.addMember(it)]
	}
	
	def addInheritsMembers(WClass it, WollokObject wo) {
		superClassesIncludingYourselfTopDownDo [
			addMembersTo(wo)
			if(native) wo.nativeObjects.put(it, createNativeObject(wo, interpreter))
		]
	}
	
	def addMixinsMembers(WMethodContainer it, WollokObject wo) {
		mixins.forEach[addMembersTo(wo)]
	}

	def dispatch evaluate(WReturnExpression it) {
		throw new ReturnValueException(expression.eval)
	}

	def dispatch evaluate(WConstructorCall call) {
		// hook the implicit relation "* extends Object*
		newInstance(call.classRef, call.arguments.evalEach)
	}

	def newInstance(String classFQN, WollokObject... arguments) {
		newInstance(classFinder.searchClass(classFQN, interpreter.evaluating), arguments)
	}

	def newInstance(WClass classRef, WollokObject... arguments) {
		new WollokObject(interpreter, classRef) => [ wo |
			classRef.addInheritsMembers(wo)
			classRef.addMixinsMembers(wo)
			
			wo.invokeConstructor(arguments.toArray(newArrayOfSize(arguments.size)))
		]
	}

	def dispatch evaluate(WNamedObject namedObject) {
		val qualifiedName = qualifiedNameProvider.getFullyQualifiedName(namedObject).toString

		val x = try {
			interpreter.currentContext.resolve(qualifiedName)
		}
		catch (UnresolvableReference e) {
			createNamedObject(namedObject, qualifiedName)
		}
		x
	}

	def createNamedObject(WNamedObject namedObject, String qualifiedName) {
		new WollokObject(interpreter, namedObject) => [ wo |
			// first add it to solve cross-refs !
			interpreter.currentContext.addGlobalReference(qualifiedName, wo)
			try {
				namedObject.addObjectMembers(wo)
				namedObject.parent.addInheritsMembers(wo)
				namedObject.addMixinsMembers(wo)
	
				if (namedObject.native)
					wo.nativeObjects.put(namedObject, namedObject.createNativeObject(wo,interpreter))
	
				if (namedObject.parentParameters != null && !namedObject.parentParameters.empty)
					wo.invokeConstructor(namedObject.parentParameters.evalEach)
			}
			catch (RuntimeException e) {
				// if init failed remove it !
				interpreter.currentContext.removeGlobalReference(qualifiedName)
				throw e
			}
		]
	}

	def dispatch evaluate(WClosure l) { newInstance(CLOSURE) => [
		(getNativeObject(CLOSURE) as NodeAware<WClosure>).EObject = l
	] }

	def dispatch evaluate(WListLiteral it) { createCollection(LIST, elements) }
	def dispatch evaluate(WSetLiteral it) { createCollection(SET, elements) }

	def createCollection(String collectionName, List<WExpression> elements) {
		newInstance(collectionName) => [
			elements.forEach[e|
				call("add", e.eval)
			]
		]
	}

	// other expressions
	def dispatch evaluate(WBlockExpression b) { b.expressions.evalAll }

	def dispatch evaluate(WAssignment a) {
		val newValue = a.value.eval
		interpreter.currentContext.setReference(a.feature.ref.name, newValue)
		newValue
	}

	// ********************************************************
	// ** operations (unary, binary, multiops, postfix)
	// ********************************************************
	def dispatch evaluate(WBinaryOperation binary) {
		if (binary.isMultiOpAssignment) {
			val operator = binary.feature.substring(0, 1)
			val reference = binary.leftOperand
			reference.performOpAndUpdateRef(operator, binary.rightOperand.lazyEval)
		} else {
			val leftOperand = binary.leftOperand.eval
			val operation = binary.feature
			validateNullOperand(leftOperand, operation)
			operation.asBinaryOperation.apply(leftOperand, binary.rightOperand.lazyEval)
				// this is just for the null == null comparisson. Otherwise is re-retrying to convert
				.javaToWollok
		}
			
	}
	
	private def validateNullOperand(WollokObject leftOperand, String operation) {
		if (leftOperand == null && !#["==","!="].contains(operation)) {
			throw newWollokExceptionAsJava('''Cannot send message «operation» to null''')
		}
	}

	def lazyEval(EObject expression) {
		val lazyContext = interpreter.currentContext
		return [| 
			interpreter.performOnStack(expression, lazyContext, [| expression.eval])
		]
	}

	def dispatch evaluate(WPostfixOperation op) {
		op.operand.performOpAndUpdateRef(op.feature.substring(0, 1), [| getOrCreateNumber("1") ])
	}

	/**
	 * A method reused between opmulti and post fix. Since it performs an binary operation applied
	 * to a reference, and then updates the value in the context (think of +=, or ++, they have common behaviors)
	 */
	def performOpAndUpdateRef(WExpression reference, String operator, ()=>WollokObject rightPart) {
		val newValue = operator.asBinaryOperation.apply(reference.eval, rightPart).javaToWollok
		interpreter.currentContext.setReference((reference as WVariableReference).ref.name, newValue)
		newValue
	}

	def dispatch evaluate(WUnaryOperation oper) {
		val operation = oper.feature
		val leftOperand = oper.operand.eval
		validateNullOperand(leftOperand, operation) 
		operation.asUnaryOperation.apply(leftOperand) 
	}

	def dispatch evaluate(WSelf t) { interpreter.currentContext.thisObject }

	// member call
	def dispatch evaluate(WFeatureCall call) {
		val target = call.evaluateTarget
		if (target == null)
			throw newWollokExceptionAsJava('''Cannot send message «call.feature»(«call.memberCallArguments.map[sourceCode].join(',')») to null''')
		target.call(call.feature, call.memberCallArguments.evalEach)
	}

	// ********************************************************************************************
	// ** HELPER FOR message sends
	// ********************************************************************************************

	def dispatch evaluateTarget(WFeatureCall call) { throw new UnsupportedOperationException("Should not happen") }
	def dispatch evaluateTarget(WMemberFeatureCall call) { call.memberCallTarget.eval }
	def dispatch evaluateTarget(WSuperInvocation call) { new CallableSuper(interpreter, call.declaringContext) }

	def WollokObject getWKObject(String qualifiedName, EObject context) {
		try {
			interpreter.currentContext.resolve(qualifiedName)
		}
		catch (UnresolvableReference e) {
			createNamedObject(classFinder.getCachedObject(context, qualifiedName), qualifiedName)
		}
	}

}
