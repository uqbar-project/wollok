package org.uqbar.project.wollok.manifest

import org.eclipse.emf.ecore.resource.ResourceSet
import org.uqbar.project.wollok.WollokActivator
import com.google.inject.Singleton

@Singleton
class BasicWollokManifestFinder implements WollokManifestFinder {
	
	val manifestNames = #["org.uqbar.project.wollok.lib"->"wollok"]
	
	def newManifest(String bundle, String manifestName){
		val fullName = manifestName + WollokManifest.WOLLOK_MANIFEST_EXTENSION
		
		if(WollokActivator.getDefault !=null){
			new WollokManifest(WollokActivator.getDefault.findResource(bundle,fullName))
		}
		else
			new WollokManifest(class.getResourceAsStream("/" + fullName))
	}
	
	override allManifests(ResourceSet resourceSet) {
		manifestNames.map[newManifest(it.key,it.value)]
	}
}