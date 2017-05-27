package org.uqbar.project.wollok.manifest

import com.google.inject.Inject
import com.google.inject.Singleton
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IResourceDescription

@Singleton
class BasicWollokLibraryLoader implements WollokLibraryLoader {

	
	@Inject
	var WollokLibraries libs;
	
	//todo inject?
	var WollokLib standardLib = new StandardWollokLib()
	
	@Inject
	IResourceDescription.Manager resourceDescriptionManager
	
	override load(Resource resource) {
		libraries(resource).map[load(resource, resourceDescriptionManager)].flatten
	}
	
	def libraries(Resource resource) {
		#[standardLib] + libs.getWollokLibs(resource);
	}
	


}