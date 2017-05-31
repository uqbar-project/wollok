package org.uqbar.project.wollok.libraries

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IResourceDescription.Manager

/**
 * Common methods between AbstractWollokLibrary 
 * and ui.ManifestEntryAdapter used by ClassPathEntryAdapter
 * 
 */
class WollokLibExtensions {

	/**
	 * loads the objects without cache
	 */
	static def load(URI uri, Resource resource, Manager manager) {
		var newResource = resource.resourceSet.getResource(uri, true)
		resource.load(#{})
		manager.getResourceDescription(newResource).exportedObjects
	}
	
	
	/** remove path and extension foo/bar.jar => bar 
	 * if path is not a jar file return path
	 */
	static def libName(String path) {
		val s = path.split("/")
		val r = s.get(s.size - 1)
		return if (r.contains(".")) r.substring(0, r.indexOf(".")) else r
	}
	
	
}