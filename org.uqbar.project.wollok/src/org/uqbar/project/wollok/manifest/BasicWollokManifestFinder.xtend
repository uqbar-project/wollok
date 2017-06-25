package org.uqbar.project.wollok.manifest

import com.google.inject.Singleton
import org.uqbar.project.wollok.WollokActivator

@Singleton
class BasicWollokManifestFinder implements WollokManifestFinder {
	
	val manifestNames = #["org.uqbar.project.wollok.lib"->"wollok"]
	
	def newManifest(String bundle, String manifestName){
		val fullName = manifestName + WollokManifest.WOLLOK_MANIFEST_EXTENSION
		
		if (WollokActivator.getDefault != null) {
			new WollokManifest(WollokActivator.getDefault.findResource(bundle, fullName))
		}
		else
			new WollokManifest(class.getResourceAsStream("/" + fullName))
	}
	
	override allManifests() {
		manifestNames.map[newManifest(it.key, it.value)]
	}
}