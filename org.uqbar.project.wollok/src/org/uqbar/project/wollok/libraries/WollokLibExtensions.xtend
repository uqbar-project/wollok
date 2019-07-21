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
	
	private static val libsFqn = #["wollok.lang","wollok.lib","wollok.vm","wollok.game","wollok.mirror"]

	/**
	 * loads the objects without cache
	 */
	static def load(URI uri, Resource resource, Manager manager) {
		val newResource = resource.resourceSet.getResource(uri, true)
		resource.load(#{})
		manager.getResourceDescription(newResource).exportedObjects
	}
	
	
	/** 
	 * remove path and extension foo/bar.jar => bar 
	 * if path is not a jar file return path
	 * 
	 * foo/bar.wollokmf => bar
	 * 
	 * But, if the library is not a jar or manifest file, then is other project, 
	 * the path must be projectName/sourceFolder. In this case the
	 * the lib name is  projectName
	 * 
	 */
	 //TODO maybe differents methods are necessary for manifest and jar/project
	static def libName(String path) {
		var newPath = if( path.startsWith("/") ) path.substring(1) else path
		
		return if(newPath.endsWith(".jar") || newPath.endsWith(WollokManifest.WOLLOK_MANIFEST_EXTENSION)) {
			val s = newPath.split("/")
			newPath = s.get(s.size - 1)
			newPath.substring(0, newPath.indexOf("."))
		} else {
			return newPath.substring(0, newPath.indexOf("/"))
		}	
	
	}
	
	static def boolean isCoreLib(String fqn){
		if(fqn === null) return false
		val fqnMatches = libsFqn.filter[ String lib | fqn.startsWith(lib)]
		return fqnMatches.size() >= 1
	}
	
	
}