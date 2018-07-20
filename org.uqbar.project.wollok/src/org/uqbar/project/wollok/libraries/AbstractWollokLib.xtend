package org.uqbar.project.wollok.libraries

import javax.inject.Inject
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.IResourceDescription.Manager
import org.uqbar.project.wollok.scoping.WollokResourceCache
import static org.uqbar.project.wollok.libraries.WollokLibExtensions.*

/**
 * This is a base class to WollokLib based on  manifest file.
 * A Wollok manifest file is a file located at root of library
 * Each line of manifest file is a path to wollok file.
 * 
 * This class has a template method: it creates a WollokManifest instance, 
 * for each entry in manifest it loads the objects. 
 * It uses WollokResourceCache 
 * 
 * @author leo
 * 
 */
abstract class AbstractWollokLib implements WollokLib {

	@Inject
	var Manager resourceDescriptionManager	
	
	var WollokManifest manifest
	
	new() {}
	
	new (Manager manager) {
		this.resourceDescriptionManager = manager
	}
	def getManager() {
		return resourceDescriptionManager
	}
	
	override load(Resource resource) {
		return getManifest(resource).allURIs.map[it.load(resource)].flatten
	}

	def WollokManifest getManifest(Resource resource){
		if(manifest === null)
			manifest = this.doGetManifest(resource)
		
		return manifest
	}
	
	def WollokManifest doGetManifest(Resource resource)
	
	def internalLoad(URI uri, Resource resource) {
		load(uri, resource, manager)
	}
	
	/**
	 * Find contents in WollokResourceCache, if not found then call internalLoad. 
	 */
	 def Iterable<IEObjectDescription> load(URI uri, Resource resource) {
		try {
			var Iterable<IEObjectDescription> exportedObjects
			exportedObjects = WollokResourceCache.getResource(uri)
			if (exportedObjects === null) {
				exportedObjects = internalLoad(uri, resource)
				WollokResourceCache.addResource(uri, exportedObjects)
			}
			exportedObjects
		} catch (RuntimeException e) {
			throw new RuntimeException("Error while loading resource [" + uri + "] in context [ " + resource + "]", e)
		}
	}
	

}