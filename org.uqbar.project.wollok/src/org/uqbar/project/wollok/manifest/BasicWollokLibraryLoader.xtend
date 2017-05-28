package org.uqbar.project.wollok.manifest

import com.google.inject.Inject
import com.google.inject.Singleton
import com.google.inject.name.Named
import org.eclipse.emf.ecore.resource.Resource

@Singleton
class BasicWollokLibraryLoader implements WollokLibraryLoader {

	
	@Inject
	var WollokLibraries libs;
	
	@Inject 
	@Named("standardWollokLib")
	var WollokLib standardLib
	
	
	override load(Resource resource) {
		libraries(resource).map[load(resource)].flatten
	}
	
	def libraries(Resource resource) {
		#[standardLib] + libs.getWollokLibs(resource);
	}
	


}