package org.uqbar.project.wollok.manifest

import java.util.List
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IResourceDescription.Manager
import com.google.inject.Inject
import com.google.inject.name.Named

class JarWollokLibraries implements WollokLibraries {
	
	@Inject
	var Manager manager
	
	@Inject
	@Named("libraries")
	var List<String> paths
	

	def getPaths(Resource resource) {
		paths
	}
	
	override getWollokLibs(Resource resource) {
		return getPaths(resource).map[new JarWollokLib(it, manager) as WollokLib]
	}
	
	
	
	
}