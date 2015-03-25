package org.uqbar.project.wollok.interpreter

import com.google.inject.Inject
import java.io.Serializable
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.api.XDebugger
import org.uqbar.project.wollok.interpreter.api.XInterpreter
import org.uqbar.project.wollok.interpreter.api.XInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.core.WollokNativeLobby
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.interpreter.debugger.XDebuggerOff
import org.uqbar.project.wollok.interpreter.stack.ObservableStack
import org.uqbar.project.wollok.interpreter.stack.ReturnValueException
import org.uqbar.project.wollok.interpreter.stack.XStackFrame

/**
 * XInterpreter impl for Wollok language.
 * Control's the execution flow and stack.
 * It does not actually have the logic to evaluate expressions.
 * For that it delegates to WollokInterpreterEvaluator.
 * 
 * @author jfernandes
 */
 // Rename to XInterpreter
class WollokInterpreter implements XInterpreter<EObject>, IWollokInterpreter, Serializable {
	static Logger log = Logger.getLogger(WollokInterpreter)
	XDebugger debugger = new XDebuggerOff
	
	val globalVariables = <String,Object>newHashMap
	def getGlobalVariables() { globalVariables }

	override addGlobalReference(String name, Object value) {
		globalVariables.put(name,value)
		value
	}

	@Inject
	XInterpreterEvaluator evaluator

	@Inject
	WollokInterpreterConsole console

	var executionStack = new ObservableStack<XStackFrame>

	static var WollokInterpreter instance = null 

	new() {
		instance = this
	}
	
	def static getInstance(){instance}
	
	def setDebugger(XDebugger debugger) { this.debugger = debugger }
	
	override getStack() { executionStack }
	def getCurrentContext() { stack.peek.context }
	
	// ***********************
	// ** Interprets
	// ***********************
	
	override interpret(EObject rootObject) {
		interpret(rootObject, false)
	}
	
	override interpret(EObject rootObject, Boolean propagatingErrors) {
		try {
			log.debug("Starting interpreter")
			val stackFrame = rootObject.createInitialStackElement
			executionStack.push(stackFrame)
			debugger.started
			
			evaluator.evaluate(rootObject)
		}
		catch (WollokProgramExceptionWrapper e) {
			throw e
		}
		catch (Throwable e)
			if (propagatingErrors)
				throw e
			else{
				console.logError(e)
				null
			}
		finally
			debugger.terminated
	}
	
	def createInitialStackElement(EObject root) {
		new XStackFrame(root, new WollokNativeLobby(console, this))
	}
	
	override performOnStack(EObject executable, EvaluationContext newContext, ()=>Object something) {
		stack.push(new XStackFrame(executable, newContext))
		try 
			return something.apply
		catch(ReturnValueException e){
			return e.value	
		}finally
			stack.pop
	}

	
	def evalBinary(Object a, String operand, Object b) {
		evaluator.resolveBinaryOperation(operand).apply(a, b)
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
			throw ex // a user-level exception, fine !
		} catch (WollokProgramExceptionWrapper ex) {
			throw ex // a user-level exception, fine !
		}
		catch (Exception ex) { // vm exception
			throw new WollokInterpreterException(e, ex)
		}
		finally {
			debugger.evaluated(e)
		}			
	}
	
	def getConsole(){console}

}
