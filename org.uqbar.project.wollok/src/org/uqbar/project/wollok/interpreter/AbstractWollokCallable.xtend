package org.uqbar.project.wollok.interpreter

import java.util.List
import java.util.Map
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.api.IWollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WCallable
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokDeclarativeNativeObject
import org.uqbar.project.wollok.sdk.WollokDSK
import org.uqbar.project.wollok.wollokDsl.Invariant
import org.uqbar.project.wollok.wollokDsl.MethodRequirement
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WParameter

import static org.uqbar.project.wollok.sdk.WollokDSK.*

import static extension org.uqbar.project.wollok.interpreter.context.EvaluationContextExtensions.*
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*
import static extension org.uqbar.project.xtext.utils.XTextExtensions.*

/**
 * Methods to be shared between WollokObject and CallableSuper
 * 
 * @author npasserini
 * @author jfernandes
 */
abstract class AbstractWollokCallable implements WCallable {
	@Accessors val extension IWollokInterpreter interpreter
	@Accessors val WMethodContainer behavior
	
	new(IWollokInterpreter interpreter, WMethodContainer behavior) {
		this.interpreter = interpreter
		this.behavior = behavior
	}

	// ********************************************************************************************
	// ** Feature calling
	// ********************************************************************************************
	
	def WollokObject theVoid() { WollokDSK.getVoid(interpreter as WollokInterpreter, behavior) }
	
	def WollokObject call(WMethodDeclaration method, WollokObject... parameters) {
		call(method, true, parameters)
	}
	
	def WollokObject call(WMethodDeclaration method, Boolean checkRequirements, WollokObject... parameters) {
		val c = method.createEvaluationContext(parameters).then(receiver)
		
		interpreter.performOnStack(method, c) [|

			if (checkRequirements) method.checkRequirements
			
			if (method.native) {
				callNative(method, parameters)
			}
			else {
				val result = method.expression.eval
				return if (method.supposedToReturnValue)
						result
					else
						theVoid
			}
		]
	}
	
	def protected void checkRequirements(WMethodDeclaration method) {
		val failing = internalCheckRequirements(method)
		// do fail
		if (!failing.empty)
			throw newException(METHOD_REQUIREMENT_VIOLATED_EXCEPTION, 
				"Method requirements not met: " + 
				failing.map['''«key.messageOrDefault» («key.condition.sourceCode.trim»)'''].join(', '))
	}
	
	// this probably can be improved :S
	def protected Iterable<Pair<MethodRequirement, WollokObject>> internalCheckRequirements(WMethodDeclaration method) {
		if (method.requirements == null || method.requirements.empty) {
			if (method.overrides) {
				// no own reqs, check super
				return method.overridenMethod.internalCheckRequirements()
			}
		}
		else {
			if (method.overrides) {
				// overrides requirement => ownReqs || super
				val failing = method.checkOwnRequirements
				if (!failing.empty) {
					val failingOnSuper = method.overridenMethod.internalCheckRequirements()
					if (!failingOnSuper.empty) {
						// own & super failed, lets fail !
						return failing + failingOnSuper	
					}
				}
			}
			else {
				// own requirements (no super)
				return method.checkOwnRequirements

			}
		}
		return #[]
	}
	
	protected def checkOwnRequirements(WMethodDeclaration method) {
		method.requirements
				.map[r| r -> r.condition.eval]
				.filter[ !value.isTrue ]
	}
	
	def getMessageOrDefault(MethodRequirement it) {
		if (message != null) message else "Not satisfied"
	}
	def getMessageOrDefault(Invariant it) {
		if (message != null) message else "Not satisfied"
	}
	
	def protected WollokObject callNative(WMethodDeclaration method, WollokObject... parameters) {
		// reflective call to native method:
		val nativeObject = receiver.nativeObjects.get(method.declaringContext)
		val result = nativeObject.invokeNative(method.name, parameters)
		return if (nativeObject.isVoid(method.name, parameters))
					theVoid
				else
					result
	}

	def WollokObject getReceiver()
		

	// ********************************************************************************************
	// ** Native objects handling
	// ********************************************************************************************
	
	def dispatch invokeNative(Object nativeObject, String name, WollokObject... parameters) {
		val method = AbstractWollokDeclarativeNativeObject.getMethod(nativeObject.class, name, parameters)
		if (method == null)
			throw throwMessageNotUnderstood(nativeObject, name, parameters)
		method.accesibleVersion.invokeConvertingArgs(nativeObject, parameters)
	}
	
	def WollokProgramExceptionWrapper throwMessageNotUnderstood(Object nativeObject, String name, WollokObject[] parameters) {
		newException(MESSAGE_NOT_UNDERSTOOD_EXCEPTION, nativeObject.createMessage(name, parameters))
	}

	def dispatch WollokObject invokeNative(AbstractWollokDeclarativeNativeObject nativeObject, String name, WollokObject... parameters) {
		nativeObject.call(name, parameters)
	}

	// ********************************************************************************************
	// ** Helpers
	// ********************************************************************************************
	
	def eval(EObject expr) { interpreter.eval(expr) }
	
	def evalAll(List<? extends EObject> list) { list.map[ eval ] }	
	
	def createEvaluationContext(WMethodDeclaration declaration, WollokObject... values) {
		declaration.parameters.createMap(values).asEvaluationContext
	}
	
	def Map<String, WollokObject> createMap(EList<WParameter> parameters, WollokObject[] values) {
		var i = 0
		val m = newHashMap
		for (p : parameters) {
			m.put(p.name, value(p, values, i))
			i++
		}
		m
	}
	
	def WollokObject value(WParameter p, WollokObject[] values, int i) {
		if (p.isVarArg) {
			// todo handle empty vararg
			(values.subList(i, values.size)).javaToWollok
		}
		// handle lazy params here ??
		else
			values.get(i)
	}

	def dispatch isVoid(Object nativeObject, String message, Object... parameters) {
		var method = AbstractWollokDeclarativeNativeObject.getMethod(nativeObject.class, message, parameters)
		AbstractWollokDeclarativeNativeObject.isVoidType(method.returnType)
	}

	def dispatch isVoid(AbstractWollokDeclarativeNativeObject nativeObject, String name, Object... parameters){
		nativeObject.isVoid(name, parameters)
	}
}

