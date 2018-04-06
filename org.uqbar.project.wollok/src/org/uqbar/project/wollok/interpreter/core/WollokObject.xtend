package org.uqbar.project.wollok.interpreter.core

import java.util.Collections
import java.util.List
import java.util.Map
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.Messages
import org.uqbar.project.wollok.interpreter.AbstractWollokCallable
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.api.IWollokInterpreter
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.context.UnresolvableReference
import org.uqbar.project.wollok.interpreter.context.WVariable
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper
import org.uqbar.project.wollok.interpreter.natives.DefaultNativeObjectFactory
import org.uqbar.project.wollok.sdk.WollokDSK
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

import static org.uqbar.project.wollok.WollokConstants.*
import static org.uqbar.project.wollok.interpreter.context.EvaluationContextExtensions.*
import static org.uqbar.project.wollok.sdk.WollokDSK.*

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
class WollokObject extends AbstractWollokCallable implements EvaluationContext<WollokObject> {
	public static val SELF_VAR = new WVariable(SELF, false)
	@Accessors val Map<String, WollokObject> instanceVariables = newHashMap
	@Accessors var Map<WMethodContainer, Object> nativeObjects = newHashMap
	val EvaluationContext<WollokObject> parentContext
	List<String> properties = newArrayList
	List<String> constantsProperties = newArrayList
	
	new(IWollokInterpreter interpreter, WMethodContainer behavior) {
		super(interpreter, behavior)
		parentContext = interpreter.currentContext
	}

	override getReceiver() { this }

	def dispatch void addMember(WMethodDeclaration method) { /** Nothing to do */ }
	def dispatch void addMember(WVariableDeclaration declaration) {
		instanceVariables.put(declaration.variable.name, interpreter.performOnStack(declaration, this) [| declaration.right?.eval ])
		if (declaration.property) {
			properties.add(declaration.variable.name)
			if (!declaration.writeable) {
				constantsProperties.add(declaration.variable.name)			
			}
		}
	}
		
	// ******************************************
	// **
	// ******************************************
	
	override getThisObject() { this }
	
	override call(String message, WollokObject... parameters) {
		val method = behavior.lookupMethod(message, parameters, false)
		if (method === null) {
			if (message.hasProperty) {
				return resolveProperty(message, parameters)				
			} else {
				throwMessageNotUnderstood(message, parameters)
			}
		}
		method.call(parameters)
	}
	
	def resolveProperty(String message, WollokObject[] parameters) {
		if (parameters.empty) {
			return resolve(message)
		}
		if (parameters.size > 1) {
			throwMessageNotUnderstood(message, parameters)
		}
		if (constantsProperties.contains(message)) {
			throw messageNotUnderstood(NLS.bind(Messages.WollokDslValidator_PROPERTY_NOT_WRITABLE, message))
		}
		setReference(message, parameters.head)
		return theVoid
	}
	
	override hasProperty(String variableName) {
		properties.contains(variableName)
	}
	
	def throwMessageNotUnderstood(String methodName, Object... parameters) {
		try {
			call("messageNotUnderstood", methodName.javaToWollok, parameters.map[javaToWollok].javaToWollok)
		}
		catch (WollokProgramExceptionWrapper e) {
			// this one is ok because calling messageNotUnderstood actually throws the exception!
			throw e
		}
		catch (RuntimeException e) {
			throw new RuntimeException("Error while executing 'messageNotUnderstood': " + e.message, e)
		}
	}
	
	def messageNotUnderstood(String message) {
		val e = evaluator.newInstance(MESSAGE_NOT_UNDERSTOOD_EXCEPTION, message.javaToWollok)
		new WollokProgramExceptionWrapper(e)
	}
	
	// ahh repetido ! no son polimorficos metodos y constructores! :S
	def invokeConstructor(WollokObject... objects) {
		behavior.resolveConstructor(objects)?.evaluateConstructor(objects)
	}
	
