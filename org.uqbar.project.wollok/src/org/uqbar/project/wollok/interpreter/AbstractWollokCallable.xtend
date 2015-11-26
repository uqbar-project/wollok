package org.uqbar.project.wollok.interpreter

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.api.IWollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WCallable
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokDeclarativeNativeObject
import org.uqbar.project.wollok.interpreter.stack.VoidObject
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static extension org.uqbar.project.wollok.interpreter.context.EvaluationContextExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.sdk.WollokDSK.*
import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.wollokDsl.WParameter
import org.eclipse.emf.common.util.EList

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

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
	
	def Object call(WMethodDeclaration method, Object... parameters) {
		val c = method.createEvaluationContext(parameters).then(receiver)
		
		interpreter.performOnStack(method, c) [|
			if (method.native) {
				// reflective call to native method:
				val nativeObject = receiver.nativeObjects.get(method.declaringContext)
				val r = nativeObject.invokeNative(method.name, parameters)
				if (nativeObject.isVoid(method.name, parameters))
					return VoidObject.instance
				else
					return r
			} 
			else {
				val r = method.expression.eval
				return if (method.expressionReturns)
						r
					else
						VoidObject.instance
			}
		]
	}

	def WollokObject getReceiver()
		

	// ********************************************************************************************
	// ** Native objects handling
	// ********************************************************************************************
	
	def dispatch invokeNative(Object nativeObject, String name, Object... parameters) {
		val method = AbstractWollokDeclarativeNativeObject.getMethod(nativeObject.class, name, parameters)
		if (method == null)
			throw throwMessageNotUnderstood(nativeObject, name, parameters)
		method.accesibleVersion.invokeConvertingArgs(nativeObject, parameters)
	}
	
	def throwMessageNotUnderstood(Object nativeObject, String name, Object[] parameters) {
		val wollokException = ((interpreter as WollokInterpreter).evaluator as WollokInterpreterEvaluator).newInstance(MESSAGE_NOT_UNDERSTOOD_EXCEPTION, nativeObject.createMessage(name, parameters))
		new WollokProgramExceptionWrapper(wollokException)
	}

	def dispatch invokeNative(AbstractWollokDeclarativeNativeObject nativeObject, String name, Object... parameters){
		nativeObject.call(name, parameters)
	}

	// ********************************************************************************************
	// ** Helpers
	// ********************************************************************************************
	
	def eval(EObject expr) { interpreter.eval(expr) }
	
	def evalAll(List<? extends EObject> list) { list.map[ eval ] }	
	
	def createEvaluationContext(WMethodDeclaration declaration, Object... values) {
		declaration.parameters.createMap(values).asEvaluationContext
	}
	
	def createMap(EList<WParameter> parameters, Object[] values) {
		var i = 0
		val m = newHashMap
		for (p : parameters) {
			m.put(p.name, value(p, values, i))
			i++
		}
		m
	}
	
	def Object value(WParameter p, Object[] values, int i) {
		if (p.isVarArg) {
			// todo handle empty vararg
			(values.subList(i, values.size)).javaToWollok
		}
		else
			values.get(i)
	}

	def dispatch isVoid(Object nativeObject, String message, Object... parameters) {
		// TODO Por qué busca el método a mano en la clase en lugar de usar los mecanismos que ya tenemos?
		var method = this.class.methods.findFirst[name == message]
		
		if (method == null) false 
		else method.returnType == Void.TYPE
	}

	def dispatch isVoid(AbstractWollokDeclarativeNativeObject nativeObject, String name, Object... parameters){
		nativeObject.isVoid(name, parameters)
	}
}

