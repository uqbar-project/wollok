package org.uqbar.project.wollok.interpreter

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
	
	def Object call(WMethodDeclaration method, Object... parameters) {
		if (method.parameters.size != parameters.size) 
			throw new MessageNotUnderstood('''Incorrect number of arguments for method '«method.name»'. Expected «method.parameters.size» but found «parameters.size»''')
		val c = method.createEvaluationContext(parameters).then(receiver)
		
		interpreter.performOnStack(method, c) [|
			if (method.native) {
				// reflective call
				val r = receiver.nativeObject.invokeNative(method.name, parameters)
				if (receiver.nativeObject.isVoid(method.name, parameters))
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
	
	def dispatch invokeNative(Object nativeObject, String name, Object... parameters){
		nativeObject.invoke(name, parameters)
	}

	def dispatch invokeNative(AbstractWollokDeclarativeNativeObject nativeObject, String name, Object... parameters){
		nativeObject.call(name, parameters)
	}

	// ********************************************************************************************
	// ** Helpers
	// ********************************************************************************************
	
	def eval(EObject expr) { interpreter.eval(expr) }	
	
	def createEvaluationContext(WMethodDeclaration declaration, Object... values) {
		declaration.parameters.map[name].createEvaluationContext(values)
	}

	def dispatch isVoid(Object nativeObject, String message, Object... parameters){
		var method = this.class.methods.findFirst[name == message] // TODO Por qué busca el método a mano en la clase en lugar de usar los mecanismos que ya tenemos?
		
		if(method == null) false 
		else method.returnType == Void.TYPE
	}

	def dispatch isVoid(AbstractWollokDeclarativeNativeObject nativeObject, String name, Object... parameters){
		nativeObject.isVoid(name, parameters)
	}
}

