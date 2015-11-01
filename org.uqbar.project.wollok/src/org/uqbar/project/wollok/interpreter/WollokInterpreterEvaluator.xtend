package org.uqbar.project.wollok.interpreter

import com.google.inject.Inject
import java.lang.ref.WeakReference
import java.util.List
import java.util.Map
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.api.XInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.core.CallableSuper
import org.uqbar.project.wollok.interpreter.core.WCallable
import org.uqbar.project.wollok.interpreter.core.WollokClosure
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper
import org.uqbar.project.wollok.interpreter.operation.WollokBasicBinaryOperations
import org.uqbar.project.wollok.interpreter.operation.WollokBasicUnaryOperations
import org.uqbar.project.wollok.interpreter.operation.WollokDeclarativeNativeBasicOperations
import org.uqbar.project.wollok.interpreter.operation.WollokDeclarativeNativeUnaryOperations
import org.uqbar.project.wollok.interpreter.stack.ReturnValueException
import org.uqbar.project.wollok.interpreter.stack.VoidObject
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
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WNullLiteral
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.wollokDsl.WSetLiteral
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WThis
import org.uqbar.project.wollok.wollokDsl.WThrow
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WUnaryOperation
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage

import static extension org.uqbar.project.wollok.WollokDSLKeywords.*
import static extension org.uqbar.project.wollok.interpreter.context.EvaluationContextExtensions.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

/**
 * It's the real "interpreter".
 * This object implements the logic to evaluate all Expression's and programs elements.
 * WollokInterpreter provides the execution logic and control flow.
 * This one is the one that has all the particular evaluation implementations
 * for each element.
 * 
 * @author jfernandes
 */
class WollokInterpreterEvaluator implements XInterpreterEvaluator {
	extension WollokBasicBinaryOperations = new WollokDeclarativeNativeBasicOperations
	extension WollokBasicUnaryOperations = new WollokDeclarativeNativeUnaryOperations
	
	// caches
	var Map<String, WeakReference<Object>> numbersCache = newHashMap
	@Inject
	WollokInterpreter interpreter
	@Inject
	WollokQualifiedNameProvider qualifiedNameProvider
	@Inject WollokClassFinder classFinder
	
	/* HELPER METHODS */
	/** helper method to evaluate an expression going all through the interpreter and back here. */
	protected def eval(EObject e) { interpreter.eval(e) }

	protected def evalAll(Iterable<? extends EObject> all) { all.fold(null)[a, e|e.eval] }

	protected def Object[] evalEach(EList<WExpression> e) { e.map[eval] }

	/* BINARY */
	override resolveBinaryOperation(String operator) { operator.asBinaryOperation }

	// EVALUATIONS (as multimethods)
	def dispatch Object evaluate(WFile it) { 
		// Files should are not allowed to have both a main program and tests at the same time.
		if (main != null) main.eval else tests.evalAll
	}

	def dispatch Object evaluate(WClass it) {}
	def dispatch Object evaluate(WPackage it) {}
	def dispatch Object evaluate(WProgram it) { elements.evalAll }
	def dispatch Object evaluate(WTest it) { elements.evalAll }


	def dispatch Object evaluate(WVariableDeclaration it) {
		if(it.eContainer instanceof WProgram){
			interpreter.addProgramVariable(variable)
		}
		interpreter.currentContext.addReference(variable.name, right?.eval)
	}

	def dispatch Object evaluate(WVariableReference it) {
		if (ref instanceof WNamedObject)
			ref.eval
		else
			interpreter.currentContext.resolve(ref.name)
	}

	def dispatch Object evaluate(WIfExpression it) {
		val cond = condition.eval
		// I18N !
		if (!(cond instanceof Boolean)) throw new WollokInterpreterException(
			"Expression in 'if' must evaluate to a boolean. Instead got: " + cond, it)
		if (Boolean.TRUE == cond)
			then.eval
		else
			^else?.eval
	}

	def dispatch Object evaluate(WTry t) {
		try
			t.expression.eval
		catch (WollokProgramExceptionWrapper e) {
			val cach = t.catchBlocks.findFirst[c|c.matches(e.wollokException)]
			if (cach != null) {
				val context = cach.createEvaluationContext(e.wollokException).then(interpreter.currentContext)
				interpreter.performOnStack(cach, context) [|
					cach.expression.eval
				]
			} else
				throw e
		} finally
			t.alwaysExpression?.eval
	}

