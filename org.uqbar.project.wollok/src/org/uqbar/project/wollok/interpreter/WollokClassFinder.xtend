package org.uqbar.project.wollok.interpreter

import com.google.common.base.Predicate
import com.google.inject.Inject
import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage

import static org.uqbar.project.wollok.sdk.WollokSDK.*

/**
 * Kind of a hack to be able to resolve a wollok class from anywhere
 * 
 * @author jfernandes
 * @author npasserini
 */
class WollokClassFinder {
	Map<String, WClass> sdkClassesCache = newHashMap
	Map<String, WNamedObject> sdkObjectsCache = newHashMap
	@Inject IGlobalScopeProvider scopeProvider

	static var WollokClassFinder INSTANCE

	new() {
		INSTANCE = this
	}

	def static getInstance() { INSTANCE }

	def WClass getObjectClass(EObject context) { context.getCachedClass(OBJECT) }

	def WClass getListClass(EObject context) { context.getCachedClass(LIST) }

	def WClass getSetClass(EObject context) { context.getCachedClass(SET) }

	def WClass getStringClass(EObject context) { context.getCachedClass(STRING) }

	def WClass getNumberClass(EObject context) { context.getCachedClass(NUMBER) }

	def WClass getBooleanClass(EObject context) { context.getCachedClass(BOOLEAN) }
	
	def WClass getClosureClass(EObject context) { context.getCachedClass(CLOSURE) }

	// ************************************************************************
	// ** Main API: cache access
	// ************************************************************************
	def WClass getCachedClass(EObject context, String classFQN) {
		if (!sdkClassesCache.containsKey(classFQN)) {
			sdkClassesCache.put(classFQN, searchClass(classFQN, context))
		}
		sdkClassesCache.get(classFQN)
	}

	def WNamedObject getCachedObject(EObject context, String objectName) {
		if (!sdkObjectsCache.containsKey(objectName)) {
			sdkObjectsCache.put(objectName, searchObject(objectName, context))
		}
		sdkObjectsCache.get(objectName)
	}

	// ************************************************************************
	// ** Search object/class in the global scope
	// ************************************************************************
	def searchClass(String classFQN, EObject context) {
		val scope = getClassScope(context.eResource)[o|o.name.toString == classFQN]
		val a = scope.allElements.findFirst[o|o.EObjectOrProxy instanceof WClass && o.name.toString == classFQN]
		if (a === null)
			throw new WollokRuntimeException("Could NOT find " + classFQN + " in scope: " + scope.allElements)
		a.EObjectOrProxy as WClass
	}

	def searchObject(String objectFQN, EObject context) {
		val scope = getObjectScope(context.eResource)[o|o.name.toString == objectFQN]
		val a = scope.allElements.findFirst[o|o.EObjectOrProxy instanceof WNamedObject && o.name.toString == objectFQN]
		if (a === null)
			throw new WollokRuntimeException("Could NOT find " + objectFQN + " in scope: " + scope.allElements)
		a.EObjectOrProxy as WNamedObject
	}

	// ************************************************************************
	// ** Utilities
	// ************************************************************************
	protected def getClassScope(Resource resource, Predicate<IEObjectDescription> predicate) {
		scopeProvider.getScope(resource, WollokDslPackage.Literals.WCLASS__PARENTS, predicate)
	}

	protected def getObjectScope(Resource resource, Predicate<IEObjectDescription> predicate) {
		scopeProvider.getScope(resource, WollokDslPackage.Literals.WVARIABLE_REFERENCE__REF, predicate)
	}
}
