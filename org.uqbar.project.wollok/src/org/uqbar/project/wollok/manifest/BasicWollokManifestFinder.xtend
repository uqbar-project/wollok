package org.uqbar.project.wollok.manifest

import com.google.inject.Inject
import com.google.inject.Singleton
import org.eclipse.emf.ecore.resource.Resource
import org.uqbar.project.wollok.WollokActivator
import java.util.List

@Singleton
class BasicWollokManifestFinder implements WollokManifestFinder {
	
	@Inject
	var WollokLibraries libs;
	
	val manifestNames = #["org.uqbar.project.wollok.lib"->"wollok"]
	
	def newManifest(String bundle, String manifestName){
		val fullName = manifestName + WollokManifest.WOLLOK_MANIFEST_EXTENSION
		
		if (WollokActivator.getDefault != null) {
			new WollokManifest(WollokActivator.getDefault.findResource(bundle, fullName))
		}
		else
			new WollokManifest(class.getResourceAsStream("/" + fullName))
	}
	
	override allManifests(Resource resource) {
		val o = manifestNames.map[newManifest(it.key,it.value)] 
		val allLibs = libs.getWollokLibs(resource);
		if (allLibs.isEmpty()) o else o + allLibs.libraryManifests()
	}
	
	def libraryManifests(List<WollokLib> allLibs) {
		allLibs.map[it.manifest]				
	}

}