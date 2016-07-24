package org.uqbar.project.wollok.interpreter

import com.google.inject.Inject
import com.google.inject.Injector
import java.io.Serializable
import org.apache.commons.logging.Log
import org.apache.commons.logging.LogFactory
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.api.IWollokInterpreter
import org.uqbar.project.wollok.interpreter.api.XDebugger
import org.uqbar.project.wollok.interpreter.api.XInterpreter
import org.uqbar.project.wollok.interpreter.api.XInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.context.UnresolvableReference
import org.uqbar.project.wollok.interpreter.core.WollokNativeLobby
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.interpreter.debugger.XDebuggerOff
import org.uqbar.project.wollok.interpreter.stack.ObservableStack
import org.uqbar.project.wollok.interpreter.stack.ReturnValueException
import org.uqbar.project.wollok.interpreter.stack.XStackFrame

/**
 * XInterpreter impl for Wollok language.
 * Control's the execution flow and stack.
 * It does not actually have the logic to evaluate expressions.
 * For that it delegates to XInterpreterEvaluator.
 * 
 * @author jfernandes
 */
// Rename to XInterpreter and move up to "xinterpreter" project
class WollokInterpreter implements XInterpreter<EObject>, IWollokInterpreter, Serializable {
	static Log log = LogFactory.getLog(WollokInterpreter)
	XDebugger debugger = new XDebuggerOff

	@Accessors val globalVariables = <String, WollokObject>newHashMap

	override addGlobalReference(String name, WollokObject value) {
		globalVariables.put(name, value)
		value
	}

	@Inject
	XInterpreterEvaluator<WollokObject> evaluator

	@Inject
	WollokInterpreterConsole console

	@Inject
	Injector injector

	@Accessors ClassLoader classLoader = WollokInterpreter.classLoader

	var executionStack = new ObservableStack<XStackFrame>

	@Accessors var EObject evaluating

	static var WollokInterpreter instance = null

	@Accessors var Boolean interactive = false

	new() {
		instance = this
	}

	def static getInstance() { instance }

	def getInjector() { injector }

	def getEvaluator() { evaluator }

	def setDebugger(XDebugger debugger) { this.debugger = debugger }

	override getStack() { executionStack }

	override getCurrentContext() { stack.peek.context }

	// ***********************
	// ** Interprets
	// ***********************
	override interpret(EObject rootObject) {
		try {
			interpret(rootObject, false)
		} catch (WollokProgramExceptionWrapper e) {
			// todo: what about "propagating errors?"
			e.wollokException.call("printStackTrace")
			throw e
		}
	}

	override interpret(EObject rootObject, Boolean propagatingErrors) {
		try {
			log.debug("Starting interpreter")
			val stackFrame = rootObject.createInitialStackElement
			executionStack.push(stackFrame)
			debugger.started

			evaluating = rootObject

			evaluator.evaluate(rootObject)

//			evaluating = null
		} catch (WollokProgramExceptionWrapper e) {
			throw e
		} catch (Throwable e)
			if (propagatingErrors)
				throw e
			else {
				console.logError(e)
				null
			}
		finally
			debugger.terminated
	}

	def createInitialStackElement(EObject root) {
		new XStackFrame(root, new WollokNativeLobby(console, this), WollokSourcecodeLocator.INSTANCE)
	}

	override performOnStack(EObject executable, EvaluationContext<WollokObject> newContext,
		()=>WollokObject something) {
		stack.push(new XStackFrame(executable, newContext, WollokSourcecodeLocator.INSTANCE))
		try
			return something.apply
		catch (ReturnValueException e)
			return e.value
		finally
			stack.pop
	}

	def evalBinary(WollokObject a, String operand, WollokObject b) {
		evaluator.resolveBinaryOperation(operand).apply(a, [|b])
	}

	/**
	 * All evaluations must pass through here (interpreter)
	 * Even if you are writing code in the IntepreterEvaluator,
	 * and you already have there the methods to evaluate an expression
	 * don't call them directly on the evaluator.
	 * You must always ask the interpreter to evaluate it.
	 * This way it will pass through the stack and execution flow (like debugging)
	 */
	override eval(EObject e) {
		try {
			stack.peek.defineCurrentLocation = e
			debugger.aboutToEvaluate(e)
			evaluator.evaluate(e)
		} catch (ReturnValueException ex) {
			throw ex // a return
		} catch (WollokProgramExceptionWrapper ex) {
			throw ex // a user-level exception, fine !
		} catch (Exception ex) { // vm exception
			throw new WollokInterpreterException(e, ex)
		} finally {
			debugger.evaluated(e)
		}
	}

	def getConsole() { console }

	def setReference(String variableName, WollokObject value) {
		if (!globalVariables.containsKey(variableName))
			// I18N !
			throw new UnresolvableReference('''Cannot resolve reference «variableName»''')
		else
			globalVariables.put(variableName, value)
	}

	def resolve(String variableName) {
		if (globalVariables.containsKey(variableName))
			return globalVariables.get(variableName)

		// I18N !
		throw new UnresolvableReference('''Cannot resolve reference «variableName»''')
	}
}
