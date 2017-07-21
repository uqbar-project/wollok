package org.uqbar.project.wollok.scoping

import java.util.HashMap
import java.util.Map
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.IEObjectDescription

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
	static def isClassPathResource(URI uri) {
		uri.toString.startsWith(CLASSPATH)
	}
	
	static def isCoreObject(EObject object) {
		object.eResource.URI.isClassPathResource
	}
	
	static def clearCache() {
		resourceCache.clear
	}
}