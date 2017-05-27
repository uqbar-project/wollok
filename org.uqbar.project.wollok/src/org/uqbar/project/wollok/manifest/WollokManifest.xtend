package org.uqbar.project.wollok.manifest

import java.io.BufferedReader
import java.io.InputStream
import java.io.InputStreamReader
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.IResourceDescription
import org.uqbar.project.wollok.scoping.WollokResourceCache

class WollokManifest {
	val uris = <URI>newArrayList
	public static val WOLLOK_MANIFEST_EXTENSION = ".wollokmf"
	
	new(InputStream is) {
		try {
			val reader = new BufferedReader(new InputStreamReader(is))
			var String name = null
			while((name = reader.readLine) != null){
				uris += URI.createURI("classpath:/" + name)
			}
		}
		finally {
			try {
				is.close
			}
			catch (Exception e) {
				println("Error while closing input stream on finally")
				e.printStackTrace
			}
		}
	}

	def getAllURIs() {
		uris
	}
	
		/**
	 * Load all resources in the manifests found.
	 */
	def load(ResourceSet resourceSet, IResourceDescription.Manager resourceDescriptionManager) {
		this.allURIs.map[loadResource(resourceSet, resourceDescriptionManager)].flatten
	}

	/**
	 * This message resolves the loading of a resource, is used by the resources listed in manifests. For the ones not in manifests (in relative locations)
	 * see WollokGlobalScopeProvider#toResource(Import imp, Resource resource)
	 */
	def loadResource(URI uri, ResourceSet resourceSet, IResourceDescription.Manager resourceDescriptionManager) {
		try {
			var Iterable<IEObjectDescription> exportedObjects
			exportedObjects = WollokResourceCache.getResource(uri)
			if (exportedObjects === null) {
				var resource = resourceSet.getResource(uri, true)
				resource.load(#{})
				exportedObjects = resourceDescriptionManager.getResourceDescription(resource).exportedObjects
				WollokResourceCache.addResource(uri, exportedObjects)
			}
			//System.err.println("anduvo resource [" + uri + "] in context [ " + resourceSet + "]")
			exportedObjects
		} catch (RuntimeException e) {
			//System.err.println("NO anduvo resource [" + uri + "] in context [ " + resourceSet + "]")
			throw new RuntimeException("Error while loading resource [" + uri + "] in context [ " + resourceSet + "]"   , e)
		}
	}
	
}
