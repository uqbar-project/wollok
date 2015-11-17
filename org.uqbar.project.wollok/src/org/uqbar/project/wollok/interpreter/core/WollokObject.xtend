package org.uqbar.project.wollok.interpreter.core

import java.util.Collections
import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.AbstractWollokCallable
import org.uqbar.project.wollok.interpreter.UnresolvableReference
import org.uqbar.project.wollok.interpreter.api.IWollokInterpreter
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper
import org.uqbar.project.wollok.interpreter.natives.DefaultNativeObjectFactory
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

import static org.uqbar.project.wollok.WollokDSLKeywords.*
import static org.uqbar.project.wollok.sdk.WollokDSK.*

import static extension org.uqbar.project.wollok.interpreter.context.EvaluationContextExtensions.*
import static extension org.uqbar.project.wollok.interpreter.core.ToStringBuilder.*
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * A wollok user defined (dynamic) object.
 * 
 * @author jfernandes
 * @author npasserini
 */
class WollokObject extends AbstractWollokCallable implements EvaluationContext {
	val extension WollokInterpreterAccess = new WollokInterpreterAccess
	@Accessors val Map<String,Object> instanceVariables = newHashMap
	@Accessors var Map<WMethodContainer, Object> nativeObjects = newHashMap
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
	
	// TODO: parameters should be WollokObject... after we migrate all to be wollok objects
	override call(String message, Object... parameters) {
		val method = behavior.lookupMethod(message, parameters)
		if (method != null)
			return method.call(parameters)

		// TODO: Adding special case for equals, but we have to fix it	
		if (message == "=="){
			val javaMethod = this.class.methods.findFirst[name == "equals"]
			return javaMethod.invoke(this, parameters).javaToWollok
		}
		
		throwMessageNotUnderstood(message, parameters)		
	}
	
	def throwMessageNotUnderstood(String name, Object... parameters) {
		try {
			call("messageNotUnderstood", name.javaToWollok, #[parameters])
		}
		catch (WollokProgramExceptionWrapper e) {
			// this one is ok !
			throw e
		}
		catch (RuntimeException e) {
			throw new RuntimeException("Error while executing 'messageNotUnderstood': " + e.message, e)
		}
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
		if (constructor.expression != null) {
			val context = constructorEvalContext.then(this)
			interpreter.performOnStack(constructor, context) [| interpreter.eval(constructor.expression) ]
		}
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
		try {
			//TODO: java string shouldn't call wollok string
			// it should be a low-lever WollokVM debugging method
			val string = call("toString", #[]) as WollokObject
			(string.getNativeObject(STRING) as JavaWrapper<String>).wrapped
		}
		// this is a hack while literal objects are not inheriting from wollok.lang.Object therefore
		// they don't understand the toString() message
		catch (WollokProgramExceptionWrapper e) {
			if (e.isMessageNotUnderstood) {
				this.behavior.objectDescription
			}
			else
				throw e
		}
	}
		
	def getKind() { behavior }
	
	def isKindOf(WMethodContainer c) { behavior.isKindOf(c) }
	
	// observable
	
	var Set<WollokObjectListener> listeners = newHashSet
	
	static val EMPTY_OBJECTS_ARRAY = newArrayOfSize(0)
	
	def addFieldChangedListener(WollokObjectListener listener) { this.listeners.add(listener) }
	def removeFieldChangedListener(WollokObjectListener listener) { this.listeners.remove(listener) }
	
	// UFFF no estoy seguro de esto ya 
	override addReference(String variable, Object value) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override addGlobalReference(String name, Object value) {
		interpreter.addGlobalReference(name, value)
	}
	
	def <T> getNativeObject(Class<T> clazz) { this.nativeObjects.values.findFirst[clazz.isInstance(it)] as T }
	def <T> getNativeObject(String clazz) {
		val transformedClassName = DefaultNativeObjectFactory.wollokToJavaFQN(clazz) 
		this.nativeObjects.values.findFirst[ transformedClassName == class.name ] as T
	}
	
	def hasNativeType(String type) {
		val transformedClassName = DefaultNativeObjectFactory.wollokToJavaFQN(type)
		nativeObjects.values.exists[n| n.class.name == transformedClassName ]
	}
	
}

/**
 * @author jfernandes
 */
interface WollokObjectListener {
	def void fieldChanged(String fieldName, Object oldValue, Object newValue)
}