package org.uqbar.project.wollok.manifest

import org.eclipse.emf.ecore.resource.ResourceSet
import org.uqbar.project.wollok.WollokActivator
import com.google.inject.Singleton
import java.util.List
import com.google.inject.Inject
import com.google.inject.name.Named
import java.net.URLClassLoader
import java.io.File
import java.io.InputStream
import java.net.URL

@Singleton
class BasicWollokManifestFinder implements WollokManifestFinder {
	
	@Inject @Named("libraries")
	var List<String> libs = #[]
	
	val manifestNames = #["org.uqbar.project.wollok.lib"->"wollok"]
	
	def newManifest(String bundle, String manifestName){
		val fullName = manifestName + WollokManifest.WOLLOK_MANIFEST_EXTENSION
		
		if (WollokActivator.getDefault != null) {
			new WollokManifest(WollokActivator.getDefault.findResource(bundle, fullName))
		}
		else
			new WollokManifest(class.getResourceAsStream("/" + fullName))
	}
	
	override allManifests(ResourceSet resourceSet) {
		val o = manifestNames.map[newManifest(it.key,it.value)] 
		if (libs.isEmpty()) o else o + libraryManifests()
	}
	
	def libraryManifests() {
		libs.map[libManifest(it)]				
	}
	
	def libManifest(String lib) {
		new JarWollokLib(lib).getManifest()	
	}	 
}