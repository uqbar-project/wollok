package org.uqbar.project.wollok.interpreter

import com.google.inject.Inject
import com.google.inject.Injector
import java.io.Serializable
import java.util.List
import org.apache.commons.logging.Log
import org.apache.commons.logging.LogFactory
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.interpreter.api.IWollokInterpreter
import org.uqbar.project.wollok.interpreter.api.XInterpreter
import org.uqbar.project.wollok.interpreter.api.XInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.api.XInterpreterListener
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.context.UnresolvableReference
import org.uqbar.project.wollok.interpreter.core.WollokNativeLobby
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.interpreter.stack.ReturnValueException
import org.uqbar.project.wollok.interpreter.stack.XStackFrame
import org.uqbar.project.wollok.interpreter.threads.WThread

import static extension org.uqbar.project.wollok.errorHandling.WollokExceptionExtensions.*
import static extension org.uqbar.project.wollok.model.FlowControlExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * XInterpreter impl for Wollok language.
 * Control's the execution flow and stack.
 * It does not actually have the logic to evaluate expressions.
 * For that it delegates to XInterpreterEvaluator.
 * 
 * @author jfernandes
 */
// Rename to XInterpreter and move up to "xinterpreter" project
class WollokInterpreter implements XInterpreter<EObject, WollokObject>, IWollokInterpreter, Serializable {
	static Log log = LogFactory.getLog(WollokInterpreter)
	List<XInterpreterListener> listeners = newArrayList

	@Accessors val globalVariables = <String, WollokObject>newHashMap

	@Inject
	XInterpreterEvaluator<WollokObject> evaluator

	@Inject
	WollokInterpreterConsole console

	@Inject
	Injector injector
	
	@Accessors 
	var EObject rootContext
	
	@Accessors ClassLoader classLoader = WollokInterpreter.classLoader
	static var WollokInterpreter instance = null
	@Accessors var Boolean interactive = false

	val currentThreadHolder = new ThreadLocal<WThread>

	new() {
		instance = this
	}

	def static getInstance() { instance }

	def getInjector() { injector }

	def getEvaluator() { evaluator }

	def addInterpreterListener(XInterpreterListener listener) {
		listeners.add(listener)
	}

	def init(boolean interactive) {
		this.interactive = interactive
		listeners.forEach [ terminated ]	
	}
	
	// ***********************
	// ** Interprets
	// ***********************
	override interpret(EObject rootObject) {
		try {
			interpret(rootObject, false)
		} catch (WollokProgramExceptionWrapper e) {
			// todo: what about "propagating errors?"
			e.printStackTraceInConsole
			throw e
		}
	}
	
	def interpret(List<EObject> eObjects, String folder) {
		try {
			interpret(eObjects, folder, false)
		} catch (WollokProgramExceptionWrapper e) {
			// todo: what about "propagating errors?"
			e.printStackTraceInConsole
			throw e
		}
	}

	def Object interpret(List<EObject> eObjects, String folder, boolean propagatingErrors) {
		try {
			log.debug("Starting interpreter")
			evaluator.evaluateAll(eObjects, folder)
		} catch (WollokProgramExceptionWrapper e) {
			throw e
		} catch (Throwable e) {
			console.logError(e)
			null
		} finally
			listeners.forEach [ terminated ]
	}

	override interpret(EObject rootObject, Boolean propagatingErrors) {
		try {
			log.debug("Starting interpreter")
			rootObject.generateStack
			evaluator.evaluate(rootObject)
		} catch (WollokProgramExceptionWrapper e) {
			throw e
		} catch (Throwable e) {
			e.printStackTrace
			if (propagatingErrors)
				throw e
			else {
				console.logError(e)
				null
			}
		} finally
			listeners.forEach [ terminated ]
	}

	def void printStackTraceInConsole(WollokProgramExceptionWrapper e) {
		println((e.exceptionClassName + ": " + e.wollokMessage))
		val errorLine = e.wollokException
			.convertStackTrace
			.toList
			.filter [ stackDTO | stackDTO.hasContextDescription ]
			.map [ stackDTO | stackDTO.elementForStackTrace ]
			.join(System.lineSeparator)
		
		println(errorLine)
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
			if (e.shouldGetDeeperInStack) {
				currentThread.stack.peek.defineCurrentLocation = e
			}
			listeners.forEach [ aboutToEvaluate(e) ]
			evaluator.evaluate(e)
		} catch (ReturnValueException ex) {
			throw ex // a return
		} catch (WollokProgramExceptionWrapper ex) {
			throw ex // a user-level exception, fine !
		} catch (Exception ex) { // vm exception
			throw new WollokInterpreterException(e, ex)
		} finally {
			listeners.forEach [ evaluated(e) ]
		}
	}
	
	def getConsole() { console }

	def setReference(String variableName, WollokObject value) {
		if (!globalVariables.containsKey(variableName))
			throw new UnresolvableReference(Messages.LINKING_COULD_NOT_RESOLVE_REFERENCE.trim + " " + (variableName ?: ""))
		else
			globalVariables.put(variableName, value)
	}

	def resolve(String variableName) {
		if (globalVariables.containsKey(variableName))
			return globalVariables.get(variableName)

		throw new UnresolvableReference(Messages.LINKING_COULD_NOT_RESOLVE_REFERENCE.trim + " " + (variableName ?: ""))
	}
	
	// Accessing Thread State
	
	override WThread getCurrentThread(){
		var thread = this.currentThreadHolder.get()
		
		if(thread !== null) 
			return thread
		
		thread = new WThread(this)	
		currentThreadHolder.set(thread)
		
		
		//This is a hack, because the threads are created with a root stack. 
		
		if(rootContext !== null){
			val stackFrame = rootContext.createInitialStackElement
			thread.stack.push(stackFrame)
		}
		
		return thread	
	}
	
	override getCurrentContext() {
		currentThread.currentContext
	}

	override performOnStack(EObject executable, EvaluationContext<WollokObject> newContext, ()=>WollokObject something) {
		currentThread.performOnStack(executable, newContext, something)
	}

	def void generateStack(EObject rootObject) {
		val stackFrame = rootObject.createInitialStackElement
		currentThread.stack.push(stackFrame)
		listeners.forEach [ started ]
		rootContext = rootObject
	}

	def createInitialStackElement(EObject root) {
		new XStackFrame(root, new WollokNativeLobby(console, this), WollokSourcecodeLocator.INSTANCE)
	}

	def initStack(){
		currentThread.initStack()
	}

	// Handling globals

	override addGlobalReference(String name, WollokObject value) {
		globalVariables.put(name, value)
		value
	}
	

	override removeGlobalReference(String name) {
		globalVariables.remove(name)
	}

	def isRootFile() { rootContext.isASuite	}
}
