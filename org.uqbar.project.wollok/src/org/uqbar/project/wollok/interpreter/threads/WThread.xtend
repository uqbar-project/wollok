package org.uqbar.project.wollok.interpreter.threads

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.WollokSourcecodeLocator
import org.uqbar.project.wollok.interpreter.api.XThread
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.interpreter.stack.ObservableStack
import org.uqbar.project.wollok.interpreter.stack.ReturnValueException
import org.uqbar.project.wollok.interpreter.stack.XStackFrame

import static org.uqbar.project.wollok.sdk.WollokSDK.*

/**
 * This class represents the threads in the execution of the interpreter, 
 * however the implementation is still very crude. 
 * 
 * It only keeps the call stack, and also it is created when it is accessed. 
 * The rest of the interpreter is still no multithreading.
 * 
 * Now is returning a different WThread per Java Thread.
 * 
 * @author tesonep
 * 
 */

class WThread implements XThread<WollokObject> {
	var executionStack = new ObservableStack<XStackFrame<WollokObject>>
	boolean instantiatingStackOverFlow = false
	val WollokInterpreter interpreter 
	
	new(WollokInterpreter interpreter){
		this.interpreter = interpreter
	}
	
	override getStack() { executionStack }
	
	def getCurrentContext() { stack.peek.context }
	
	def void initStack() {
		executionStack = new ObservableStack<XStackFrame<WollokObject>>
	}	

	def WollokObject performOnStack(EObject executable, EvaluationContext<WollokObject> newContext,
		()=>WollokObject something) {
		stack.push(new XStackFrame(executable, newContext, WollokSourcecodeLocator.INSTANCE))
		try {
			return something.apply
		}
		catch (ReturnValueException e)
			return e.value
		catch (StackOverflowError e) {
			instantiatingStackOverFlow = true
			val exp = (interpreter.evaluator as WollokInterpreterEvaluator).newInstance(STACK_OVERFLOW_EXCEPTION)
			instantiatingStackOverFlow = false
			throw new WollokProgramExceptionWrapper(exp)
		} finally {
			stack.pop
		}
	}
	
}