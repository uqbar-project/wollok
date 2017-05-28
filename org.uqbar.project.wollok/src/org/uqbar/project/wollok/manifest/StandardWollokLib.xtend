package org.uqbar.project.wollok.manifest

import org.eclipse.emf.ecore.resource.Resource
import org.uqbar.project.wollok.WollokActivator

/**
 * This is the wollok standard lib
 */
class StandardWollokLib extends AbstractWollokLib {
	
	def newManifest(String bundle, String manifestName){
		val fullName = manifestName + WollokManifest.WOLLOK_MANIFEST_EXTENSION
		
		if (WollokActivator.getDefault !== null) {
			new WollokManifest(WollokActivator.getDefault.findResource(bundle, fullName))
		}
		else
			new WollokManifest(class.getResourceAsStream("/" + fullName))
	}
	
	override getManifest(Resource resource) {
		return newManifest("org.uqbar.project.wollok.lib", "wollok" )
	}
	
	
}