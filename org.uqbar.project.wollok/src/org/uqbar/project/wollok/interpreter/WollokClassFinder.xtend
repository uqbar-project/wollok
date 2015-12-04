package org.uqbar.project.wollok.interpreter

import com.google.inject.Inject
import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage

import static org.uqbar.project.wollok.sdk.WollokDSK.*

/**
 * Kind of a hack to be able to resolve a wollok class from anywhere
 * 
 * @author jfernandes
 */
class WollokClassFinder {
	// class cache
	private Map<String, WClass> sdkClassesCache = newHashMap
	private Map<String, WNamedObject> sdkObjectsCache = newHashMap
	@Inject IGlobalScopeProvider scopeProvider
	
	static var WollokClassFinder INSTANCE
	
	new() { INSTANCE = this }
	
	def static getInstance() { INSTANCE } 
	
	def WClass getObjectClass(EObject context) { context.getCachedClass(OBJECT) }
	def WClass getListClass(EObject context) { context.getCachedClass(LIST) }
	def WClass getSetClass(EObject context) { context.getCachedClass(SET) }
	def WClass getStringClass(EObject context) { context.getCachedClass(STRING) }
	def WClass getIntegerClass(EObject context) { context.getCachedClass(INTEGER) }
	def WClass getDoubleClass(EObject context) { context.getCachedClass(DOUBLE) }
	def WClass getBooleanClass(EObject context) { context.getCachedClass(BOOLEAN) }
	
	def WClass getCachedClass(EObject context, String className) {
		if (!sdkClassesCache.containsKey(className)) { 
			sdkClassesCache.put(className, searchClass(className, context))
		}
		sdkClassesCache.get(className)
	}
	
	def searchClass(String classFQN, EObject context) {
		val scope = scopeProvider.getScope(context.eResource, WollokDslPackage.Literals.WCLASS__PARENT) [o|
			o.name.toString == classFQN
		]
		val a = scope.allElements.findFirst[o| o.name.toString == classFQN]
		if (a == null)
			throw new WollokRuntimeException("Could NOT find " + classFQN + " in scope: " + scope.allElements)
		a.EObjectOrProxy as WClass
	}
	
	def WNamedObject getCachedObject(EObject context, String objectName) {
		if (!sdkObjectsCache.containsKey(objectName)) { 
			sdkObjectsCache.put(objectName, searchObject(objectName, context))
		}
		sdkObjectsCache.get(objectName)
	}
	
	def searchObject(String objectFQN, EObject context) {
		val scope = scopeProvider.getScope(context.eResource, WollokDslPackage.Literals.WVARIABLE_REFERENCE__REF) [o|
			o.name.toString == objectFQN
		]
		val a = scope.allElements.findFirst[o| o.name.toString == objectFQN]
		if (a == null)
			throw new WollokRuntimeException("Could NOT find " + objectFQN + " in scope: " + scope.allElements)
		a.EObjectOrProxy as WNamedObject
	}
	
}