	def void evaluateConstructor(WConstructor constructor, WollokObject[] objects) {
		val constructorEvalContext = constructor.createEvaluationContext(objects)
		// delegation
		val other = constructor.delegatingConstructorCall
		if (other !== null) {
			val delegatedConstructor = constructor.wollokClass.resolveConstructorReference(other)
			delegatedConstructor?.invokeOnContext(other, other.arguments, constructorEvalContext) // no 'this' as parent context !
		}
		else {
			// automatic super() call
			val delegatedConstructor = constructor.wollokClass.findConstructorInSuper(EMPTY_OBJECTS_ARRAY)
			delegatedConstructor?.invokeOnContext(constructor, Collections.EMPTY_LIST, constructorEvalContext)
		}
		
		// actual call
		if (constructor.expression !== null) {
			val context = then(constructorEvalContext, this)
			interpreter.performOnStack(constructor, context) [| interpreter.eval(constructor.expression) ]
		}
	}
	
	def invokeOnContext(WConstructor constructor, EObject call, List<? extends EObject> argumentsToEval, EvaluationContext context) {
		interpreter.performOnStack(call, context) [|
			evaluateConstructor(constructor, argumentsToEval.evalAll) 
			null
		]
	} 
	
	def createEvaluationContext(WConstructor declaration, WollokObject... values) {
		asEvaluationContext(declaration.parameters.createMap(values))
	}
	
	override resolve(String variableName) {
		if (variableName == SELF)
			this
		else if (instanceVariables.containsKey(variableName))
			instanceVariables.get(variableName)
		else
			parentContext.resolve(variableName)				
 	}
 	
	override setReference(String name, WollokObject value) {
		if (name == SELF)
			throw new RuntimeException("Cannot modify \"" +  SELF + "\" variable")
		if (!instanceVariables.containsKey(name))
			throw new UnresolvableReference('''Unrecognized variable "«name»" in object "«this»"''')
		
		val oldValue = instanceVariables.put(name, value)
		listeners.forEach[fieldChanged(name, oldValue, value)]
	}
	
	// query (kind of reflection api)
	override allReferenceNames() { 
		instanceVariables.keySet.map[new WVariable(it, false)]
		+ 
		#[SELF_VAR]
	}
	
	def getProperties() {
		properties	
	}
	
	def allMethods() {
		if (behavior.parent !== null)
			behavior.methods + behavior.parent.methods
		else
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
	
	def isVoid() { this == WollokDSK.getVoid(interpreter as WollokInterpreter, behavior) }
	
	def isKindOf(WMethodContainer c) { behavior.isKindOf(c) }
	
	// observable
	
	var Set<WollokObjectListener> listeners = newHashSet
	
	static val EMPTY_OBJECTS_ARRAY = newArrayOfSize(0)
	
	def addFieldChangedListener(WollokObjectListener listener) { this.listeners.add(listener) }
	def removeFieldChangedListener(WollokObjectListener listener) { this.listeners.remove(listener) }
	
	// UFFF no estoy seguro de esto ya 
	override addReference(String variable, WollokObject value) {
//		throw new UnsupportedOperationException("ERROR while adding reference [" + variable + "] to value [" + value + "]")
		setReference(variable, value)
//		addGlobalReference(variable, value)
		value
	}
	
	override addGlobalReference(String name, WollokObject value) {
		interpreter.addGlobalReference(name, value)
	}
	
	override removeGlobalReference(String name) {
		interpreter.removeGlobalReference(name)
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
	
	def callSuper(WMethodContainer superFrom, String message, WollokObject[] parameters) {
		val hierarchy = behavior.linearizeHierarchy
		val subhierarchy = hierarchy.subList(hierarchy.indexOf(superFrom) + 1, hierarchy.size)
		
		val method = subhierarchy.fold(null) [method, t |
			if (method !== null)
				method
			else 
				t.methods.findFirst[matches(message, parameters)]
		]

		if (method === null)
			// should be an specific error: no super method to call or something
			throw throwMessageNotUnderstood(this, message, parameters)
		method.call(parameters)
	}

	override showableInStackTrace() { true }	
}

/**
 * @author jfernandes
 */
interface WollokObjectListener {
	def void fieldChanged(String fieldName, Object oldValue, Object newValue)
}