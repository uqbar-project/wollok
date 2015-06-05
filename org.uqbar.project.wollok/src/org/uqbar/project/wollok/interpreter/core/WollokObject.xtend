package org.uqbar.project.wollok.interpreter.core

import java.util.Map
import java.util.Set
import org.eclipse.xtend.lib.annotations.Accessors
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
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

import static org.uqbar.project.wollok.WollokDSLKeywords.*

import static extension org.uqbar.project.wollok.interpreter.context.EvaluationContextExtensions.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

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
		
		// I18N !
		throw new MessageNotUnderstood('''Message not understood: «this» does not understand «message»''')
	}
	
	
	// ahh repetido ! no son polimorficos metodos y constructores! :S
	def invokeConstructor(WConstructor constructor, Object... objects) {
		if (constructor != null) {
			val context = constructor.createEvaluationContext(objects).then(this)
			interpreter.performOnStack(constructor, context) [| interpreter.eval(constructor.expression) ]
		}
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
			// I18N !
			throw new RuntimeException("Cannot modify \"" +  THIS + "\" variable")
		if (!instanceVariables.containsKey(name))
			// I18N !
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