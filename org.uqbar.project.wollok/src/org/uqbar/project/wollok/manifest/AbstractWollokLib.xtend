package org.uqbar.project.wollok.manifest

import org.uqbar.project.wollok.manifest.WollokLib
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.emf.common.util.URI
import org.uqbar.project.wollok.scoping.WollokResourceCache
import javax.inject.Inject
import org.eclipse.xtext.resource.IResourceDescription.Manager

abstract class AbstractWollokLib implements WollokLib {

	@Inject
	var Manager resourceDescriptionManager	
	
	override load(Resource resource) {
		return getManifest(resource).allURIs.map[it.load(resource)].flatten
	}
	
	def WollokManifest getManifest(Resource resource)
	
	def Iterable<IEObjectDescription> load(URI uri, Resource resource) {
			try {
			var Iterable<IEObjectDescription> exportedObjects
			exportedObjects = WollokResourceCache.getResource(uri)
			if (exportedObjects === null) {
				var newResource = resource.resourceSet.getResource(uri, true)
				resource.load(#{})
				exportedObjects = resourceDescriptionManager.getResourceDescription(newResource).exportedObjects
				WollokResourceCache.addResource(uri, exportedObjects)
			}
			exportedObjects
		} catch (RuntimeException e) {
			throw new RuntimeException("Error while loading resource [" + uri + "] in context [ " + resource + "]"   , e)
		}
	}
	
}