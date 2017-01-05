package org.uqbar.project.wollok.scoping

import java.util.HashMap
import java.util.Map
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.resource.IEObjectDescription

class WollokResourceCache {
	
	static String CLASSPATH = "classpath"
	static Map<URI, Iterable<IEObjectDescription>> resourceCache = new HashMap<URI, Iterable<IEObjectDescription>>
	
	static def getResource(URI uri) {
		resourceCache.get(uri)
	}
	
	static synchronized def void addResource(URI uri,  Iterable<IEObjectDescription> objects) {
		if (uri.toString.startsWith(CLASSPATH) && (getResource(uri) == null)) {
			resourceCache.put(uri, objects)
		}
	}
	
}