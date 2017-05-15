package org.uqbar.project.wollok.manifest

import java.util.List
import org.eclipse.emf.ecore.resource.Resource

class JarWollokLibraries implements WollokLibraries {
	
	
	var List<String> paths
	
	new (){
		
	}	
	
	new (List<String> paths){
		this.paths = paths
	}
	

	def getPaths(Resource resource) {
		paths
	}
	
	override getWollokLibs(Resource resource
	) {
		return getPaths(resource).map[new JarWollokLib(it) as WollokLib]
	}
	
	
}