package org.uqbar.project.wollok.interpreter

import com.google.inject.Inject
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.WollokDSLKeywords
import org.uqbar.project.wollok.interpreter.api.XInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.context.MessageNotUnderstood
import org.uqbar.project.wollok.interpreter.context.UnresolvableReference
import org.uqbar.project.wollok.interpreter.core.CallableSuper
import org.uqbar.project.wollok.interpreter.core.WCallable
import org.uqbar.project.wollok.interpreter.core.WollokClosure
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.interpreter.nativeobj.collections.WollokList
import org.uqbar.project.wollok.interpreter.operation.WollokBasicBinaryOperations
import org.uqbar.project.wollok.interpreter.operation.WollokBasicUnaryOperations
import org.uqbar.project.wollok.interpreter.operation.WollokDeclarativeNativeBasicOperations
import org.uqbar.project.wollok.interpreter.operation.WollokDeclarativeNativeUnaryOperations
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
import org.uqbar.project.wollok.wollokDsl.WLibrary
import org.uqbar.project.wollok.wollokDsl.WListLiteral
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WNullLiteral
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WThis
import org.uqbar.project.wollok.wollokDsl.WThrow
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WUnaryOperation
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static extension org.uqbar.project.wollok.interpreter.WollokFeatureCallExtensions.*
import static extension org.uqbar.project.wollok.interpreter.context.EvaluationContextExtensions.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*
import org.uqbar.project.wollok.wollokDsl.WReturnExpression
import org.uqbar.project.wollok.interpreter.stack.ReturnValueException
import org.uqbar.project.wollok.interpreter.stack.VoidObject

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

	@Inject
	WollokInterpreter interpreter

	@Inject
	WollokQualifiedNameProvider qualifiedNameProvider

	/* HELPER METHODS */
	/** helper method to evaluate an expression going all through the interpreter and back here. */
	protected def eval(EObject e) { interpreter.eval(e) }

	protected def evalAll(Iterable<? extends EObject> all) { all.fold(null)[a, e|e.eval] }

	protected def Object[] evalEach(EList<WExpression> e) { e.map[eval] }

	/* BINARY */
	override resolveBinaryOperation(String operator) { operator.asBinaryOperation }

	// EVALUATIONS (as multimethods)
	def dispatch Object evaluate(WFile it) { body.eval }

	// library won't do anything
	def dispatch Object evaluate(WLibrary it) {}

	def dispatch Object evaluate(WClass it) {}

	def dispatch Object evaluate(WPackage it) {}

	// program
	def dispatch Object evaluate(WProgram it) { elements.evalAll }

	// Test
	def dispatch Object evaluate(WTest it) { elements.evalAll }


	def dispatch Object evaluate(WVariableDeclaration it) {
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
		if(!(cond instanceof Boolean)) throw new WollokInterpreterException(
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
	def dispatch Object evaluate(WStringLiteral it) { value }

	def dispatch Object evaluate(WBooleanLiteral it) { isTrue }

	def dispatch Object evaluate(WNullLiteral it) { null }

	def dispatch Object evaluate(WNumberLiteral it) {
		if(value.contains('.')) Double.valueOf(value) else Integer.valueOf(value)
	}

	def dispatch Object evaluate(WObjectLiteral l) {
		new WollokObject(interpreter, l) => [l.members.forEach[m|addMember(m)]]
	}
	
	def dispatch Object evaluate(WReturnExpression it){
		throw new ReturnValueException(expression.eval)
	}

	def dispatch Object evaluate(WConstructorCall call) {
		new WollokObject(interpreter, call.classRef) => [ wo |
			call.classRef.superClassesIncludingYourselfTopDownDo [
				addMembersTo(wo)
				if(native) wo.nativeObject = createNativeObject(wo, interpreter)
			]
			wo.invokeConstructor(call.classRef.constructor, call.arguments.evalEach)
		]
	}

	def dispatch Object evaluate(WNamedObject namedObject) {
		val qualifiedName = qualifiedNameProvider.getFullyQualifiedName(namedObject).toString
		try {
			interpreter.currentContext.resolve(qualifiedName)
		} catch (UnresolvableReference e) {
			new WollokObject(interpreter, namedObject) => [ wo |
				namedObject.members.forEach[wo.addMember(it)]
				if(namedObject.native)
					wo.nativeObject = namedObject.createNativeObject(wo,interpreter)
				interpreter.currentContext.addGlobalReference(qualifiedName, wo)
			]
		}
	}

	def dispatch Object evaluate(WClosure l) { new WollokClosure(l, interpreter) }

	def dispatch Object evaluate(WListLiteral l) {
		new WollokList(interpreter, newArrayList(l.elements.map[eval].toArray))
	}

	// other expressions
	def dispatch Object evaluate(WBlockExpression b) { b.expressions.evalAll }

	def dispatch Object evaluate(WAssignment a) {
		val newValue = a.value.eval
		
		if(newValue instanceof VoidObject)
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
			val rightPart = binary.rightOperand.eval
			reference.performOpAndUpdateRef(operator, rightPart)
		} else
			binary.feature.asBinaryOperation.apply(binary.leftOperand.eval, binary.rightOperand.eval)
	}

	def static isMultiOpAssignment(String operator) { operator.matches(WollokDSLKeywords.MULTIOPS_REGEXP) }

	def dispatch Object evaluate(WPostfixOperation op) {

		// if we start to "box" numbers into wollok objects, this "1" will then change to find the wollok "1" object-
		performOpAndUpdateRef(op.operand, op.feature.substring(0, 1), 1)
	}

	/** 
	 * A method reused between opmulti and post fix. Since it performs an binary operation applied
	 * to a reference, and then updates the value in the context (think of +=, or ++, they have common behaviors)
	 */
	def performOpAndUpdateRef(WExpression reference, String operator, Object rightPart) {
		val newValue = operator.asBinaryOperation.apply(reference.eval, rightPart)
		interpreter.currentContext.setReference((reference as WVariableReference).ref.name, newValue)
		newValue
	}

	def dispatch Object evaluate(WUnaryOperation oper) { oper.feature.asUnaryOperation.apply(oper.operand.eval) }

	// member call
	def dispatch Object evaluate(WFeatureCall call) {
		try {
			call.evaluateTarget.perform(call.feature, call.memberCallArguments.evalEach)
		} catch (MessageNotUnderstood e) {
			e.pushStack(call)
			throw e
		}
	}

	// HELPER FOR message sends
	def dispatch evaluateTarget(WFeatureCall call) { throw new UnsupportedOperationException("Should not happen") }

	def dispatch evaluateTarget(WMemberFeatureCall call) { call.memberCallTarget.eval }

	def dispatch evaluateTarget(WSuperInvocation call) {
		new CallableSuper(interpreter, call.method.declaringContext.parent)
	}

	def dispatch Object evaluate(WThis t) { interpreter.currentContext.thisObject }

	// *******************************************
	// ** member call with multiple dispatch to handle WollokObjects as well as primitive types
	// *******************************************
	def perform(Object target, String message, Object... args) {
		target.call(message, args)
	}

	def dispatch Object call(WCallable target, String message, Object... args) { target.call(message, args) }

	/** @deprecated creo que esto no tiene sentido si incluimos los objetos nativos wrappeados en WCallable */
	def dispatch Object call(Object target, String message, Object... args) { target.invoke(message, args) }

}
