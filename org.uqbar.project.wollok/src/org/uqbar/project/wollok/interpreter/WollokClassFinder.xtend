package org.uqbar.project.wollok.interpreter

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage

import static org.uqbar.project.wollok.sdk.WollokDSK.*
import java.util.Map

/**
 * Kind of a hack to be able to resolve a wollok class from anywhere
 * 
 * @author jfernandes
 */
class WollokClassFinder {
	// class cache
	private Map<String, WClass> sdkClassesCache = newHashMap
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
	
}