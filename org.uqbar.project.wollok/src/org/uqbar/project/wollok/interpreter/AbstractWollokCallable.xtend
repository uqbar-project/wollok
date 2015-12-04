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
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WParameter

import static org.uqbar.project.wollok.sdk.WollokDSK.*

import static extension org.uqbar.project.wollok.interpreter.context.EvaluationContextExtensions.*
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

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
		val c = method.createEvaluationContext(parameters).then(receiver)
		
		interpreter.performOnStack(method, c) [|
			if (method.native) {
				// reflective call to native method:
				val nativeObject = receiver.nativeObjects.get(method.declaringContext)
				val WollokObject r = nativeObject.invokeNative(method.name, parameters)
				if (nativeObject.isVoid(method.name, parameters))
					return theVoid
				else
					return r
			}
			else {
				val WollokObject r = method.expression.eval as WollokObject
				return if (method.expressionReturns)
						r
					else
						theVoid
			}
		]
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
	
	def throwMessageNotUnderstood(Object nativeObject, String name, WollokObject[] parameters) {
		newException(MESSAGE_NOT_UNDERSTOOD_EXCEPTION, nativeObject.createMessage(name, parameters))
	}

	def dispatch invokeNative(AbstractWollokDeclarativeNativeObject nativeObject, String name, WollokObject... parameters) {
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
		// TODO Por qué busca el método a mano en la clase en lugar de usar los mecanismos que ya tenemos?
		var method = class.methods.findFirst[name == message]
		method != null && method.returnType == Void.TYPE 
	}

	def dispatch isVoid(AbstractWollokDeclarativeNativeObject nativeObject, String name, Object... parameters){
		nativeObject.isVoid(name, parameters)
	}
}

