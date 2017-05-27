package org.uqbar.project.wollok.manifest

import org.uqbar.project.wollok.manifest.WollokLib
import org.uqbar.project.wollok.WollokActivator
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IResourceDescription.Manager

/**
 * This is the wollok standard lib
 */
class StandardWollokLib implements WollokLib {
		
	def newManifest(String bundle, String manifestName){
		val fullName = manifestName + WollokManifest.WOLLOK_MANIFEST_EXTENSION
		
		if (WollokActivator.getDefault != null) {
			new WollokManifest(WollokActivator.getDefault.findResource(bundle, fullName))
		}
		else
			new WollokManifest(class.getResourceAsStream("/" + fullName))
	}
	
	def getManifest() {
		return newManifest("org.uqbar.project.wollok.lib", "wollok" )
	}
	
	
	override equals(Object obj) {
		return obj !== null && obj.class == this.class
	}
	
	override hashCode() {
		return class.hashCode
	}
	
	override load(Resource resource, Manager manager) {
		manifest.load(resource.resourceSet, manager)
	}
	
}