	def createEvaluationContext(WCatch wCatch, WollokObject exception) {
		createEvaluationContext(wCatch.exceptionVarName.name, exception)
	}

	def dispatch Object evaluate(WThrow t) {
		// this must be checked!
		val obj = t.exception.eval as WollokObject
		throw new WollokProgramExceptionWrapper(obj)
	}

	def boolean matches(WCatch cach, WollokObject exceptionThrown) { exceptionThrown.isKindOf(cach.exceptionType) }

	// literals
	def dispatch Object evaluate(WStringLiteral it) { newInstanceWithWrapped("wollok.lang.WString", value) }

	def dispatch Object evaluate(WBooleanLiteral it) { isTrue }

	def dispatch Object evaluate(WNullLiteral it) { null }

	def dispatch Object evaluate(WNumberLiteral it) { value.orCreateNumber }
	
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
	
	def <T> newInstanceWithWrapped(String className, T wrapped) {
		newInstance(className) => [
			val JavaWrapper<T> native = getNativeObject(className)
			native.wrapped = wrapped
		]
	}
	
	def instantiateNumber(String value) {
		if (value.contains('.'))
			doInstantiateNumber("wollok.lang.WDouble", Double.valueOf(value)) 
		else {
			doInstantiateNumber("wollok.lang.WInteger", Integer.valueOf(value))
		}
	}
	
	def doInstantiateNumber(String className, Object value) {
		val obj = newInstance(className)
		// hack because this project doesn't depend on wollok.lib project so we don't see the classes !
		val intNative = obj.nativeObjects.values.findFirst[it.class.name == className] as JavaWrapper
		intNative.wrapped = value
		obj
	}

	def dispatch Object evaluate(WObjectLiteral l) {
		new WollokObject(interpreter, l) => [l.members.forEach[m|addMember(m)]]
	}
	
	def dispatch Object evaluate(WReturnExpression it) {
		throw new ReturnValueException(expression.eval)
	}

	def dispatch Object evaluate(WConstructorCall call) {
		// hook the implicit relation "* extends Object*
		newInstance(call.classRef, call.arguments.evalEach)
	}
	
	def newInstance(String classFQN, Object... arguments) {
		newInstance(classFinder.searchClass(classFQN, interpreter.evaluating), arguments)
	}
	
	def newInstance(WClass classRef, Object... arguments) {
		classRef.hookToObject(classFinder)
		
		new WollokObject(interpreter, classRef) => [ wo |
			classRef.superClassesIncludingYourselfTopDownDo [
				addMembersTo(wo)
				if(native) wo.nativeObjects.put(it, createNativeObject(wo, interpreter))
			]
			wo.invokeConstructor(arguments.map[javaToWollok].toArray)
		]
	}
	
	def static void hookToObject(WClass wClass, WollokClassFinder finder) {
		if (wClass.parent != null)
			wClass.parent.hookToObject(finder)
		else {
			val object = finder.getObjectClass(wClass)
			if (wClass.fqn != object.fqn) { 
				wClass.parent = object
				wClass.eSet(WollokDslPackage.Literals.WCLASS__PARENT, object)
			}
		}
	}
	
	def dispatch Object evaluate(WNamedObject namedObject) {
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
		namedObject.hookObjectInHierarhcy(classFinder)
		
		new WollokObject(interpreter, namedObject) => [ wo |
			namedObject.members.forEach[wo.addMember(it)]
			
			namedObject.parent.superClassesIncludingYourselfTopDownDo [
				addMembersTo(wo)
				if(native) wo.nativeObjects.put(it, createNativeObject(wo, interpreter))
			]
			
			if (namedObject.native)
				wo.nativeObjects.put(namedObject, namedObject.createNativeObject(wo,interpreter))

			if (namedObject.parentParameters != null && !namedObject.parentParameters.empty)
				wo.invokeConstructor(namedObject.parentParameters.evalEach)
			
			interpreter.currentContext.addGlobalReference(qualifiedName, wo)
		]
	}
	
	def static hookObjectInHierarhcy(WNamedObject namedObject, WollokClassFinder finder) {
		if (namedObject.parent != null)
			namedObject.parent.hookToObject(finder)
		else {
			val object = finder.getObjectClass(namedObject)
			namedObject.parent = object
			namedObject.eSet(WollokDslPackage.Literals.WNAMED_OBJECT__PARENT, object)
		}
	}

