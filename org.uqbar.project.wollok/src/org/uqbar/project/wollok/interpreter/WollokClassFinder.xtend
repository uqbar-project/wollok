package org.uqbar.project.wollok.interpreter

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage

/**
 * Kind of a hack to be able to resolve a wollok class from anywhere
 * 
 * @author jfernandes
 */
class WollokClassFinder {
	static final String OBJECT_CLASS_NAME = 'wollok.lang.WObject'
	private WClass objectClass
	@Inject IGlobalScopeProvider scopeProvider
	static val INSTANCE = new WollokClassFinder

	new() {
		WollokInterpreter.getInstance.injector.injectMembers(this)
	}
	
	def static getInstance() { INSTANCE }
	
	def WClass getObjectClass(EObject context) {
		if (objectClass == null) {
			objectClass = searchClass(OBJECT_CLASS_NAME, context)
		}
		objectClass
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