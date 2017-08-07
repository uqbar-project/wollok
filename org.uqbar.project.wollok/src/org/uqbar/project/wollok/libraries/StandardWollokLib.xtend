package org.uqbar.project.wollok.libraries

import org.eclipse.emf.ecore.resource.Resource
import org.uqbar.project.wollok.WollokActivator

/**
 * This represents the wollok standard lib
 * It finds wollok.wollokmf in the classPath or
 * in the bundle if it is necesary
 * 
 * @author tesonep
 * @author leo         
 */
class StandardWollokLib extends AbstractWollokLib {

	public static val standardLibManifestName = "wollok" + WollokManifest.WOLLOK_MANIFEST_EXTENSION
	
	def newManifest(String bundle, String manifestName){
		
		if (WollokActivator.getDefault !== null) {
			new WollokManifest(WollokActivator.getDefault.findResource(bundle, manifestName))
		}
		else
			new WollokManifest(class.getResourceAsStream("/" + manifestName))
	}
	
	override doGetManifest(Resource resource) {
		return newManifest("org.uqbar.project.wollok.lib", standardLibManifestName )
	}

		
}