	def dispatch Object evaluate(WClosure l) { new WollokClosure(l, interpreter) }

	def dispatch Object evaluate(WListLiteral l) { createCollection("wollok.lang.WList", l.elements) }
	def dispatch Object evaluate(WSetLiteral l) { createCollection("wollok.lang.WSet", l.elements) }
//	def dispatch Object evaluate(WSetLiteral l) { new WollokSet(interpreter, newHashSet(l.elements.map[eval].toArray)) }
	// TODO create a WSET
	
	def createCollection(String collectionName, List<WExpression> elements) {
		this.newInstance(collectionName) => [
			elements.forEach[e| 
				call("add", e.eval)
			]
		]
	}

	// other expressions
	def dispatch Object evaluate(WBlockExpression b) { b.expressions.evalAll }

	def dispatch Object evaluate(WAssignment a) {
		val newValue = a.value.eval
		
		if(newValue instanceof VoidObject)
			// i18n
			throw new WollokInterpreterException("No se puede asignar el valor de retorno de un mensaje que no devuelve nada", a)
		
		interpreter.currentContext.setReference(a.feature.ref.name, newValue)
		newValue
	}

	// ********************************************************
	// ** operations (unary, binary, multiops, postfix)
	// ********************************************************
	def dispatch Object evaluate(WBinaryOperation binary) {
		if (binary.feature.isMultiOpAssignment) {
			val operator = binary.feature.substring(0, 1)
			val reference = binary.leftOperand

			reference.performOpAndUpdateRef(operator, binary.rightOperand.lazyEval)
		} else
			binary.feature.asBinaryOperation.apply(binary.leftOperand.eval, binary.rightOperand.lazyEval)
	}
	
	def lazyEval(EObject expression) {
		[| expression.eval ]
	}

	def dispatch Object evaluate(WPostfixOperation op) {
		// if we start to "box" numbers into wollok objects, this "1" will then change to find the wollok "1" object-
		op.operand.performOpAndUpdateRef(op.feature.substring(0, 1), [| instantiateNumber("1") ])
	}

	/** 
	 * A method reused between opmulti and post fix. Since it performs an binary operation applied
	 * to a reference, and then updates the value in the context (think of +=, or ++, they have common behaviors)
	 */
	def performOpAndUpdateRef(WExpression reference, String operator, ()=>Object rightPart) {
		val newValue = operator.asBinaryOperation.apply(reference.eval, rightPart)
		interpreter.currentContext.setReference((reference as WVariableReference).ref.name, newValue)
		newValue
	}

	def dispatch Object evaluate(WUnaryOperation oper) { oper.feature.asUnaryOperation.apply(oper.operand.eval) }

	def dispatch Object evaluate(WThis t) { interpreter.currentContext.thisObject }

	// member call
	def dispatch Object evaluate(WFeatureCall call) {
		try {
			call.evaluateTarget.perform(call.feature, call.memberCallArguments.evalEach)
		} catch (MessageNotUnderstood e) {
			e.pushStack(call)
			throw e
		}
	}

	// ********************************************************************************************
	// ** HELPER FOR message sends
	// ********************************************************************************************
	
	def dispatch evaluateTarget(WFeatureCall call) { throw new UnsupportedOperationException("Should not happen") }

	def dispatch evaluateTarget(WMemberFeatureCall call) { call.memberCallTarget.eval }

	def dispatch evaluateTarget(WSuperInvocation call) {
		new CallableSuper(interpreter, call.method.declaringContext.parent)
	}

	// ********************************************************************************************
	// ** Member call with multiple dispatch to handle WollokObjects as well as primitive types
	// ********************************************************************************************

	def perform(Object target, String message, Object... args) {
		target.call(message, args)
	}

	def dispatch Object call(WCallable target, String message, Object... args) { target.call(message, args) }

	/** @deprecated creo que esto no tiene sentido si incluimos los objetos nativos wrappeados en WCallable */
	def dispatch Object call(Object target, String message, Object... args) {
		// hack while we still have some java objects being published and used in the wollok world.
		// for example java.lang.String's and booleans
		var messageName = message
		var arguments = args
		if (message == "toSmartString") {
			messageName = "toString"
			arguments = #[]
		} 
		val r = target.invoke(messageName, arguments)
		if (r != null)
			WollokInterpreterAccess.INSTANCE.asWollokObject(r)
		else
			r
	}
}
