package org.uqbar.project.wollok.scoping

import java.util.HashMap
import java.util.Map
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.emf.ecore.resource.Resource
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WClass

/**
 * Cache of wollok classpath resources
 * 
 * @author fdodino
 * @author npasserini
 */
class WollokResourceCache {
	
	static String CLASSPATH = "classpath"
	static Map<URI, Iterable<IEObjectDescription>> resourceCache = new HashMap<URI, Iterable<IEObjectDescription>>
	
	static def hasResource(URI uri) {
		getResource(uri) !== null
	}
	
	static def getResource(URI uri) {
		resourceCache.get(uri)
	}
	
	static synchronized def void addResource(URI uri,  Iterable<IEObjectDescription> objects) {
		if (uri.isClassPathResource && !hasResource(uri)) {
			resourceCache.put(uri, objects)
		}
	}
	
	// TODO I do not think this logic belongs here.
	static def boolean isClassPathResource(Resource resource) {
		resource.URI.isClassPathResource
	}

	static def boolean isClassPathResource(URI uri) {
		uri.toString.startsWith(CLASSPATH)
	}
	
	static def isCoreObject(EObject object) {
		if (object === null)
			throw new RuntimeException('''Found null while verifying for core object''')

		if (object.eResource === null)
			throw new RuntimeException('''eResource null for «object» while verifying for core object''')

		if (object.eResource.URI === null)
			throw new RuntimeException('''URI null for «object.eResource» while verifying for core object''')
			
		object.eResource.URI.isClassPathResource
	}
	

	// ************************************************************************
	// ** Get all elements in the scope (used by the type system)
	// ************************************************************************

	static def allCoreWKOs() {
		resourceCache.values.flatten.map[EObjectOrProxy].filter(WNamedObject)
	}	

	static def allCoreClasses() {
		resourceCache.values.flatten.map[EObjectOrProxy].filter(WClass)
	}	

	/**
	 * Clears all cached resources and objects.
	 * Only for test purposes, should not be loaded in live environment.
	 */
	static def clearResourceCache() {
		resourceCache.clear
	}
}