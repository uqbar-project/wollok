package org.uqbar.project.wollok.interpreter.core

import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.EcoreUtil2
import org.uqbar.project.wollok.interpreter.AbstractWollokCallable
import org.uqbar.project.wollok.interpreter.MessageNotUnderstood
import org.uqbar.project.wollok.interpreter.UnresolvableReference
import org.uqbar.project.wollok.interpreter.api.IWollokInterpreter
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WSuperDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WThisDelegatingConstructorCall
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

import static org.uqbar.project.wollok.WollokDSLKeywords.*

import static extension org.uqbar.project.wollok.interpreter.context.EvaluationContextExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import com.google.common.collect.Lists
import java.util.Collections

/**
 * A wollok user defined (dynamic) object.
 * 
 * @author jfernandes
 * @author npasserini
 */
class WollokObject extends AbstractWollokCallable implements EvaluationContext {
	val extension WollokInterpreterAccess = new WollokInterpreterAccess
	val Map<String,Object> instanceVariables = newHashMap
	@Accessors var Object nativeObject
	val EvaluationContext parentContext
	
	new(IWollokInterpreter interpreter, WMethodContainer behavior) {
		super(interpreter, behavior)
		parentContext = interpreter.currentContext
	}

	override getReceiver() { this }

	def dispatch void addMember(WMethodDeclaration method) { /** Nothing to do */ }
	def dispatch void addMember(WVariableDeclaration declaration) {
		instanceVariables.put(declaration.variable.name, declaration.right?.eval)
	}
		
	// ******************************************
	// **
	// ******************************************
	
	override getThisObject() { this }
	
	override call(String message, Object... parameters) {
		val method = behavior.lookupMethod(message)
		if (method != null)
			return method.call(parameters)

		// TODO: Adding special case for equals, but we have to fix it	
		if (message == "=="){
			val javaMethod = this.class.methods.findFirst[name == "equals"]
			return javaMethod.invoke(this, parameters).asWollokObject
		}
		
		throw new MessageNotUnderstood('''Message not understood: «this» does not understand «message»''')
	}
	
	
	// ahh repetido ! no son polimorficos metodos y constructores! :S
	def invokeConstructor(Object... objects) {
		var constructor = behavior.resolveConstructor(objects)
		
		// no-args constructor automatic execution 
		if (constructor == null && objects.length == 0)
			constructor = (behavior as WClass).findConstructorInSuper(EMPTY_OBJECTS_ARRAY)
			
		if (constructor != null)
			evaluateConstructor(constructor, objects)
	}
	
	def void evaluateConstructor(WConstructor constructor, Object[] objects) {
		val constructorEvalContext = constructor.createEvaluationContext(objects)
		// delegation
		val other = constructor.delegatingConstructorCall
		if (other != null) {
			val delegatedConstructor = constructor.wollokClass.resolveConstructorReference(other)
			delegatedConstructor.invokeOnContext(other, other.arguments, constructorEvalContext) // no 'this' as parent context !
		}
		else {
			// automatic super() call
			val delegatedConstructor = constructor.wollokClass.findConstructorInSuper(EMPTY_OBJECTS_ARRAY)
			delegatedConstructor?.invokeOnContext(constructor, Collections.EMPTY_LIST, constructorEvalContext)
		}
		
		// actual call
		val context = constructorEvalContext.then(this)
		interpreter.performOnStack(constructor, context) [| interpreter.eval(constructor.expression) ]
	}
	
	def invokeOnContext(WConstructor constructor, EObject call, List<? extends EObject> argumentsToEval, EvaluationContext context) {
		interpreter.performOnStack(call, context) [|
			evaluateConstructor(constructor, argumentsToEval.evalAll) 
			null
		]
	} 
	
	def static createEvaluationContext(WConstructor declaration, Object... values) {
		declaration.parameters.map[name].createEvaluationContext(values)
	}
	
	override resolve(String variableName) {
		if (variableName == THIS)
			this
		else if (instanceVariables.containsKey(variableName))
			instanceVariables.get(variableName)
		else
			parentContext.resolve(variableName)				
 	}
 	
	override setReference(String name, Object value) {
		if (name == THIS)
			throw new RuntimeException("Cannot modify \"" +  THIS + "\" variable")
		if (!instanceVariables.containsKey(name))
			throw new UnresolvableReference('''Unrecognized variable "«name»" in object "«this»"''')
		
		val oldValue = instanceVariables.put(name, value)
		listeners.forEach[fieldChanged(name, oldValue, value)]
	}
	
	// query (kind of reflection api)
	override allReferenceNames() { instanceVariables.keySet.map[new WVariable(it, false)] }
	def allMethods() {
		// TODO: include inherited methods!
		behavior.methods
	}
	
	override toString() {
		val toString = behavior.lookupMethod("toString")
		if (toString != null)
			this.call("toString").toString
		else
			behavior.objectDescription + this.instanceVariables
	}
	
	def shortLabel() {
		behavior.objectDescription
	}

	def dispatch objectDescription(WClass clazz) { "a " + clazz.name }
	def dispatch objectDescription(WObjectLiteral obj) { "anObject" }
	def dispatch objectDescription(WNamedObject namedObject){ namedObject.name }
	
	def getKind() { behavior }
	
	def isKindOf(WMethodContainer c) { behavior.isKindOf(c) }
	
	// observable
	
	var Set<WollokObjectListener> listeners = newHashSet
	
	static val EMPTY_OBJECTS_ARRAY = newArrayOfSize(0)
	
	def addFieldChangedListener(WollokObjectListener listener) { this.listeners.add(listener) }
	def removeFieldChangedListener(WollokObjectListener listener) { this.listeners.remove(listener) }
	
	// UFFF no estoy seguro de esto ya 
	override addReference(String name, Object value) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override addGlobalReference(String name, Object value) {
		interpreter.addGlobalReference(name, value)
	}
}

/**
 * @author jfernandes
 */
interface WollokObjectListener {
	def void fieldChanged(String fieldName, Object oldValue, Object newValue)
}